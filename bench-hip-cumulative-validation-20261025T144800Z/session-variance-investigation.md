# Cross-session throughput difference

## Throughput records

The earlier IQ3_XXS direct-sign experiment measured its control A at 32.56938 tok/s for d=0 and 31.79945 tok/s for d=4096. The later IQ2_XXS validation measured the same active control library at 34.98567 and 34.31173 tok/s. These are +7.419% and +7.900% across sessions.

The old `baseline-hip-20261025T012021Z-xZDy5L` result from the original source was 32.640529/31.821090 tok/s. Rebuilt A in this cumulative session measured 32.33337/31.55651 tok/s, within -0.941%/-0.831% of that original record. This supports the source reconstruction and suggests the later A/B gain is not caused by using a mislabeled baseline directory.

## Evidence that matches

- Both prior sessions used the same `llama-bench` SHA-256 `39ed56ec...5fcda25`, model SHA-256 `e13d3e74...06c7d803`, and active control HIP library SHA-256 `676433a4...8e658b`.
- Their command lines match: `-dev ROCm0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 8 -r 1 -p 0 -n 128 -d 0,4096`.
- Both records identify the same Ryzen 7 5700X and RX 7800 XT/gfx1101. Both show a reported 190 W cap.
- Busy-sample telemetry from the slower IQ3_XXS session averaged 2291.6 MHz SCLK and 189.7 W; the faster IQ2_XXS session averaged 2328.4 MHz and 189.1 W. SCLK was about 1.6% higher in the faster session, while mean power was nearly the same. Mean junction temperature was 69.7 C in the slower session and 72.4 C in the faster session.
- Telemetry reported draw above 190 W in both sessions (116/267 and 102/250 busy samples). Therefore the configured cap did not establish a strict 190 W draw in either session.

## Assessment

The recorded SCLK change could explain part of the difference, but not the full 7.4-7.9% shift. Mean power and temperatures do not point to a clear thermal or power explanation. The older IQ3_XXS run also had a killed sample 18-B and reran samples 18-B, 19-B, and 20-A; this is a measurement caveat, but it does not establish the cause.

The available records do not identify why the same control binaries and settings produced different absolute throughput. The cause remains unknown. This is why the cumulative A/B and incremental B/C decisions use paired results within the current session rather than absolute throughput comparisons across sessions.
