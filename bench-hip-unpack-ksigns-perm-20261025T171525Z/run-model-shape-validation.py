import os,re,subprocess
from pathlib import Path
repo=Path.cwd(); run=repo/'bench-hip-unpack-ksigns-perm-20261025T171525Z'
out=run/'model-shape'; binary=out/'bin/test-backend-ops-model-shape-perm'
args=[str(binary),'-b','ROCm0','-o','MUL_MAT,MUL_MAT_VEC_FUSION','-p','iq2_xs|iq2_xxs|iq3_xxs']
for variant in ('C','E'):
 libdir=run/'library'/variant
 env=os.environ.copy(); env['LLAMA_TEST_RANDOM_SEED']='4321'; env['LD_LIBRARY_PATH']=f'{libdir}:{repo}/build-hip-baseline/bin:/opt/rocm/lib'
 loader=subprocess.run(['ldd',str(binary)],env=env,text=True,capture_output=True,check=True).stdout
 (out/f'loader-{variant}.txt').write_text(loader)
 m=re.search(r'libggml-hip\.so\.0\s+=>\s+(\S+)',loader)
 expected=(libdir/'libggml-hip.so.0.27.0').resolve()
 if not m or Path(m.group(1)).resolve()!=expected: raise SystemExit(f'wrong library for {variant}: {loader}')
 (out/f'{variant}.command.txt').write_text('env LLAMA_TEST_RANDOM_SEED=4321 LD_LIBRARY_PATH='+env['LD_LIBRARY_PATH']+' '+' '.join(args)+'\n')
 print(f'start {variant}',flush=True)
 with (out/f'{variant}.log').open('w') as f:
  p=subprocess.run(args,env=env,stdout=f,stderr=subprocess.STDOUT,text=True)
 lines=(out/f'{variant}.log').read_text(errors='replace').splitlines()
 summary=[x for x in lines if 'tests passed' in x or x.startswith('  MUL_MAT(') or x.startswith('  MUL_MAT_VEC_FUSION(') or x.startswith('Failing tests:')]
 print(f'{variant} exit={p.returncode}',flush=True)
 print('\n'.join(summary[-12:]),flush=True)
 if p.returncode: raise SystemExit(f'{variant} backend tests failed')
