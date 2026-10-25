#!/usr/bin/env python3
import json
import pathlib
import shlex
import subprocess


repo_dir = pathlib.Path("/home/carlos/project/llama.gfx1101")
run_dir = repo_dir / "bench-hip-cumulative-validation-20261025T144800Z"
build_dir = repo_dir / "build-hip-baseline"
test_source = repo_dir / "tests/test-backend-ops.cpp"
det_dir = run_dir / "deterministic-test"
(det_dir / "bin").mkdir(parents=True, exist_ok=True)

original = test_source.read_text()
old = "thread_local std::default_random_engine gen(std::random_device{}());"
new = "thread_local std::default_random_engine gen(std::strtoul(std::getenv(\"LLAMA_TEST_RANDOM_SEED\"), nullptr, 10));"
if original.count(old) != 1:
    raise SystemExit(f"expected one RNG initializer, found {original.count(old)}")
patched = original.replace(old, new)
private_source = det_dir / "test-backend-ops.cpp"
private_source.write_text(patched)
(det_dir / "test-backend-ops.diff").write_text(
    subprocess.run(
        ["diff", "-u", str(test_source), str(private_source)],
        text=True,
        stdout=subprocess.PIPE,
        check=False,
    ).stdout
)

entries = json.loads((build_dir / "compile_commands.json").read_text())
entry = next(item for item in entries if item["file"] == str(test_source))
compile_args = shlex.split(entry["command"])
for i, arg in enumerate(compile_args):
    if arg == entry["file"]:
        compile_args[i] = str(private_source)
    elif arg == "-o":
        compile_args[i + 1] = str(det_dir / "test-backend-ops.cpp.o")
compile_command = shlex.join(compile_args)
(det_dir / "compile.command.txt").write_text(compile_command + "\n")
subprocess.run(compile_args, cwd=entry["directory"], check=True)

commands = subprocess.run(
    ["ninja", "-C", str(build_dir), "-t", "commands", "test-backend-ops"],
    text=True,
    check=True,
    stdout=subprocess.PIPE,
).stdout.splitlines()
link_command = next(line for line in commands if "-o bin/test-backend-ops " in line)
link_command = link_command.replace(
    "tests/CMakeFiles/test-backend-ops.dir/test-backend-ops.cpp.o",
    str(det_dir / "test-backend-ops.cpp.o"),
)
link_command = link_command.replace("-o bin/test-backend-ops ", f"-o {det_dir / 'bin/test-backend-ops'} ")
(det_dir / "link.command.txt").write_text(link_command + "\n")
subprocess.run(["bash", "-lc", link_command], cwd=build_dir, check=True)
subprocess.run(
    ["ldd", str(det_dir / "bin/test-backend-ops")],
    text=True,
    check=True,
    stdout=(det_dir / "ldd.txt").open("w"),
)
