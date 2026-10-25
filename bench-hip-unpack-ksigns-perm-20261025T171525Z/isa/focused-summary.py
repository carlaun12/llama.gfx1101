import json
import re
from pathlib import Path
root = Path(__file__).resolve().parent
summary=json.loads((root/'isa-summary.json').read_text())
with (root/'isa-focused.txt').open('w') as f:
  for tid,name in [(16,'IQ2_XXS'),(17,'IQ2_XS'),(18,'IQ3_XXS')]:
    f.write(f'{name} MMVQ\n')
    for label,flag in [('plain','ELi1ELb0ELb0ELb0EE'),('fused','ELi1ELb1ELb0ELb0EE')]:
      rows=[x for x in summary['mmvq.cu']['C'] if x['type']==tid and flag in x['symbol']]
      old=rows[0]
      idx=summary['mmvq.cu']['C'].index(old)
      new=summary['mmvq.cu']['E'][idx]
      def fields(x):
        return f"ins={x['instructions']} broadcast_mul={x['broadcast_mul']} broadcast_perm={x['broadcast_perm']} dot4={x['dot4']} loads={x['load_instructions']} vgpr={x['meta']['next_free_vgpr']} sgpr={x['meta']['next_free_sgpr']} private={x['meta']['private_segment_fixed_size']}"
      f.write(f'  {label}: C {fields(old)}\n')
      f.write(f'  {label}: E {fields(new)}\n')
      # Compare all load instructions and relative positions in the operation schedule.
      def events(path, sym):
        lines=path.read_text().splitlines()
        start=next(i for i,x in enumerate(lines) if x.startswith(sym+': ;'))
        end=next(i for i in range(start+1,len(lines)) if lines[i].startswith('.Lfunc_end'))
        result=[]
        for raw in lines[start:end]:
          m=re.match(r'^\s+([a-z][a-z0-9_]+)\s+(.+)$',raw)
          if not m: continue
          op,args=m.groups()
          if 'load' in op: result.append('load:'+op)
          elif op=='v_bcnt_u32_b32': result.append('popcnt')
          elif (op=='v_mul_lo_u32' and '0x1010101' in args) or (op=='v_perm_b32' and re.search(r',\s*0,\s*v\d+,\s*0$',args)): result.append('broadcast')
          elif op.startswith('v_dot4_i32'): result.append('dot4')
        return result
      cpath=root/'C-mmvq.cu.s'; epath=root/'E-mmvq.cu.s'
      c_ev=events(cpath,old['symbol']); e_ev=events(epath,new['symbol'])
      f.write(f"  schedule events identical={c_ev==e_ev}; C={','.join(c_ev[:90])}\n")
    f.write('\n')
  for filename in ('mmq-instance-iq2_xxs.cu','mmq-instance-iq2_xs.cu','mmq-instance-iq3_xxs.cu'):
    c=summary[filename]['C']; e=summary[filename]['E']
    active=[(x,y) for x,y in zip(c,e) if x['instructions']>7 or y['instructions']>7]
    def total(rows,key): return sum(x[key] for x in rows)
    f.write(f"{filename} MMQ (all instantiated kernels with device code)\n")
    for key in ('instructions','broadcast_mul','broadcast_perm','all_perm','load_instructions'):
      cv=total([x for x,y in active],key); ev=total([y for x,y in active],key)
      f.write(f'  {key}: C={cv} E={ev}\n')
    for key in ('next_free_vgpr','next_free_sgpr','private_segment_fixed_size'):
      cv=[x['meta'][key] or 0 for x,y in active]; ev=[y['meta'][key] or 0 for x,y in active]
      f.write(f'  {key}: C={min(cv)}..{max(cv)} E={min(ev)}..{max(ev)}; changed={sum(a!=b for a,b in zip(cv,ev))}\n')
    f.write(f"  active kernels={len(active)}; kernel instruction deltas={sorted(set(y['instructions']-x['instructions'] for x,y in active))}; load counts changed={sum(x['load_instructions']!=y['load_instructions'] for x,y in active)}\n\n")
print((root/'isa-focused.txt').read_text())
