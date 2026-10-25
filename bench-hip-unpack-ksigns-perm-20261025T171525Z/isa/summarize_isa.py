import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent
files = ["mmvq.cu"] + ["mmq-instance-iq2_xxs.cu", "mmq-instance-iq2_xs.cu", "mmq-instance-iq3_xxs.cu"]
func_re = re.compile(r"^(_ZL(?:13mul_mat_vec_q|9mul_mat_q)IL9ggml_type(16|17|18)[^:]*): ;")
inst_re = re.compile(r"^\s+([a-z][a-z0-9_]+)\s+(.+)$")

def analyze(path):
    lines = path.read_text().splitlines()
    out = []
    for i, line in enumerate(lines):
        m = func_re.match(line)
        if not m:
            continue
        symbol, type_id = m.groups()
        end = next((j for j in range(i + 1, len(lines)) if lines[j].startswith(".Lfunc_end")), len(lines))
        body = lines[i:end]
        ins = []
        for raw in body:
            q = inst_re.match(raw)
            if q:
                ins.append((q.group(1), q.group(2).split(" ;", 1)[0]))
        meta_start = next((j for j, x in enumerate(lines) if x.strip() == ".amdhsa_kernel " + symbol), None)
        meta = []
        if meta_start is not None:
            meta_end = next((j for j in range(meta_start + 1, len(lines)) if lines[j].strip() == ".end_amdhsa_kernel"), len(lines))
            meta = lines[meta_start:meta_end]
        metadata = {}
        for key in ("next_free_vgpr", "next_free_sgpr", "private_segment_fixed_size", "vgpr_spill_count", "sgpr_spill_count", "wavefront_size32"):
            mm = re.search(rf"\.amdhsa_{key}\s+(\d+)", "\n".join(meta))
            metadata[key] = int(mm.group(1)) if mm else None
        ops = [f"{op} {args}" for op, args in ins]
        out.append({
            "symbol": symbol,
            "type": int(type_id),
            "instructions": len(ins),
            "broadcast_mul": sum(op == "v_mul_lo_u32" and "0x1010101" in args for op, args in ins),
            "broadcast_perm": sum(op == "v_perm_b32" and re.search(r",\s*0,\s*v\d+,\s*0$", args) is not None for op, args in ins),
            "all_perm": sum(op == "v_perm_b32" for op, args in ins),
            "dot4": sum(op.startswith("v_dot4_i32") for op, args in ins),
            "popcount": sum(op == "v_bcnt_u32_b32" for op, args in ins),
            "load_instructions": sum("load" in op for op, args in ins),
            "meta": metadata,
            "schedule_excerpt": [op for op in ops if op.startswith(("v_bcnt_u32", "v_mul_lo_u32", "v_perm_b32", "v_dot4_i32", "global_load", "buffer_load", "flat_load"))][:100],
        })
    return out

summary = {}
for filename in files:
    summary[filename] = {variant: analyze(root / f"{variant}-{filename}.s") for variant in ("C", "E")}
(root / "isa-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
with (root / "isa-summary.txt").open("w") as f:
    for filename in files:
        f.write(f"[{filename}]\n")
        c, e = summary[filename]["C"], summary[filename]["E"]
        f.write(f"kernels C/E: {len(c)}/{len(e)}\n")
        for typ in (16, 17, 18):
            cs = [x for x in c if x["type"] == typ]
            es = [x for x in e if x["type"] == typ]
            if not cs and not es:
                continue
            def totals(rows):
                return {k: sum(x[k] for x in rows) for k in ("instructions", "broadcast_mul", "broadcast_perm", "all_perm", "dot4", "popcount", "load_instructions")}
            f.write(f"type {typ}: C={totals(cs)} E={totals(es)}\n")
            for old, new in zip(cs, es):
                f.write(f"  {old['symbol']}\n")
                f.write(f"    C ins={old['instructions']} mul={old['broadcast_mul']} perm={old['broadcast_perm']} dot4={old['dot4']} loads={old['load_instructions']} vgpr={old['meta']['next_free_vgpr']} sgpr={old['meta']['next_free_sgpr']} vspill={old['meta']['vgpr_spill_count']} sspill={old['meta']['sgpr_spill_count']}\n")
                f.write(f"    E ins={new['instructions']} mul={new['broadcast_mul']} perm={new['broadcast_perm']} dot4={new['dot4']} loads={new['load_instructions']} vgpr={new['meta']['next_free_vgpr']} sgpr={new['meta']['next_free_sgpr']} vspill={new['meta']['vgpr_spill_count']} sspill={new['meta']['sgpr_spill_count']}\n")
        f.write("\n")
print((root / "isa-summary.txt").read_text())
