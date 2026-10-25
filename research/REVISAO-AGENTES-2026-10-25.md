# Revisão cruzada — quatro relatórios: GDN, MTP, Flash Attention e IQ

**Data:** 2026-10-25. **Escopo:** pesquisa documental exclusiva, sem testes em máquina, GPU remota, compilação, scripts, profiler ou solicitação de logs.
**Alvo único:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`, RX 7800 XT (`gfx1101`, 16 GiB).
**Recebido:** quatro relatórios independentes: (1) GDN FP32, (2) MTP, (3) FA/memória e (4) auditoria de kernels IQ2/IQ3. Todos passaram por cruzamento documental; não confundir números dos agentes com medições em gfx1101.

## Resultado executivo

| Linha | Descoberta documentada | Maturidade da evidência | Implicação para este GGUF |
| --- | --- | --- | --- |
| GDN FP32 | KKT e scan em chunks de 64, scratch FP32, tail sequencial, `n_rs_batch` e rollback fazem parte do mesmo contrato | Diferença de código na origem e no destino; integração é proposta | Alta prioridade de análise de dependências para 48 camadas GDN |
| MTP | Uma camada extra `blk.64`; draft próprio, estado `h_nextn`, snapshots GDN do target dimensionados por `n_max` | Fluxo de código do destino e fórmulas de memória | Alta prioridade para orçamento estático de VRAM e LM head real |
| FA nativo | `TILE` e `MMA_F16` alocam staging de K/V em F16 no destino, mesmo quando o KV persistente é BF16/Q8_0 | Trecho do alocador verificado; benefício temporal é hipótese | Relevância potencial em verify MTP e contexto longo |
| MMB/MMQ | A otimização de prefill depende do tipo quantizado por tensor, do shape e de recursos RDNA3 | Inferência fundada em política de kernels | Não assumir que ganhos com Q4_K_M se transferem a RCO IQ misto |
| IQ MMVQ | Cinco famílias IQ2/IQ3 podem substituir tratamento de sinais por `apply_ksigns`; limite conservador de `mul24` já mapeado | Comparação estática confirmada em `vecdotq.cuh`; equivalência condicionada ao domínio não nulo | Melhor primeira proposta localizada para decode/verify, mas speedup desconhecido |
| IQ MMQ | Cinco helpers adicionais de tile unpack mantêm no destino `__vcmpne4/__vsub4`, enquanto a origem usa `apply_ksigns` | Diferença confirmada nas funções homólogas de `mmq-load-tiles.cuh` | Abrir proposta separada de prefill, sem assumir que port MMVQ resolve MMQ |

## Correções exigidas pela revisão cruzada

1. **Não usar quantizações de outros publicadores.** O relatório MTP menciona bartowski, tsaipifong e unsloth; eles não substituem o GGUF RCO do usuário. O relatório FA usa em algumas tabelas uma variante Swift IQ3_XXS de aproximadamente 12,32 GB, mas **o arquivo escolhido tem 9,7 GiB**, conforme a ficha `ajgazin`. Recalcular as margens somente com este arquivo.
2. **Não confundir `Q6_K` do MTP com `output.weight`.** O inventário RCO público do alvo contém oito tensores Q6_K associados ao bloco MTP `blk.64`, enquanto o `output.weight` do backbone é **IQ4_XS**. O loader `src/models/qwen35.cpp` usa `nextn.shared_head_head` quando presente e, caso contrário, reutiliza `model.output`. Logo, o custo hipotético de um `output.weight` Q6_K com 994,6 MiB e as propostas de vocabulário reduzido para Q6_K **não descrevem automaticamente o head usado neste GGUF**. A viabilidade do patch `0013` depende de saber qual objeto é selecionado.
3. **Parâmetros GDN reais:** o exemplo com `H_v=32,H_k=16,T=2048` do relatório GDN era hipotético. A arquitetura Qwen3.8-27B possui **`H_v=48,H_k=16`** e `S_v=128`. Com 64-token chunks e `PACKED_CS=2080`, o scratch A+KQ para um único stream de 2.048 tokens é `ceil(2048/64) * (48+16) * 2080 * 4 = 17.039.360 bytes = 16,25 MiB`. Em 8.192 tokens: **65 MiB**. São custos de dados lógicos, não picos de VRAM.
4. **Contexto e KV:** o cálculo F16 para 16 camadas de atenção é 64 KiB/token; Q8_0 usa 34 KiB/token, ou 1,0625 GiB a 32.768 tokens. O relatório FA apresenta **5,0625 GiB de tráfego lógico somado** ao converter e reler todo o cache em 16 camadas, o que não significa 5 GiB de scratch simultâneo. O custo efetivo depende de reuse/dispatch real.
5. **GQA:** `24 query heads / 4 KV heads = 6` consultas por head KV. Expressões `GQA-6` são razão de agrupamento, **não 6 heads KV**.
6. **MTP não tem snapshots gratuitos:** para 48 camadas GDN, 48 cabeças de valor e estado 128x128 FP32, a matriz de estado requer 144 MiB por plano por sequência. A convolução causal de largura 4 acrescenta aproximadamente 5,625 MiB por plano. Teoricamente: `(1+n_max)*149,625 MiB` antes de overhead. `n_max=3` dá 598,5 MiB; `n_max=7` dá 1.197 MiB. Um controlador adaptativo que reduza profundidade efetiva não diminui essas alocações reservadas pelo máximo.
7. **Não extrapolar benchmarks de terceiros:** medições públicas citadas pelos agentes em gfx1100/7900 XTX ou gfx1201/R9700 não são dados da RX 7800 XT e frequentemente pertencem a outros GGUFs/quantizações/versões.
8. **Evitar pedidos de testes:** os capítulos de build, benchmark, instrumentação, testes de rollback e `A/B` escritos pelos agentes são sugestões fora do escopo decidido pelo usuário. Neste repositório, transformá-los em **invariantes matemáticos, pré-condições do dispatcher, revisão de fluxo e riscos hipotéticos**, sem executar nada.

## GDN: mapa de dependências e invariantes

**Origem do algoritmo:** [`gated_delta_net_chunked.cu`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/gated_delta_net_chunked.cu), [`gated_delta_net.cu`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/gated_delta_net.cu); **destino** [`gated_delta_net.cu`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/gated_delta_net.cu).

- Dois kernels FP32, KKT e scan, em `64` tokens por chunk, `256` threads/CTA, `VT=16`, `PACKED_CS=2080`.
- Separar `K=n_rs_seq+1` (capacidade de snapshots) de `n_rs_batch` (largura máxima de verify por sequência). O guard da origem preserva os últimos `D=max(K>16?K:16,n_rs_batch)` tokens na execução sequencial.
- `ggml_cuda_wide_scratch<float>` da origem não pertence ao destino. Candidato documental de adaptação: `ggml_cuda_pool_alloc<float>`; conferir interfaces e lifetimes de buffers assíncronos por inspeção de código.
- A cauda sequencial precisa produzir todos os snapshots relevantes; em batches menores que `K`, a cópia do estado **pré-batch** também deve ser contemplada. Não modificar a fusão `GDN->CPY` inadvertidamente.
- As dependências atravessam API do `ggml`, `op_params[1]`, contexto (`n_rs_batch`), `delta-net-base.cpp`, memória recorrente/híbrida e políticas de speculative decoding. Incluir mudanças de API/ABI na matriz de riscos.
- Invariantes de multisequência e broadcast da origem demandam prova de indexação; a restrição inicial de uma sequência e `kda=false` é uma **recomendação de desenho**, não condição provada de hardware.
- LDS local reportada para `S_v=128`: KKT 17.152 B/CTA; scan 30.080 B/CTA; recursos reais após codegen em gfx1101 desconhecidos.

## MTP: custo do draft e dependências

**Destino:** [`src/models/qwen35.cpp`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp), [`common/speculative.cpp`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/common/speculative.cpp), [`src/llama-memory-recurrent.cpp`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/llama-memory-recurrent.cpp).

- `n_layer_nextn == 1`: uma camada MTP adicional reaplicada em sequência, e não um conjunto de `n` heads paralelos.
- O draft usa `h_nextn` do target, embedding, projeções, atenção, FFN e LM head. Seu custo **não é só uma matriz de logits**; há cache/contexto separados. O target mantém snapshots GDN para reversão.
- O `nextn.shared_head_head` é opcional; se ausente, o draft utiliza `model.output` (formato IQ4_XS neste GGUF). Se presente, só então examinar a quantização da matriz dedicada no manifesto.
- Regra de decisão teórica para uma profundidade `d`: `E[A_d]=1+Σ_{j=1..d}P(aceitar os j primeiros)`; uma estratégia especulativa é benéfica quando o custo esperado de draft + verify + overhead dividido por `E[A_d]` for inferior ao custo de decode simples. Sem probabilidades específicas do modelo, o resultado permanece indeterminado.
- Subset de vocabulário (patch `0013`) pode exigir cópia persistente de linhas e eliminar candidatos, e seu código limita-se ao caminho de head compartilhado. Prioridade condicional; investigar formatos e quantização reais em vez de usar hipótese de Q6_K no output.

## FA: staging lógico não é alocação de pico

**Destino:** [`ggml/src/ggml-cuda/fattn.cu`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu).

- O alocador marca `need_f16_K=true` e `need_f16_V=true` nos caminhos `TILE` e `MMA_F16`. No `VEC`, há ramos que preservam tipos nativos, conforme fallback.
- A hipótese é que decode Q8_0 numa largura pequena use `VEC` e verify mais largo selecione `TILE` com conversão. Isso é **condicional** a dispatch, shape, máscara e configuração de KV.
- Para todo o KV de 32K: leitura Q8_0 1,0625 GiB + escrita F16 2 GiB + leitura F16 2 GiB = 5,0625 GiB de tráfego lógico por passagem idealizada. Nativo Q8_0 exigiria pelo menos a leitura de 1,0625 GiB na mesma hipótese; há reuso e outras leituras possíveis.
- Staging de **uma** camada convencional em 32K é da ordem de 128 MiB, se ambos K e V forem convertidos; o pool pode reutilizar buffers. Não comparar 5 GiB de tráfego com 5 GiB de VRAM requerida.
- Pré-requisitos documentais de port: paridade exata entre launch, seleção do tipo nativo e cálculo de scratch; preservar guard `RDNA3_0`, head-256, GQA 6:1 e política de verify-band.
- Ganhos públicos em gfx1100 com Qwen3.5-9B head-256 ilustram aplicabilidade da família RDNA3 **somente como referências externas**; não transferir percentuais para este GGUF ou gfx1101.

## IQ: quarto relatório recebido, delta de MMVQ e MMQ

**Entrada:** auditoria de kernels IQ2/IQ3 para gfx1101 enviada em 2026-10-25. **Fonte verificada:**
[destino `vecdotq.cuh`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/vecdotq.cuh),
[origem `vecdotq.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh),
[destino `mmq-load-tiles.cuh`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq-load-tiles.cuh),
[origem `mmq-load-tiles.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/mmq-load-tiles.cuh).

**Diferenças confirmadas:**

1. Cinco produtos vetoriais IQ2/IQ3 em `vecdotq.cuh` substituem a sequência `__vcmpne4`/`__vsub4` por `apply_ksigns`; `IQ4_XS` é diferente e só oferece o candidato independente de multiplicação de escala.
2. **Achado novo:** os cinco helpers `ggml_cuda_mmq_load_tiles_iq{2_xxs,2_xs,2_s,3_xxs,3_s}` em `mmq-load-tiles.cuh` repetem o unpack antigo no destino. A origem também os converte para `apply_ksigns`. O cabeçalho MMQ inclui `vecdotq.cuh`, mas os corpos dos seus próprios helpers não mudam apenas porque o vec-dot é otimizado.
3. `common.cuh` do destino já define `ggml_cuda_dp4a` com `__builtin_amdgcn_sudot4` no HIP/AMD, portanto o relatório não traz uma nova implementação necessária de dot-product; `IQ4_XS` também já tem permute AMD na etapa de consulta.
4. A demonstração de `apply_ksigns` é local, baseada em bytes positivos e não nulos das cinco grades. Intercambiar bits de sinal, índices de tabela ou incluir outro formato fora desses domínios **invalida a demonstração**.
5. O helper `ggml_cuda_mul_small()` por `__mul24` está matematicamente delimitado para os seis vec-dot auditados, mas a eficiência da ISA, a pressão de VGPR e a ocupação são desconhecidas. Não substituir divisão inteira por shift com valores negativos nem mudar escala e geometria simultaneamente.
6. O relatório ordena os tipos principalmente por quantidade de tensores (97 IQ3_S, 83 IQ3_XXS etc.). É um critério útil de presença, **não demonstra o peso relativo de `output.weight` IQ4_XS**, o tráfego nem a participação real de MMVQ versus MMQ. Para otimização focada no GGUF, manter prioridades como hipóteses condicionais.

**Resultado documental:** [MMVQ IQ misto](mmvq-iq-mistos-rco.md) conserva a análise da aritmética dos vetores; uma proposta separada [MMQ unpack IQ](mmq-unpack-iq-rco.md) passa a acompanhar o prefill. Sem patch de inferência, compilação, benchmark ou teste prático.

## Conclusões e fila documental

| Prioridade nesta rodada | Pesquisa concluída | Próxima leitura de código |
| --- | --- | --- |
| 1 | GDN FP32: invariantes e custos por chunk | Propagação completa de `n_rs_batch` no grafo e na memória recorrente |
| 2 | MTP: custo de snapshots e distinção de LM heads | Seleção efetiva de head e quantização por tensor em `blk.64` |
| 3 | FA: staging e política hipotética de verify-band | Comparar par launcher/alocador dos formatos Q8_0 e BF16 |
| 4 | GEMM IQ: aplicabilidade por tipo | Mapear formas do manifesto RCO e tipos admitidos no MMB |
| 5 | IQ MMVQ: sinais e multiplicação pequena, com limites matemáticos verificados | Desenhar mudanças independentes por formato em `vecdotq.cuh` |
| 6 | IQ MMQ: unpack de sinais em cinco funções de tiles | Mapear elegibilidade de MMQ e código por formato em `mmq-load-tiles.cuh` |

**Nada foi executado no hardware; resultados são revisão estática, cálculo e crítica de fontes.**

## Referências

- [GGUF exato e manifesto RCO, ficha do publicador](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF)
- [Configuração oficial Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/config.json)
- [Origem RDNA Boosts](https://github.com/stew675/llama-cpp-rdna-boosts)
- [MMVQ IQ do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu)

## Histórico

- 2026-10-25: recebimento e revisão cruzada de três relatórios de agentes; corrigidas extrapolações de GGUF e divisões entre bytes lógicos e pico de memória.
- 2026-10-25: integração do quarto relatório de IQ2/IQ3. Confirmada a separação entre `vecdotq.cuh` e `mmq-load-tiles.cuh`; adicionada proposta MMQ específica, totalizando quatro relatórios recebidos.
