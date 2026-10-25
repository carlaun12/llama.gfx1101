# GPU telemetry summary

Busy samples use GPU utilization >=95%. RX 7800 XT reports `Average Graphics Package Power`; repeated readings exceeded the configured/reported 190 W power cap. No clock or power limit was changed by this experiment.

| Session / variant | Busy samples | Mean power | Mean SCLK | Mean junction | Power >190 W | Ranges (power / SCLK / junction / memory) |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Cumulative session, all | 560 | 190.1 W | 2316.2 MHz | 69.8 C | 266/560 | 75-224 W / 1940-2484 MHz / 54-81 C / 62-88 C |
| Cumulative session, pp / A | 20 | 197.2 W | 2335.4 MHz | 66.3 C | 13/20 | 176-224 W / 2270-2410 MHz / 62-70 C / 70-76 C |
| Cumulative session, pp / B | 21 | 191.5 W | 2313.6 MHz | 65.7 C | 10/21 | 170-215 W / 2252-2367 MHz / 55-70 C / 69-74 C |
| Cumulative session, pp / C | 17 | 169.5 W | 2341.1 MHz | 66.2 C | 7/17 | 75-199 W / 2237-2484 MHz / 58-71 C / 70-74 C |
| Cumulative session, tg / A | 127 | 189.6 W | 2300.7 MHz | 70.0 C | 59/127 | 160-217 W / 1942-2435 MHz / 54-81 C / 62-88 C |
| Cumulative session, tg / B | 251 | 190.5 W | 2317.5 MHz | 70.3 C | 109/251 | 90-222 W / 1940-2484 MHz / 55-81 C / 67-88 C |
| Cumulative session, tg / C | 124 | 191.2 W | 2323.3 MHz | 70.3 C | 68/124 | 165-219 W / 1975-2442 MHz / 62-81 C / 74-86 C |
| IQ3_XXS direct session 13:02 | 267 | 189.7 W | 2291.6 MHz | 69.7 C | 116/267 | 63-215 W / 2157-2494 MHz / 48-79 C / 59-86 C |
| IQ2_XXS validation session 14:32 | 250 | 189.1 W | 2328.4 MHz | 72.4 C | 102/250 | 87-210 W / 2210-2482 MHz / 52-82 C / 62-87 C |

The current A/B/C sessions were interleaved by pair. Per-variant telemetry includes only samples attributed to that variant's benchmark interval. Historical session totals are less precise for per-variant attribution, but are adequate to compare overall device state.
