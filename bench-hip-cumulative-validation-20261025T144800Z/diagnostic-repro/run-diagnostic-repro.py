#!/usr/bin/env python3
from pathlib import Path
import os
import re
import subprocess

repo = Path('/home/carlos/project/llama.gfx1101')
run = repo / 'bench-hip-cumulative-validation-20261025T144800Z'
outdir = run / 'diagnostic-repro'
binary = outdir / 'bin/test-backend-ops-plain-diagnostic'
args = [str(binary), '-b', 'ROCm0', '-o', 'MUL_MAT,MUL_MAT_VEC_FUSION', '-p', 'iq2_s|iq3_s|iq3_xxs|iq2_xxs']
status = []
for seed in (17, 25025):
    for variant in ('A', 'B', 'C'):
        libdir = run / 'library' / variant
        ldpath = f'{libdir}:{repo}/build-hip-baseline/bin:/opt/rocm/lib'
        env = os.environ.copy()
        env['LLAMA_TEST_RANDOM_SEED'] = str(seed)
        env['LD_LIBRARY_PATH'] = ldpath
        loader = subprocess.run(['ldd', str(binary)], env=env, text=True, capture_output=True, check=True).stdout
        (outdir / f'loader-{seed}-{variant}.txt').write_text(loader)
        hit = re.search(r'libggml-hip\.so\.0\s+=>\s+(\S+)', loader)
        expected = (libdir / 'libggml-hip.so.0.27.0').resolve()
        if not hit or Path(hit.group(1)).resolve() != expected:
            raise SystemExit(f'wrong HIP library for {seed}/{variant}: {hit.group(1) if hit else "not found"}')
        command = ['env', f'LLAMA_TEST_RANDOM_SEED={seed}', f'LD_LIBRARY_PATH={ldpath}', *args]
        (outdir / f'{seed}-{variant}.command.txt').write_text(' '.join(command) + '\n')
        proc = subprocess.run(args, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        log = outdir / f'{seed}-{variant}.log'
        log.write_text(proc.stdout)
        status.append(f'{seed} {variant} exit={proc.returncode}')
        print(f'{seed} {variant} exit={proc.returncode}')
        for line in proc.stdout.splitlines():
            if 'DIAG_INPUT_SET' in line or 'DIAG_INPUT tensor=' in line or 'DIAG_OUTPUT' in line or 'DIAG_VALUE' in line or 'tests passed' in line or 'ERR =' in line:
                print(line)
(outdir / 'status.txt').write_text('\n'.join(status) + '\n')
