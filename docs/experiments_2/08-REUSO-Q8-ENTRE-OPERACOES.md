# Experiments 2 — Reutilizacao q8_1 entre multiplicacoes distintas

**Data:** 2026-10-26. **Branch:** `experiment_2-1`. **Base examinada pelos agentes:** `5c4f54f73ebfc65a115449a54a45ff5d66ba001b`.

**Proveniência:** revisão dos resumos dos Agentes 1 e 4 apresentados no chat e dos dois relatórios textuais anexados dos Agentes 2 e 3. Nenhuma medição no GGUF alvo foi executada. Não confundir evidência do código com prova de que o backend realmente repete quantizações em uma execução do modelo.

## Decisão

**Candidato condicional de compartilhamento de q8_1 entre operações `GGML_OP_MUL_MAT` independentes; não implementar ainda.** O fork já reutiliza seu buffer q8_1 internamente em cada multiplicação. O trabalho novo seria eliminar produções repetidas entre multiplicações distintas de um mesmo `ggml_tensor *` F32, com layout, quantização e lifetime compatíveis, descontadas as fusões de grafo existentes.

A opção inicial mais defensável é uma **fusão local de operações conhecidas com um produtor q8_1 único e armazenamento explicitamente pertencente ao grupo**. Não usar cache global por ponteiro, nem presumir intercambiabilidade MMVQ/MMQ.

## Agente 1 — candidatos de grafo

| Candidato | Origem comum F32 | Duplicação q8_1 comprovada? | Prioridade |
| --- | --- | --- | --- |
| FFN gate/up denso, `LLM_FFN_PAR` | Sim | **Não**: backend reconhece fusão `MUL_MAT → MUL_MAT → GLU` em casos elegíveis | Residual apenas quando falhar a fusão |
| FFN gate/up MTP `blk.64` | Sim | Não; mesmos descontos da fusão | Residual |
| Atenção Q/K/V separada | Condicional a `layer.wqkv == nullptr` | Não, depende de dispatch | **Primeira investigação** |
| Atenção Q/K/V do MTP `blk.64` | Condicional a pesos separados | Não, depende de dispatch | **Primeira investigação** |
| Atenção linear `build_qkvz()`, `ssm_beta`, `ssm_alpha` | Múltiplas projeções de `cur` | Não; tipos e kernels podem variar | **Segunda investigação** |

Relatório do Agente 1 cita `src/models/qwen35.cpp` (`build_layer_ffn`, `build_layer_attn`, `build_mtp`, `build_layer_linear_attn`) e `src/llama-graph.cpp` (`build_ffn`, `build_qkv`, `build_qkvz`). Identidade de tensor é condição necessária, não prova de duplicação após fusões e dispatch.

**Critérios de duplicação efetiva:** nós separados sobrevivem à fusão; mesma versão lógica de `src[1]`; ambos seguem MMVQ ou MMQ quantizador; duas chamadas alocam buffers e quantizam; nenhuma incompatibilidade de layout ou indexação.

## Agente 2 — compatibilidade de representações (relatório integral fornecido)

MMVQ produz `block_q8_1`: 32 quantizados int8, escala e soma FP16, 36 bytes por 32 valores.

MMQ produz `block_q8_1_mmq`: 128 quantizados por bloco, 144 bytes por 128 valores, organizado conforme metadata e layout `D4`, `DS4` ou `D2S6`. Mesmo volume lógico não significa mesma representação; quantização pode diferir também por ordem aritmética e arredondamento.

| Par | Reuso direto | Exigência |
| --- | --- | --- |
| MMVQ ↔ MMVQ | Condicional | Mesma ativação, shape, padding, endereçamento e quantizador |
| MMQ ↔ MMQ | Condicional | Também mesmo `ds_layout`, indexação/scatter quando aplicável |
| MMVQ ↔ MMQ | **Não** | Reempacotamento ou quantização própria para cada consumidor |

O Agente 2 indica que IQ2_S, IQ3_S, IQ3_XXS e IQ4_XS usam `D4` em MMQ, mas isso só permite formar uma classe de compatibilidade quando a ativação e o endereçamento também coincidirem.

Os limites de `K`, padding, stride, índice, token, canal, lote, arredondamento, escala, soma e validade temporal precisam ser preservados.

## Agente 3 — modelo de custos lógicos (relatório integral fornecido)

Para `D=5120`, sem padding adicional, por coluna: entrada F32 = **20.480 B**, produção q8_1 = **5.760 B**, uma produção = **26.240 B** de leitura F32 + escrita q8_1.

Para `N` operações independentes que compartilham os mesmos valores e a representação:

```text
B_independente = 32.000 * N * W
B_compartilhado = (26.240 + 5.760 * N) * W
economia_logica = 26.240 * (N - 1) * W bytes
```

| N | W=1 | W=2 | W=4 | W=8 |
| --- | ---: | ---: | ---: | ---: |
| 2 | 26.240 B | 52.480 B | 104.960 B | 209.920 B |
| 3 | 52.480 B | 104.960 B | 209.920 B | 419.840 B |
| 4 | 78.720 B | 157.440 B | 314.880 B | 629.760 B |

Este é o **modelo mínimo de bytes lógicos**: mantém uma leitura integral q8_1 por consumidor, não representa acessos reais dos matvec, cache ou DRAM. Se as operações já compartilham uma quantização por fusão, não há economia adicional.

**Vida útil:** N buffers produzidos sequencialmente podem reutilizar uma região do pool; um buffer compartilhado prolonga sua vida e pode aumentar o pico da alocação total. Reduzir a contagem de buffers não assegura reduzir VRAM de pico. Podem ser eliminados até N-1 lançamentos de quantização, não os N lançamentos das multiplicações.

## Agente 4 — propriedade, streams e fallback

- `ggml_cuda_mul_mat_vec_q()` e `ggml_cuda_mul_mat_q()` alocam `src1_q8_1` privadamente com `ggml_cuda_pool_alloc`; o lifetime não é um tensor compartilhável do grafo. Pool de capacidade **não é cache de conteúdo**.
- Fusão local dentro de uma operação de backend: escolha preferencial. Receber somente um ponteiro `char*` externo sem metadados, lifetime e propriedade é insuficiente.
- É necessário um descritor que registre identidade/geração lógica de entrada, dispositivo, layout, K, W, strides, padding, metadados de quantização e ownership. Consumidores tomam empréstimo; dono libera depois do último uso.
- Em mesmo stream, a ordem de lançamentos pode fornecer a dependência; em streams concorrentes, eventos e sincronização de término são necessários. Graph capture/replay impõe requisitos de estabilidade da alocação e revalidação da entrada.
- Não adotar cache persistente indexado por `ggml_tensor*` ou endereço. Não passar q8_1 MMVQ para MMQ.
- Escopo mais restrito: `gfx1101`, `MUL_MAT` denso, consumidores MMVQ, tipos IQ compatíveis, src1 F32 idêntico, fallback para chamadas independentes se falhar qualquer guarda.
- Excluir inicialmente `MUL_MAT_ID`, MMQ, NVFP4, multi-GPU, views incompatíveis, mudanças de layout, streams sem dependências demonstradas e fusões que alterem outros usos F32.

## Revisão cruzada e próximos bloqueadores

1. **Confirmar pelo grafo concreto** se Q/K/V separados do modelo e MTP `blk.64` sobrevivem às fusões; o mero manifesto de tensores não comprova a execução.
2. **Confirmar despacho** de dois ou mais consumidores MMVQ compatíveis da mesma ativação. Q/K/V podem ter tipos, dimensões e kernels distintos.
3. **Verificar se há algo a eliminar:** quantização independente realmente presente, não substituída por fusão FFN ou uma projeção `wqkv` única.
4. Só então especificar fusão local, produtor compartilhado, propriedade e fallback. Um cache genérico é prematuro.
5. Não presumir ganho percentual, banda DRAM, ocupação, VRAM de pico menor ou latência a partir dos bytes lógicos.

**Resultado do tópico 1:** candidato **condicional**, com atenção Q/K/V e atenção linear em maior prioridade que gate/up já fundido. Nenhum patch, build, script, teste ou benchmark.
