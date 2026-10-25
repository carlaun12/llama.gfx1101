import json
import pathlib


repo = pathlib.Path("/home/carlos/project/llama.gfx1101")
root = pathlib.Path(__file__).resolve().parent
candidate_source = str(root / "source-candidate")
candidate_build = str(root / "build-candidate")
control_build = str(repo / "build-hip-baseline")
control = json.loads((repo / "build-hip-baseline/compile_commands.json").read_text())
candidate = json.loads((root / "build-candidate/compile_commands.json").read_text())


def command_for(entries, suffix):
    return next((entry for entry in entries if suffix in entry["file"]), None)


def normalize(entry):
    return (
        entry["directory"].replace(candidate_build, control_build).replace(candidate_source, str(repo)),
        entry["command"].replace(candidate_build, control_build).replace(candidate_source, str(repo)),
    )


lines = ["Normalized control/candidate HIP compile command comparison"]
for suffix in ("/mmvq.cu", "/template-instances/mmq-instance-iq2_xxs.cu"):
    control_entry = command_for(control, suffix)
    candidate_entry = command_for(candidate, suffix)
    if control_entry is None or candidate_entry is None:
        raise SystemExit(f"missing compile command for {suffix}")
    same = normalize(control_entry) == normalize(candidate_entry)
    lines.append(f"{suffix}: {'identical' if same else 'DIFFERENT'}")
    if not same:
        raise SystemExit("compile commands differ after source/build path normalization")

lines.append("CMake: Release, clang 22, HIP gfx1101, GGML_HIP_GRAPHS=ON, GGML_HIP_MMQ_MFMA=ON, GGML_HIP_NO_VMM=ON, GGML_NATIVE=ON")
(root / "build-comparison.txt").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
