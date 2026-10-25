import json
import pathlib
import shlex
import subprocess

repo = pathlib.Path(__file__).resolve().parents[2]
run = pathlib.Path(__file__).resolve().parents[1]
entries = json.loads((repo / "build-hip-baseline/compile_commands.json").read_text())
entry = next(e for e in entries if e["file"].endswith("/ggml-cuda/mmvq.cu"))
for variant in ("control", "candidate"):
    source = run / "isa" / variant / "ggml-cuda" / "mmvq.cu"
    out = run / "isa" / f"{variant}.s"
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
    result[1:1] = ["-I" + str(run / "isa" / variant / "ggml-cuda")]
    result.extend(["--cuda-device-only", "-S", "-o", str(out), str(source)])
    (run / "isa" / f"{variant}.command.txt").write_text(shlex.join(result) + "\n")
    with (run / "isa" / f"{variant}.compile.log").open("w") as f:
        subprocess.run(result, cwd=entry["directory"], stdout=f, stderr=subprocess.STDOUT, check=True)
    obj = run / "isa" / f"{variant}.o"
    obj_cmd = list(result)
    asm_index = obj_cmd.index("-S")
    del obj_cmd[asm_index]
    obj_cmd[obj_cmd.index("-o") + 1] = str(obj)
    obj_cmd.extend(["-c"])
    (run / "isa" / f"{variant}-object.command.txt").write_text(shlex.join(obj_cmd) + "\n")
    with (run / "isa" / f"{variant}-object.compile.log").open("w") as f:
        subprocess.run(obj_cmd, cwd=entry["directory"], stdout=f, stderr=subprocess.STDOUT, check=True)
    hsaco = run / "isa" / f"{variant}.hsaco"
    bundler = "/opt/rocm/llvm/bin/clang-offload-bundler"
    subprocess.run([bundler, "--type=o", "--unbundle", "--targets=hipv4-amdgcn-amd-amdhsa--gfx1101", f"--input={obj}", f"--output={hsaco}"], check=True)
    readobj = "/opt/rocm/llvm/bin/llvm-readobj"
    notes = subprocess.run([readobj, "--notes", str(hsaco)], text=True, capture_output=True, check=True)
    (run / "isa" / f"{variant}-object-notes.txt").write_text(notes.stdout)
    print(f"compiled {variant}: assembly={out} object={obj}")
