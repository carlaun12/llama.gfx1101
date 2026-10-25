#!/usr/bin/env python3
from pathlib import Path
import os, re, subprocess
repo=Path('/home/carlos/project/llama.gfx1101')
run=repo/'bench-hip-cumulative-validation-20261025T144800Z'
out=run/'model-shape-coverage'
binary=out/'bin/test-backend-ops-model-shape'
args=[str(binary), '-b', 'ROCm0', '-o', 'MUL_MAT,MUL_MAT_VEC_FUSION', '-p', 'iq2_xxs']
seed='71393'
for variant in ('A','B','C'):
    libdir=run/'library'/variant
    ldpath=f'{libdir}:{repo}/build-hip-baseline/bin:/opt/rocm/lib'
    env=os.environ.copy(); env['LLAMA_TEST_RANDOM_SEED']=seed; env['LD_LIBRARY_PATH']=ldpath
    loader=subprocess.run(['ldd',str(binary)],env=env,text=True,capture_output=True,check=True).stdout
    (out/f'loader-{variant}.txt').write_text(loader)
    m=re.search(r'libggml-hip\.so\.0\s+=>\s+(\S+)',loader)
    expected=(libdir/'libggml-hip.so.0.27.0').resolve()
    if not m or Path(m.group(1)).resolve()!=expected: raise SystemExit(f'wrong library for {variant}')
    cmd=['env',f'LLAMA_TEST_RANDOM_SEED={seed}',f'LD_LIBRARY_PATH={ldpath}',*args]
    (out/f'{variant}.command.txt').write_text(' '.join(cmd)+'\n')
    p=subprocess.run(args,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{variant}.log').write_text(p.stdout)
    print(f'{variant} exit={p.returncode}')
    for line in p.stdout.splitlines():
        if line.startswith('  MUL_MAT(') or line.startswith('  MUL_MAT_VEC_FUSION(') or 'tests passed' in line or 'Failing tests:' in line or '[MUL_MAT]' in line or '[ADD]' in line:
            print(line)
    if p.returncode: raise SystemExit(f'backend validation failed for {variant}; see log')
