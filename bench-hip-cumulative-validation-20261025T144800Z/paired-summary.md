# Paired A/B results

Gains are computed per adjacent pair as `(candidate_tps / control_tps - 1) * 100`. Intervals are two-sided 95% Student-t intervals on the 10 paired percentage gains (`df=9`, `t*=2.262157`). The equal-weight decode summary averages d=0 and d=4096 gains within each pair before calculating its interval. Prefill is reported separately.

| Comparison | Workload | Control mean | Candidate mean | Paired gain | 95% CI |
| --- | --- | ---: | ---: | ---: | ---: |
| AB | tg128, d=0 | 32.33337 tok/s | 34.79532 tok/s | +7.616% | [+7.081%, +8.150%] |
| AB | tg128, d=4096 | 31.55651 tok/s | 34.13248 tok/s | +8.172% | [+7.408%, +8.936%] |
| AB | tg128 equal-weight d=0/4096 | - | - | +7.894% | [+7.604%, +8.184%] |
| AB | pp512 | 648.14009 tok/s | 647.55892 tok/s | -0.088% | [-0.476%, +0.300%] |
| BC | tg128, d=0 | 34.78216 tok/s | 35.05884 tok/s | +0.797% | [+0.392%, +1.203%] |
| BC | tg128, d=4096 | 34.05995 tok/s | 34.29797 tok/s | +0.703% | [+0.079%, +1.327%] |
| BC | tg128 equal-weight d=0/4096 | - | - | +0.750% | [+0.466%, +1.034%] |
| BC | pp512 | 647.85043 tok/s | 647.54177 tok/s | -0.044% | [-0.668%, +0.581%] |

