import json
import pathlib
import shlex
import subprocess

repo = pathlib.Path(__file__).resolve().parents[2]
run = pathlib.Path(__file__).resolve().parents[1]
entries = json.loads((repo / "build-hip-baseline/compile_commands.json").read_text())
files = ("mmq-instance-iq2_xxs.cu", "mmq-instance-iq2_xs.cu", "mmq-instance-iq3_xxs.cu")
for filename in files:
    entry = next(e for e in entries if e["file"].endswith("/template-instances/" + filename))
    for variant in ("C", "E"):
        source_dir = run / "isa" / variant / "ggml-cuda"
        source = source_dir / "template-instances" / filename
        out = run / "isa" / f"{variant}-{filename}.s"
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
        result[1:1] = ["-I" + str(source_dir)]
        result.extend(["--cuda-device-only", "-S", "-o", str(out), str(source)])
        (run / "isa" / f"{variant}-{filename}.command.txt").write_text(shlex.join(result) + "\n")
        with (run / "isa" / f"{variant}-{filename}.compile.log").open("w") as f:
            subprocess.run(result, cwd=entry["directory"], stdout=f, stderr=subprocess.STDOUT, check=True)
        print(f"compiled {variant} {filename}: {out}", flush=True)
