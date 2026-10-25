# Rodada 05 — revisão cruzada dos quatro relatórios

**Data:** 2026-10-25. **Alvo exclusivo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`, publicado por `ajgazin`, RX 7800 XT `gfx1101` 16 GiB. **Branch de documentação:** `deep-research`.

## Proveniência, estado e escopo

O usuário forneceu **quatro resumos de relatórios dos agentes** R05, identificados como `RELATORIO-R05-BPE-GGUF.md`, `RELATORIO-R05-MTP-SUBSET.md`, `RELATORIO-R05-Q8-ROUNDING.md` e `RELATORIO-R05-FA-CONTRATO.md`. **Os arquivos Markdown completos não foram anexados** e não foram lidos nesta consolidação. Números de linhas/byte-count, identidade SHA-256 e afirmações de funções constam dos resumos, conforme indicado, e não equivalem automaticamente a uma auditoria independente do arquivo completo.

**Papel nesta etapa:** coordenação e revisão cruzada de conclusões dos agentes. Não houve quinta investigação, scripts, compilação, benchmark, GPU, obtenção de logs ou modificações em kernels. As referências de código a seguir apontam para revisões de comparação já adotadas no projeto:
- [Origem `stew675/llama.cpp` no commit `e8bd52069ca049cd5213366363451abbb5383865`](https://github.com/stew675/llama.cpp/tree/e8bd52069ca049cd5213366363451abbb5383865)
- [Destino `carlaun12/llama.gfx1101` no commit `31288c9c66e59377f7788d920678a565bb89dd37`](https://github.com/carlaun12/llama.gfx1101/tree/31288c9c66e59377f7788d920678a565bb89dd37)
- [Manifesto RCO por tensor](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF/blob/main/rco_types.tsv)

**Legenda:** *Relatado pelo agente* = conclusão do resumo; *Coerente entre os agentes* = corroboração cruzada, não verificação de arquivo binário; *Condicionado* = exige premissa ainda não comprovada; *Aberto* = evidência insuficiente.

## Conclusão executiva

| Frente | Síntese dos agentes | Revisão de coordenação | Pendente |
| --- | --- | --- | --- |
| Agente 1 — BPE | Tokenizers públicos Qwen/Swift/ajgazin com mesmo SHA-256; merges publicados; nenhuma incompatibilidade explícita | **Compatibilidade plausível**, elegibilidade não demonstrada | Tipo/ordem de IDs válidos, `floor(n_first/100)` e atributos dos tokens do GGUF efetivo |
| Agente 2 — MTP subset | Head `model.output` IQ4_XS é compatível estruturalmente; destino dispõe de FILL/SET_ROWS HIP | O subset não poupa head do target e requer cache, contexto, grafo; **risco LoRA** é bloqueio de desenho | Guard BPE e preservação de vínculo dos adaptadores |
| Agente 3 — Q8_0 RNE | Multiplicação int8×escala FP16 equivale por valor sob FP16 RNE, incluindo subnormais se preservados | **Prova aritmética local condicional**; não generalizar para resultado completo | FTZ, semântica HIP/LLVM, zeros, escalas especiais |
| Agente 4 — FA verify | Integração mínima em W=1–8 por TILE nativo Q8_0/BF16, seletor/launcher/scratch coerentes | Proposta documental limitada, **não port efetuado** | Dependência da prova Q8_0, caminho BF16 numérico, layouts e fallback |

## Agente 1 — BPE e ordem dos merges

**Relatório anunciado:** `RELATORIO-R05-BPE-GGUF.md`.

O resumo informa SHA-256 idêntico para `tokenizer.json` de três publicações públicas:
`0997f410c57a1f4e53b09e4be8f4a172d90edd9564368fb0847030937229b9f3`
(`Qwen/Qwen3.8-27B`, `ukisai/Swift-1.5-Qwen3.8-27b`, `ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-MTP`). **Valor apresentado pelo agente, não recalculado nesta revisão.** Identidade entre esses arquivos públicos não estabelece identidade do índice do GGUF RCO.

Segundo o resumo, o `merges.txt` público contém **247.587 linhas** contra um limiar básico de **124.160 IDs** para `n_vocab=248.320`. O número bruto de linhas não é `n_first` do guard, pois as regras precisam ser mapeadas a IDs únicos e válidos por `text_to_token()`. O guard da origem descarta resultados inválidos/duplicados, compara cada ID válido com o **ID válido anterior** e admite no máximo `floor(n_first/100)` inversões. Sem a sequência de IDs reais do vocabulário GGUF, essa desigualdade permanece **não comprovada**, embora não haja incompatibilidade evidente nas fontes descritas.

Os atributos `LLAMA_TOKEN_ATTR_CONTROL` e `LLAMA_TOKEN_ATTR_USER_DEFINED` são essenciais: o algoritmo mantém esses IDs mesmo fora do cutoff, de modo que `n_sel>=n_keep`. O agente observa que a propriedade `special` de `tokenizer_config.json` não determina diretamente os atributos dentro do `llama_vocab`; não concluir preservação de `<think>` ou `<|fim_prefix|>` exclusivamente a partir dela.

**Decisão:** não marcar o patch 0013 como habilitável para o GGUF exato. Estabelecer **compatibilidade provável; elegibilidade documental aberta**, sem pedir ao usuário dump/binário/comando.

**Fontes para prosseguimento dos agentes:** [guard `mtp_draft_vocab_ids_follow_merge_order`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-model.cpp#L2944-L2988), [construção do subset](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-model.cpp#L2989-L3085).

## Agente 2 — head IQ4_XS e integração do patch 0013

**Relatório anunciado:** `RELATORIO-R05-MTP-SUBSET.md`.

Os resultados relatados são coerentes com a revisão R04: o [grafo do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp#L659-L664) seleciona `model.output` quando não encontra `nextn.shared_head_head`, e o manifesto RCO atribui **IQ4_XS** a `output.weight`. A ausência do head opcional no manifesto é evidência forte, **não inspeção do GGUF binário**.

O agente documentou que `ggml_fill`, `ggml_set_rows` e seus operadores HIP **já existem no fork**, portanto não é necessário assumir port de kernels de SET_ROWS/FILL. O escopo pendente é no **C++ de modelo/contexto/cache/grafo MTP**: escolha do subset, cópia de linhas, cache por tipo de buffer e `n_keep`, `n_outputs==1`, criação do logit `-INFINITY`, scatter de índices e fallback para head completo.

**Memória:** head IQ4_XS original ~**644,14 MiB** permanece; subset com 98.304 linhas representa ao menos **255 MiB adicionais** (mais índices e eventuais tokens especiais). Não projetar economia de VRAM ou speedup medido.

**Novo risco levantado:** o uso de novo ponteiro de tensor para `mtp_draft->head` pode impedir que `build_lora_mm` encontre adaptadores indexados pelo ponteiro do head original. Isso requer **auditoria dos mapas/lookup de adaptador** e desenho de proteção explícita, especialmente se o usuário usar LoRA. O resumo não prova falha efetiva, nem que a versão e configuração do usuário ativam LoRA; classificar como **risco documental**, não bug observado.

**Decisão:** integração estruturalmente plausível **sob guard BPE e segurança dos adaptadores LoRA**. A simples existência de operadores HIP não prova compatibilidade integral de API entre os commits.

**Fontes do desenho:** [subsets `llama-model.cpp`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-model.cpp#L2989-L3085), [contexto MTP](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-context.cpp#L812-L823), [grafo `qwen35.cpp`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/models/qwen35.cpp#L656-L675).

## Agente 3 — Q8_0, precisão e arredondamento

**Relatório anunciado:** `RELATORIO-R05-Q8-ROUNDING.md`.

O argumento matemático relatado usa o bloco `Q8_0` (32 int8 e escala FP16, 34 bytes) e compara a multiplicação FP16 do [staging `dequantize_block_q8_0_f16`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/convert.cu#L44-L82) com a [rotina nativa `ggml_cuda_fattn_dequantize_q8_0_chunk`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-common.cuh).

**Prova condicional apresentada:** com a mesma escala FP16 e o mesmo inteiro de 8 bits, a multiplicação em precisão FP16 arredondada ao mais próximo, com empate para o par (RNE), retorna o mesmo resultado em ambos os caminhos. O agente argumenta que o produto exato de uma escala FP16 por um int8 cabe na precisão FP32, de modo que uma promoção a FP32 e conversão única para FP16 não impõe erro intermediário **se a semântica incluir subnormais e não introduzir FTZ divergente**.

**Fronteiras da prova:** a equivalência não estabelece ISA idêntica, comportamento com escalas especiais sem premissas adicionais, preservação de sinal do zero em toda cadeia, nem redução/softmax idênticos. A arquitetura, flags de compilação, FTZ/denormals e uso posterior do valor continuam fatores abertos, inclusive em `gfx1101`.

**Decisão:** aceitar como **fundamento matemático condicional para valores desquantizados**, não como certificação de igualdade bit a bit de Flash Attention ou logits MTP.

## Agente 4 — FA TILE, W=1–8 e scratch

**Relatório anunciado:** `RELATORIO-R05-FA-CONTRATO.md`.

O agente propõe o **menor recorte** de integração: caminho `TILE` Q8_0/BF16 nativo para verify em `W=1..8`, sem alterar a escolha e memória de prefill `W>8` e sem transportar a banda WMMA RDNA4 ou a arena de staging de prefill longo.

É indispensável alinhar o contrato `seletor -> tipo KV -> instanciação TILE -> carregador -> launcher -> get_alloc_size`. Pares K/V não compatíveis, layouts não suportados, ausência de `FAST_FP16_AVAILABLE` ou guards de BF16 exigem fallback F16 com reserva correspondente. A seleção em função de `W` é **condicional à geometria do modelo, máscara, strides e hardware**; não é observação de runtime.

**Dependências cruzadas:** a prova do Agente 3 sustenta apenas valores desquantizados Q8_0 sob condições; **BF16 direto no TILE** pode ter aritmética/precisão distinta do caminho que anteriormente arredondava a F16. Assim, BF16 exige análise numérica própria antes de afirmar preservação de resultados. A proposta **não está implementada**, e nenhuma taxa de aceitação, variação de logits ou ganho em gfx1101 foi medida.

**Decisão:** manter o recorte W1–8 como candidato documental, dependente de prova de casos-limite Q8_0 e de avaliação independente BF16.

## Questões que permanecem para os agentes

1. **P0 — BPE do GGUF:** existem metadados primários publicados suficientes para estabelecer `n_first`, o número de inversões, e os atributos especiais do `llama_vocab` efetivo? Se não, manter resultado negativo de evidência como conclusão final da investigação documental.
2. **P0 — LoRA do subset:** identificar como `build_lora_mm` associa adaptadores ao ponteiro do head e qual fallback ou preservação de associação é necessária. Não inferir incompatibilidade observada sem fonte.
3. **P0 — Semântica FP16 Q8_0:** separar a prova do valor matemático dos comportamentos permitidos para subnormais, FTZ e sinal de zero no alvo, sem pedir execução.
4. **P1 — BF16 TILE:** comparar semântica BF16 nativa com conversão BF16->F16 e o efeito teórico sobre KQ/PV; manter cenário Q8_0 independente.
5. **P1 — Revisão final do port mínimo:** exigir uma matriz única por formato e largura com fallback e scratch, após incorporar as conclusões dos itens anteriores.

## Estado da rodada

**Quatro resumos recebidos, quatro documentos integrais anunciados mas não anexados.** As missões originais podem ser consideradas **entregues em resumo**, mas as **pendências técnicas P0 não foram resolvidas**. Os relatórios completos não foram inventados nem commitados como se fossem arquivos de origem.

**Escopo respeitado:** somente atualização de documentação na branch `deep-research`, sem alteração de kernels, compilação, benchmark, GPU ou pedido de logs.
