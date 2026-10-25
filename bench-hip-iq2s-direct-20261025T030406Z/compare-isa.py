import pathlib
import re


root = pathlib.Path(__file__).resolve().parent
variants = {name: (root / f"{name}.s").read_text().splitlines() for name in ("control", "candidate")}
targets = {
    "plain": "_ZL13mul_mat_vec_qIL9ggml_type22ELi1ELb0ELb0ELb0EE",
    "fused": "_ZL13mul_mat_vec_qIL9ggml_type22ELi1ELb1ELb0ELb0EE",
}


def extract(lines, prefix):
    start = next(i for i, line in enumerate(lines) if line.startswith(prefix))
    symbol = lines[start].split(":", 1)[0]
    end = next(i for i in range(start + 1, len(lines)) if lines[i].strip().startswith(".size\t"))
    body = lines[start:end]
    instructions = [line.strip().split()[0] for line in body if re.match(r"^\s+[a-z][a-z0-9_]+\s", line)]
    meta_start = next(i for i in range(start, len(lines))
            if lines[i].strip().startswith(".amdhsa_kernel ") and lines[i].strip().endswith(symbol))
    meta_end = next(i for i in range(meta_start + 1, len(lines)) if lines[i].strip() == ".end_amdhsa_kernel")
    meta = "\n".join(lines[meta_start:meta_end])
    values = {}
    for key in ("private_segment_fixed_size", "wavefront_size32", "next_free_vgpr", "next_free_sgpr"):
        match = re.search(rf"\.amdhsa_{key}\s+(\d+)", meta)
        values[key] = int(match.group(1)) if match else None
    values["instructions"] = len(instructions)
    values["ops"] = {op: instructions.count(op) for op in (
        "v_mul_lo_u32", "v_bcnt_u32_b32", "v_and_b32_e32", "v_xor_b32_e32",
        "v_add_nc_u32_e32", "v_sub_nc_u32_e32", "v_dot4_i32_iu8",
    )}
    return values


for name, prefix in targets.items():
    print(name)
    for variant, lines in variants.items():
        print(f"  {variant}: {extract(lines, prefix)}")
