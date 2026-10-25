from pathlib import Path
import subprocess
repo=Path(__file__).resolve().parents[2]
run=Path(__file__).resolve().parents[1]
files={
 'mmvq':'ggml/src/ggml-hip/CMakeFiles/ggml-hip.dir/__/ggml-cuda/mmvq.cu.o',
 'mmq-iq2_xxs':'ggml/src/ggml-hip/CMakeFiles/ggml-hip.dir/__/ggml-cuda/template-instances/mmq-instance-iq2_xxs.cu.o',
 'mmq-iq2_xs':'ggml/src/ggml-hip/CMakeFiles/ggml-hip.dir/__/ggml-cuda/template-instances/mmq-instance-iq2_xs.cu.o',
 'mmq-iq3_xxs':'ggml/src/ggml-hip/CMakeFiles/ggml-hip.dir/__/ggml-cuda/template-instances/mmq-instance-iq3_xxs.cu.o',
}
bundler='/opt/rocm/llvm/bin/clang-offload-bundler'
readobj='/opt/rocm/llvm/bin/llvm-readobj'
target='hipv4-amdgcn-amd-amdhsa--gfx1101'
outdir=run/'isa/object-notes'
for name,rel in files.items():
 for variant,build in [('C',repo/'build-hip-baseline'),('E',run/'build/E')]:
  obj=build/rel
  hsaco=outdir/f'{variant}-{name}.hsaco'
  command=[bundler,'--type=o','--unbundle',f'--targets={target}',f'--input={obj}',f'--output={hsaco}']
  (outdir/f'{variant}-{name}-unbundle.command.txt').write_text(' '.join(command)+'\n')
  subprocess.run(command,check=True)
  result=subprocess.run([readobj,'--notes',str(hsaco)],text=True,capture_output=True,check=True)
  (outdir/f'{variant}-{name}.txt').write_text(result.stdout)
print('extracted metadata for C/E MMVQ and three MMQ instances')
