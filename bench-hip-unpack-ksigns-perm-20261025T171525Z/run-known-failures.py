import os,re,subprocess
from pathlib import Path
repo=Path.cwd(); run=repo/'bench-hip-unpack-ksigns-perm-20261025T171525Z'
out=run/'shared-iq3xxs-failures'; out.mkdir(exist_ok=True)
binary=repo/'bench-hip-cumulative-validation-20261025T144800Z/diagnostic-repro/bin/test-backend-ops-diagnostic'
args=[str(binary),'-b','ROCm0','-o','MUL_MAT,MUL_MAT_VEC_FUSION','-p','iq2_s|iq3_s|iq3_xxs|iq2_xxs']
for seed in ('17','25025'):
 for variant in ('C','E'):
  libdir=run/'library'/variant
  env=os.environ.copy(); env['LLAMA_TEST_RANDOM_SEED']=seed; env['LD_LIBRARY_PATH']=f'{libdir}:{repo}/build-hip-baseline/bin:/opt/rocm/lib'
  loader=subprocess.run(['ldd',str(binary)],env=env,text=True,capture_output=True,check=True).stdout
  (out/f'loader-{seed}-{variant}.txt').write_text(loader)
  m=re.search(r'libggml-hip\.so\.0\s+=>\s+(\S+)',loader)
  expected=(libdir/'libggml-hip.so.0.27.0').resolve()
  if not m or Path(m.group(1)).resolve()!=expected: raise SystemExit(f'wrong library for {seed}/{variant}')
  (out/f'{seed}-{variant}.command.txt').write_text(f'env LLAMA_TEST_RANDOM_SEED={seed} LD_LIBRARY_PATH={env["LD_LIBRARY_PATH"]} '+' '.join(args)+'\n')
  p=subprocess.run(args,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
  (out/f'{seed}-{variant}.log').write_text(p.stdout)
  fail_lines=[x for x in p.stdout.splitlines() if x.startswith('Failing tests:') or (x.startswith('  MUL_MAT_VEC_FUSION(') and 'FAIL' in x)]
  values=[x for x in p.stdout.splitlines() if x.startswith('DIAG_INPUT_SET') or x.startswith('DIAG_VALUE ') or x.startswith('DIAG_STAGE_VALUE node=out')]
  print(f'{seed}-{variant} exit={p.returncode} failures={len([x for x in fail_lines if "FAIL" in x])}',flush=True)
  print('\n'.join(values[-16:]),flush=True)
