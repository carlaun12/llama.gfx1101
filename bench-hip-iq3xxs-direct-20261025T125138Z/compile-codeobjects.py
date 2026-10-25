import json
import pathlib
import shlex
import subprocess


repo = pathlib.Path(__file__).resolve().parents[1]
root = pathlib.Path("/tmp/iq3xxs-direct-isa-review")
entries = json.loads((repo / "build-hip-baseline/compile_commands.json").read_text())
entry = next(e for e in entries if e["file"].endswith("/ggml-cuda/mmvq.cu"))

for variant in ("control", "candidate"):
    source = root / variant / "mmvq.cu"
    out = repo / "bench-hip-iq3xxs-direct-20261025T125138Z" / f"{variant}-metadata.o"
    argv = shlex.split(entry["command"])
    result = []
    skip = False
    for arg in argv:
        if skip:
            skip = False
            continue
        if arg == "-o":
            skip = True
            continue
        if arg == "-c" or arg == entry["file"]:
            continue
        result.append(arg)
    result[1:1] = ["-I" + str(root / variant / "ggml-cuda")]
    result.extend(["--cuda-device-only", "-c", "-o", str(out), str(source)])
    log = out.with_suffix(".compile.log")
    with log.open("w") as f:
        subprocess.run(result, cwd=entry["directory"], stdout=f, stderr=subprocess.STDOUT, check=True)
