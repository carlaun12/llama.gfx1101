import datetime
import json
import pathlib
import subprocess
import time

root = pathlib.Path(__file__).resolve().parent
stage_path = root / "telemetry-stage.txt"
command = ["rocm-smi", "--json", "--showpower", "--showtemp", "--showclocks", "--showuse"]
while True:
    stamp = datetime.datetime.now(datetime.timezone.utc).isoformat()
    stage = stage_path.read_text().strip() if stage_path.exists() else "unknown"
    result = subprocess.run(command, text=True, capture_output=True)
    try:
        payload = json.loads(result.stdout)
        row = {"timestamp": stamp, "stage": stage, "returncode": result.returncode, "rocm": payload}
    except json.JSONDecodeError:
        row = {"timestamp": stamp, "stage": stage, "returncode": result.returncode,
               "stdout": result.stdout, "stderr": result.stderr}
    print(json.dumps(row), flush=True)
    time.sleep(1)
