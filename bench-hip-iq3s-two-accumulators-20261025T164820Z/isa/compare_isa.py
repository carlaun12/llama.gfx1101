import pathlib
import re
import json

root = pathlib.Path(__file__).resolve().parent
symbols = {
    "fused": "_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb1ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj",
    "plain": "_ZL13mul_mat_vec_qIL9ggml_type21ELi1ELb0ELb0ELb0EEvPKvS2_PKi31ggml_cuda_mm_fusion_args_devicePfj15HIP_vector_typeIjLj3EEjjjS8_jjjS8_jjjj",
}


def analyze(lines, symbol):
    start = next(i for i, line in enumerate(lines) if line.startswith(symbol + ": ;"))
    end = next(i for i in range(start + 1, len(lines)) if lines[i].startswith(".Lfunc_end"))
    body = lines[start:end]
    ins = []
    for line in body:
        match = re.match(r"^\s+([a-z][a-z0-9_]+)\s+(.+)$", line)
        if match:
            ins.append((match.group(1), match.group(2).split(" ;", 1)[0]))
    dots = [(i, op, args) for i, (op, args) in enumerate(ins) if op == "v_dot4_i32_iu8"]
    state = {}
    next_chain = 0
    for idx, op, args in dots:
        vals = [x.strip() for x in args.split(",")]
        dst, acc = vals[0], vals[3].split()[0]
        if acc == "0" or acc not in state:
            chain = next_chain
            next_chain += 1
            length = 1
        else:
            chain, length = state[acc]
            length += 1
        state[dst] = (chain, length)
    chain_lengths = {}
    for chain, length in state.values():
        chain_lengths[chain] = max(chain_lengths.get(chain, 0), length)
    meta_start = next(i for i, line in enumerate(lines) if line.strip() == ".amdhsa_kernel " + symbol)
    meta_end = next(i for i in range(meta_start + 1, len(lines)) if lines[i].strip() == ".end_amdhsa_kernel")
    meta = "\n".join(lines[meta_start:meta_end])
    resources = {}
    for key in ("private_segment_fixed_size", "next_free_vgpr", "next_free_sgpr"):
        m = re.search(rf"\.amdhsa_{key}\s+(\d+)", meta)
        resources[key] = int(m.group(1)) if m else None
    resources["wavefront_size32"] = ".amdhsa_wavefront_size32 1" in meta
    resources["instructions"] = len(ins)
    resources["dot4_count"] = len(dots)
    resources["dot4_chains"] = sorted(chain_lengths.values(), reverse=True)
    resources["loads"] = [f"{op} {args}" for op, args in ins if "load" in op]
    resources["dot4"] = [args for _, _, args in dots]
    return resources, body

summary = {}
for variant in ("control", "candidate"):
    lines = (root / f"{variant}.s").read_text().splitlines()
    summary[variant] = {}
    for path, symbol in symbols.items():
        values, body = analyze(lines, symbol)
        summary[variant][path] = values
        (root / f"{variant}-{path}.body.s").write_text("\n".join(body) + "\n")
(root / "isa-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
for path in ("plain", "fused"):
    print(path)
    for variant in ("control", "candidate"):
        v = summary[variant][path]
        print(f"  {variant}: instructions={v['instructions']} dot4={v['dot4_count']} chains={v['dot4_chains']} VGPR={v['next_free_vgpr']} SGPR={v['next_free_sgpr']} private={v['private_segment_fixed_size']}")
