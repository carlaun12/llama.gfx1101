from pathlib import Path
import re,subprocess
root=Path(__file__).resolve().parent
outdir=root/'object-notes'
files=['mmvq.cu']+['mmq-instance-iq2_xxs.cu','mmq-instance-iq2_xs.cu','mmq-instance-iq3_xxs.cu']
mc='/opt/rocm/llvm/bin/llvm-mc'; readobj='/opt/rocm/llvm/bin/llvm-readobj'
all_rows={}
for filename in files:
 for variant in ('C','E'):
  assembly=root/f'{variant}-{filename}.s'
  obj=outdir/f'{variant}-{filename}.amdgpu.o'
  command=[mc,'-triple=amdgcn-amd-amdhsa','-mcpu=gfx1101','-filetype=obj',str(assembly),'-o',str(obj)]
  (outdir/f'{variant}-{filename}.assemble.command.txt').write_text(' '.join(command)+'\n')
  subprocess.run(command,check=True)
  text=subprocess.run([readobj,'--notes',str(obj)],text=True,capture_output=True,check=True).stdout
  (outdir/f'{variant}-{filename}.notes.txt').write_text(text)
  names=list(re.finditer(r'^\s*\.name:\s+(\S+)\s*$',text,re.M))
  rows=[]
  for i,m in enumerate(names):
   end=names[i+1].start() if i+1<len(names) else len(text)
   chunk=text[m.end():end]
   vals={k:int(v) for k,v in re.findall(r'^\s*\.(private_segment_fixed_size|sgpr_count|sgpr_spill_count|vgpr_count|vgpr_spill_count|wavefront_size):\s+(\d+)\s*$',chunk,re.M)}
   rows.append({'name':m.group(1),'resources':vals})
  all_rows[(filename,variant)]=rows
summary=[]
for filename in files:
 c=all_rows[(filename,'C')]; e=all_rows[(filename,'E')]
 # Pair in source order; symbols are stable for the same target and toolchain.
 by_name={x['name']:x['resources'] for x in e}
 targets=[x for x in c if re.search(r'ggml_type(16|17|18)',x['name']) and re.search(r'mul_mat_vec_q|mul_mat_q',x['name'])]
 diffs=[]; spill_summaries=[]
 for x in targets:
  y=by_name.get(x['name'])
  if y is None:
   diffs.append((x['name'],'missing E')); continue
  if x['resources']!=y:
   diffs.append((x['name'],x['resources'],y))
  spill_summaries.append((x['resources'].get('vgpr_spill_count',0),y.get('vgpr_spill_count',0),x['resources'].get('sgpr_spill_count',0),y.get('sgpr_spill_count',0)))
 summary.append(f'{filename}: affected kernels C/E={len(targets)}/{sum(1 for x in e if re.search(r"ggml_type(16|17|18)",x["name"]) and re.search(r"mul_mat_vec_q|mul_mat_q",x["name"]))}; resource records differing={len(diffs)}')
 if spill_summaries:
  summary.append('  spill counts (VGPR/SGPR) C/E range='+str((min(x[0] for x in spill_summaries),max(x[0] for x in spill_summaries),min(x[2] for x in spill_summaries),max(x[2] for x in spill_summaries)))+' / '+str((min(x[1] for x in spill_summaries),max(x[1] for x in spill_summaries),min(x[3] for x in spill_summaries),max(x[3] for x in spill_summaries))))
  summary.append('  private-segment bytes C/E range='+str((min(x['resources'].get('private_segment_fixed_size',0) for x in targets),max(x['resources'].get('private_segment_fixed_size',0) for x in targets)))+' / '+str((min(by_name[x['name']].get('private_segment_fixed_size',0) for x in targets),max(by_name[x['name']].get('private_segment_fixed_size',0) for x in targets))))
  summary.append('  VGPR count C/E range='+str((min(x['resources'].get('vgpr_count',0) for x in targets),max(x['resources'].get('vgpr_count',0) for x in targets)))+' / '+str((min(by_name[x['name']].get('vgpr_count',0) for x in targets),max(by_name[x['name']].get('vgpr_count',0) for x in targets))))
  summary.append('  SGPR count C/E range='+str((min(x['resources'].get('sgpr_count',0) for x in targets),max(x['resources'].get('sgpr_count',0) for x in targets)))+' / '+str((min(by_name[x['name']].get('sgpr_count',0) for x in targets),max(by_name[x['name']].get('sgpr_count',0) for x in targets))))
 if diffs: summary.extend('  '+str(x) for x in diffs[:20])
(outdir/'resource-delta.txt').write_text('\n'.join(summary)+'\n')
print((outdir/'resource-delta.txt').read_text())
