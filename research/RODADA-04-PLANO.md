# Quarta rodada de pesquisa — quatro investigações especializadas

**Data:** 2026-10-25
**Estado:** quatro resumos de conclusões recebidos em 25/10/2026 e consolidados em [RODADA-04-RESULTADOS.md](RODADA-04-RESULTADOS.md); os quatro documentos integrais anunciados não estavam anexados. Nenhum agente está executando em segundo plano nesta conversa.
**Branch de documentação:** `deep-research`.
**GPU-alvo:** AMD Radeon RX 7800 XT (gfx1101, Navi 32, 16 GiB).
**GGUF exato:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`.
**Autor/modelo:** `ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF`.

## Objetivo geral

Resolver as **incertezas decisórias** após os quatro relatórios iniciais:
- Qual LM head o MTP usa **neste GGUF**, quais tensores têm Q6_K e quais são os seus shapes?
- Quais matrizes IQ usam efetivamente **MMQ** no prefill, e onde o unpack pode ser especializado sem afetar MMVQ?
- Qual é a cadeia exata de propagação de `n_rs_batch` e preservação de estado na proposta GDN chunked FP32?
- Em que condições **concretas de código**, na arquitetura head-256/GQA 6:1, Flash Attention usa leitura nativa ou staging F16 para F16/BF16/Q8_0?

A documentação existente é o ponto de partida, não um texto a reproduzir. Os agentes devem contribuir com **deltas novos de pesquisa** e destacar afirmações que ainda não podem ser verificadas.

## Regras fixas dos quatro agentes

1. **Somente pesquisa documental remota.** Não executar, solicitar ou preparar comandos locais, scripts de testes, builds, benchmarks, profiling, dumps locais, logs, acesso remoto, GPU de nuvem ou resultados de inferência.
2. Consultar código público e fonte primária. Preferir refs imutáveis: destino `31288c9c66e59377f7788d920678a565bb89dd37`; origem `e8bd52069ca049cd5213366363451abbb5383865`. Se o código relevante existir apenas em `rdna-boosts`, informar explicitamente o ref de comparação e divergências em relação ao commit anterior. O estado desta documentação está na branch `deep-research`.
3. Não usar `master` como ponto de escrita. O papel dos agentes é **entregar relatório Markdown**, não modificar kernels nem branches.
4. Não transferir quantização, comportamento ou benchmarks de outros Swift/Unsloth/Bartowski/UkisAI para este RCO; o arquivo exato é 9,7 GiB segundo a ficha `ajgazin`.
5. Separar em toda afirmação **Fato conferido por leitura**, **Dedução matemática**, **Hipótese arquitetural** e **Lacuna documental**. Não atribuir percentuais de speedup em gfx1101; terceiros podem ser citados somente com fonte e hardware claramente identificados.
6. Preservar a distinção entre `MUL_MAT`, `MUL_MAT_ID`, MMVQ e MMQ, bem como entre memória reservada, tráfego de bytes lógico e latência.
7. Usar como estrutura de entrega: **Resumo executivo, Sobre a proposta, Evidências e referências, Ganhos estimados (somente condicionais), Resultados da pesquisa, Descobertas, Riscos e fallback, Verificação documental, Próximos passos, Tabela de achados conferidos/pendentes**.
8. Se não houver metadados públicos suficientes, dizer **não confirmado**; não pedir ao usuário que execute nada.

## Agente 1 — MTP: identidade e custo do head real

**Pergunta decisória:** o draft usa `nextn.shared_head_head` ou cai em `model.output`? Quais tensores de `blk.64` estão realmente em Q6_K e qual o custo de cada operação?

Fontes prioritárias:
- [Ficha e manifesto público `rco_types.tsv`](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF).
- [`src/models/qwen35.cpp`, destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp).
- [`common/speculative.cpp`, destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/common/speculative.cpp).
- Patches `0002` e `0013` da série RDNA Boosts; [pesquisa atual de MTP](mtp-adaptativo.md) e [subset](mtp-vocabulario-reduzido.md).

Tarefas:
1. Transcrever uma **tabela tensor-por-tensor** do `blk.64` (nome, tipo, dimensões se disponíveis, bytes teóricos, função), distinguindo dados públicos de suposições.
2. Examinar `create_tensor` e a seleção `nextn.shared_head_head ? nextn.shared_head_head : model.output`. Explicar exatamente **qual ocorrência no manifesto** decidiria o caminho real; não afirmar Q6_K para `output.weight` (IQ4_XS neste RCO).
3. Mapear uma proposta MTP: `h_nextn`, embeddings, projeção, atenção, FFN, logits, cache; separar tamanho do head do custo das outras camadas.
4. Auditar pré-condições reais do patch `0013`: head compartilhado, `n_outputs==1`, quantização, cópia de linhas, manutenção dos IDs de controle; estimar bytes da cópia nos formatos **reais** ou informar caso indisponíveis.
5. Distinguir `n_max` como **reserva de snapshots** da profundidade efetiva do controlador adaptativo; manter `149,625 MiB x (1+n_max)` como estimativa para uma sequência e condições documentadas, não VRAM observada.
6. Entregar uma classificação **aplicável / condicional / inaplicável / não confirmado** para MTP adaptativo, subset de head, tuning de Q6_K e alternativa sem cópia.

**Entrega sugerida:** `RELATORIO-R04-MTP-HEAD.md`. Não preparar experimentos.

## Agente 2 — MMQ: dispatch de prefill para IQ misto

**Pergunta decisória:** quais caminhos `IQ3_S`, `IQ3_XXS`, `IQ2_S/XS/XXS` realmente podem executar os cinco helpers de `mmq-load-tiles.cuh` no `gfx1101`?

Fontes prioritárias:
- [Destino `mmq-load-tiles.cuh`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq-load-tiles.cuh).
- [Origem `mmq-load-tiles.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/mmq-load-tiles.cuh).
- `ggml/src/ggml-cuda/mmq.cu`, `mmq.cuh`, `mmvq.cu`, `common.cuh` e qualquer dispatcher host necessário.
- [`rco_types.tsv` do GGUF exato](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF), [proposta MMQ](mmq-unpack-iq-rco.md) e [MMVQ](mmvq-iq-mistos-rco.md).

Tarefas:
1. Criar mapa **entrada (tipo, shape, número de colunas) -> decisão host -> kernel -> helper MMQ**, anotando restrições `RDNA3_0`, elegibilidade `MMQ` e eventuais fallbacks. Diferenciar `MUL_MAT` de `MUL_MAT_ID`.
2. Extrair os cinco diffs de `apply_ksigns` da origem, preservando máscaras, offsets de tabelas, ordem de escala e endereços de tile; explicar por que `vecdotq.cuh` sozinho **não** alcança o unpack de MMQ.
3. Mapear matriz grande `output.weight` IQ4_XS sem exagerar seu papel em prefill: tipo, shape e bytes (~644 MiB) não provam o kernel de execução.
4. Distinguir formatos presentes de **volume por tensor e chamadas**; não estimar tempo por contagem simples de 314 tensores.
5. Documentar competição entre MMQ, MMVQ, GEMM, rocBLAS e MMB somente quando houver caminho estático verificável no código.
6. Entregar uma ordem de propostas pontuais: `IQ3_S`, `IQ3_XXS`, IQ2 e IQ4_XS, com impacto **condicional**, evidência e riscos de VGPR/tile.

**Entrega sugerida:** `RELATORIO-R04-MMQ-DISPATCH.md`. Não preparar testes.

## Agente 3 — GDN: propagação de estado e rollback

**Pergunta decisória:** quais alterações mínimas são realmente obrigatórias para acrescentar **chunked FP32** sem comprometer o contrato de recorrência e speculative MTP no fork?

Fontes prioritárias:
- [Origem `gated_delta_net_chunked.cu`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/gated_delta_net_chunked.cu).
- Origem e destino `gated_delta_net.cu`; `ggml/include/ggml.h`, `ggml/src/ggml.c`, `src/models/delta-net-base.cpp`, `src/llama-memory-recurrent.cpp`, híbrido e `common/speculative.cpp`.
- [Proposta atual de GDN](gdn-chunked-gfx1101.md) e [revisão](REVISAO-AGENTES-2026-10-25.md).

Tarefas:
1. Construir uma **matriz de propagação** campo/valor desde a configuração da especulação (`n_max`) até `n_rs_batch`, `K=n_rs_seq+1`, `op_params`, dispatcher HIP e alocações. Indicar arquivos e símbolos exatos.
2. Fazer prova documental do invariante de tail `D=max(K>16?K:16,n_rs_batch)`; definir estados e índices preservados para `T<=D`, `D<T<K+D`, `T>K`, `T<K` e vários `seq_id`. Se faltarem detalhes, marcar hipótese.
3. Mapear `GDN->CPY`, ownership do estado, alias `state_in/state_out`, cópia pré-batch, `split_equal` e rollback completo de GDN **mais conv1d**.
4. Comparar `ggml_cuda_wide_scratch` na origem com `ggml_cuda_pool_alloc` no destino; estudar exigências documentais de vida útil, ordem no stream e falha de alocação.
5. Recalcular SCRATCH pela geometria correta `H_v=48,H_k=16,S_v=128,CS=64` (16,25 MiB em 2K; 65 MiB em 8K por stream, sem overhead). Não confundir scratch lógico com VRAM de pico.
6. Produzir lista de mudanças necessárias versus opcionais, riscos de ABI, casos multissequência e proposta de fallback sequencial. **Sem portar código.**

**Entrega sugerida:** `RELATORIO-R04-GDN-ROLLBACK.md`. Não preparar testes.

## Agente 4 — FA: dispatch e contrato de scratch para verify

**Pergunta decisória:** em quais condições de código a verificação MTP com larguras `W=1..8` exige staging para F16, e onde KV Q8_0/BF16 pode ser lido diretamente?

Fontes prioritárias:
- [Destino `fattn.cu`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu); `fattn-common.cuh` e variantes `fattn-vec`, `fattn-tile`, `fattn-mma`.
- [Origem `fattn-rdna.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh) e implementações nativas, patches `0004/0005`.
- [Proposta FA](flash-attention-kv-nativo.md) e [revisão cruzada](REVISAO-AGENTES-2026-10-25.md).

Tarefas:
1. Reconstituir os **predicados exatos**, incluindo máscara, alinhamento, tipo K/V, head-256, Q/K/V shapes, GQA 6:1, largura W, comprimento do contexto e `RDNA3_0`; evitar declarar uma escolha de kernel universal.
2. Produzir uma tabela de cenários **`W=1..8` por `F16/BF16/Q8_0`** classificando cada célula **código confirma / condição pendente / não elegível**. A saída deve ser hipótese de dispatch quando as condições não puderem ser fixadas, nunca trace.
3. Comparar, em ambos os repositórios, **seletor + launcher + get_alloc_size**. Marcar cada ramo onde o kernel lê KV nativo, onde converte para F16 e que scratch o alocador deve reservar.
4. Modelar a 32K tokens: KV F16 2 GiB, Q8_0 1,0625 GiB; staging integral lógico de uma camada F16 ~128 MiB; tráfego somado idealizado Q8_0->F16->atenção ~5,0625 GiB em 16 camadas. Não alegar pico simultâneo igual à soma.
5. Examinar a hipótese de fronteira entre decode e verify e a relação com GDN/MTP **pela ordem de redução**, sem resultados de logits ou speedup.
6. Enumerar conjunto mínimo de funções para eventual port de leitura Q8_0 e BF16, com guard, fallback e dependências; não importar arena RDNA4 sem justificar.

**Entrega sugerida:** `RELATORIO-R04-FA-VERIFY.md`. Não preparar testes.

## Protocolo de consolidação ao receber os relatórios

- Associar cada afirmação ao repositório, arquivo, símbolo, ref e evidência; resolver divergências dos agentes antes de atualizar as propostas.
- Incorporar descobertas confirmadas aos `.md` existentes e abrir propostas novas só quando a superfície de otimização for efetivamente distinta.
- Manter estados explícitos: **Confirmado em código, Derivado matematicamente, Condicional, Não comprovado**.
- Preservar o histórico dos quatro relatórios anteriores na [revisão cruzada](REVISAO-AGENTES-2026-10-25.md).
- Não há trabalho autônomo executando por esta conversa; os prompts precisam ser entregues aos quatro agentes externos ou usados como guias de análise síncrona.
