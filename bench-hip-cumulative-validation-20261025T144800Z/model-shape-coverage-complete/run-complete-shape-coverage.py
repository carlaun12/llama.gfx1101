from pathlib import Path
import os, re, subprocess
repo=Path('/home/carlos/project/llama.gfx1101')
run=repo/'bench-hip-cumulative-validation-20261025T144800Z'
out=run/'model-shape-coverage-complete'
binary=out/'bin/test-backend-ops-model-shape-complete'
args=[str(binary), '-b', 'ROCm0', '-o', 'MUL_MAT,MUL_MAT_VEC_FUSION', '-p', 'iq2_s|iq3_s|iq3_xxs|iq2_xxs']
seed='4321'
failed=[]
for variant in ('A','B','C'):
    libdir=run/'library'/variant
    ldpath=f'{libdir}:{repo}/build-hip-baseline/bin:/opt/rocm/lib'
    env=os.environ.copy(); env['LLAMA_TEST_RANDOM_SEED']=seed; env['LD_LIBRARY_PATH']=ldpath
    loader=subprocess.run(['ldd',str(binary)],env=env,text=True,capture_output=True,check=True).stdout
    (out/f'loader-{variant}.txt').write_text(loader)
    match=re.search(r'libggml-hip\.so\.0\s+=>\s+(\S+)',loader)
    expected=(libdir/'libggml-hip.so.0.27.0').resolve()
    if not match or Path(match.group(1)).resolve()!=expected:
        raise SystemExit(f'wrong HIP library for {variant}: {loader}')
    command=['env',f'LLAMA_TEST_RANDOM_SEED={seed}',f'LD_LIBRARY_PATH={ldpath}',*args]
    (out/f'{variant}.command.txt').write_text(' '.join(command)+'\n')
    print(f'start {variant}',flush=True)
    with (out/f'{variant}.log').open('w') as log:
        p=subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,text=True)
    print(f'{variant} exit={p.returncode}',flush=True)
    lines=(out/f'{variant}.log').read_text(errors='replace').splitlines()
    for line in lines:
        if ('tests passed' in line or 'Failing tests:' in line or
            line.startswith('  MUL_MAT(') or line.startswith('  MUL_MAT_VEC_FUSION(')):
            print(line,flush=True)
    if p.returncode: failed.append(variant)
if failed:
    raise SystemExit('backend shape validation failed for variants: '+','.join(failed))
