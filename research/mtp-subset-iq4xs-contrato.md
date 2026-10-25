# MTP: contrato de vocabulário reduzido do head IQ4_XS no gfx1101

> **Estado:** pesquisa estática aprofundada, 2026-10-25. Proposta independente do controlador adaptativo. **Nenhum patch aplicado, nenhum dado de throughput obtido e nenhum teste solicitado.**

**GGUF alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`, autor `ajgazin`, aprox. 9,7 GiB.
**GPU:** RX 7800 XT gfx1101, 16 GiB.
**Destino congelado:** `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`. **Origem congelada:** `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

## Sobre a proposta

O MTP seleciona `nextn.shared_head_head` quando presente e `model.output` em caso contrário, em [`qwen35.cpp` do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp#L659-L664). O inventário `rco_types.tsv` da distribuição `ajgazin` contém oito projeções Q6_K de `blk.64`, nenhuma `nextn.shared_head_head.weight`, e `output.weight` IQ4_XS. Portanto, **head compartilhado IQ4_XS é dedução documental forte**, ainda condicionada à integridade do manifesto diante do binário GGUF.

O [patch 0013 integrado na origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/models/qwen35.cpp#L656-L675) calcula logits **somente para um subset de IDs** no draft, recria a linha completa como valores `-INFINITY` e espalha os logits selecionados para seus IDs originais usando `ggml_set_rows`. O target continua consultando a saída integral. Isso restringe o espaço de candidatos do draft, e **pode alterar a distribuição de aceitação**; não é transformação matematicamente equivalente da geração.

## Ganhos estimados e custo de memória

O output compartilhado tem dimensões `5120 × 248320`, formato `IQ4_XS`, blocos de `256` pesos com `136` bytes.

| Grandeza | Cálculo | Estimativa teórica |
| --- | --- | --- |
| Head completo | `248320 × 5120 × 136 / 256` | 675.430.400 bytes = 644,14 MiB |
| Subset básico de 98.304 IDs | `98304 × 5120 × 136 / 256` | 267.386.880 bytes = 255 MiB |
| Índices do subset básico | `98304 × sizeof(int64_t)` | 786.432 bytes = 0,75 MiB |
| Proporção mínima de linhas mantidas | `98304 / 248320` | 39,59% |
| Matmul denso completo | `2 × 248320 × 5120` | 2,543 GFLOPs/token |
| Matmul para o subset básico | `2 × 98304 × 5120` | 1,007 GFLOPs/token |

Os custos do subset representam **mínimos**, pois a seleção acrescenta IDs especiais fora do cutoff. O modelo mantém o head original; o subset **acrescenta VRAM** ao mesmo tempo que pode diminuir bytes processados por token draft, e também acrescenta uma linha de logits `F32` preenchida com `-inf` e um scatter. Nenhuma cifra é medida em gfx1101. O compartilhamento da cópia entre contextos equivalentes impede multiplicação automática por número de contextos.

## Resultados da pesquisa: contrato exato da origem

### 1. Filtros para construir o subset

No [`llama_model::mtp_draft_vocab_get` e `mtp_draft_vocab_ids_follow_merge_order`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-model.cpp#L2944-L3085), **todos** os seguintes pontos precisam valer:

1. `n_keep>0`; `output` existe e contém pesos efetivamente alocados (`buffer` e `data` válidos). Modelos no modo de prova de ajuste sem alocação não recebem subset.
2. `arch` está na whitelist (inclui QWEN35), e o caminho de Qwen3.5 tem bloco `nextn` e não usa `nextn.shared_head_head` dedicado. Essa restrição é eliminada somente para outras arquiteturas/casos explicitamente tratados.
3. `n_keep < n_vocab`.
4. O tokenizer é **`LLAMA_VOCAB_TYPE_BPE`** e a contagem de merges recuperáveis é pelo menos metade da dimensão do vocabulário.
5. Pelo menos metade do vocabulário é representada por IDs encontrados pela análise das regras de merge; o número de inversões de ID comparado ao merge anterior é **no máximo 1%** desses IDs. Não se pode deduzir sucesso do guard apenas da declaração `Qwen2Tokenizer` no JSON público.
6. Seleção final inclui todo ID `t < n_keep` **OU** marcado como `LLAMA_TOKEN_ATTR_CONTROL` ou `LLAMA_TOKEN_ATTR_USER_DEFINED`, mesmo quando `t >= n_keep`.
7. O número `n_sel` de IDs mantidos precisa ser menor que o número original de linhas; caso contrário, não constrói cópia.

**Lacuna remanescente:** o `tokenizer_config.json` público do Qwen descreve muitos tokens especiais na faixa alta de IDs, mas não prova os atributos no `llama_vocab` final do GGUF nem a ordem de merges na implementação exata. A elegibilidade permanece **não confirmada**. Fonte do tokenizer upstream: [`tokenizer_config.json`](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/tokenizer_config.json).

### 2. Construção e memória

A origem mantém `mtp_draft_cache` de referências fracas, com chave `(n_keep, backend_buffer_type)`; uma cópia ativa pode ser compartilhada por contextos do **mesmo modelo** com esses dois parâmetros idênticos. O mutex protege a construção. A implementação:

- Recebe `row_bytes=output->nb[1]`, copia linhas selecionadas de `output` para buffer temporário `host`, agrupando IDs consecutivos.
- Cria tensor `head` no mesmo tipo GGML de `output` e tensor `ids` em `GGML_TYPE_I64`.
- Aloca os dois via `ggml_backend_alloc_ctx_tensors_from_buft`, com o mesmo tipo de backend do head de origem, e transfere os dados.
- Falha de alocação implica **fallback para head completo**; validação do tokenizer recusada também desabilita a otimização.
- A cópia exige memória host temporária para `n_sel × row_bytes` durante o setup; isso não é memória de VRAM residente de forma permanente.

**Risco específico de 16 GiB:** a seleção aumenta a memória residente exigida justamente no cenário de limite de offload completo ou contexto longo. Não prometer economia de VRAM apenas porque a execução do draft consulta menos linhas.

### 3. Ativação no contexto e grafo MTP

No [contexto MTP da origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-context.cpp#L812-L823), a construção só é solicitada quando `ctx_type == LLAMA_CONTEXT_TYPE_MTP` e `params.mtp_draft_vocab > 0`. Se bem-sucedida, `cparams.mtp_draft_vocab` recebe o `n_keep` solicitado.

Em [`qwen35.cpp` da origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/models/qwen35.cpp#L659-L673), o branch adicional depende de `mtp_draft != nullptr`, `head_w == model.output` e `n_outputs==1`. Ele calcula `build_lora_mm(mtp_draft->head, cur, head_s)`, cria a linha original F32 preenchida com `-inf`, executa `ggml_set_rows` usando `mtp_draft->ids` e restaura o formato `[n_vocab, 1]`.

**O destino já implementa `ggml_cuda_op_set_rows` em `set-rows.cu`** ([arquivo](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/set-rows.cu)); não existe justificativa automática para portar todo esse backend. A disponibilidade de `ggml_fill`, caminhos de operador e tipos precisa ser revisada contra a versão do destino antes de propor port, sem assumir equivalência de commits.

### 4. Limites de compatibilidade

- **`n_outputs != 1`**: caminho do subset do grafo MTP **não** entra, ainda que a cópia tenha sido criada; usa head completo.
- **Head dedicado presente**: o builder seleciona `nextn.shared_head_head` e a construção do subset do `model.output` é recusada para esse MTP.
- **Formato original**: a cópia preserva o tipo `IQ4_XS`; não implica requantização adicional nem transformar o original em Q6_K.
- **Tokens fora do subset**: recebem logit `-inf` no draft, mas o target mantém vocabulário completo. Isso pode excluir a melhor sugestão do modelo draft e alterar sua aceitação.
- **Rollback**: a camada MTP e o target continuam respeitando estado GDN/snapshots; subset não é substituto de MTP adaptativo.

## Riscos, correção e fallback

A ausência de token importante do draft fora do cutoff, em textos multilíngues, código ou modalidades mistas, é risco de qualidade/aceitação. Classificá-la como ganho inevitável é incorreto. A suposição de ordenação BPE pode falhar silenciosamente em algumas variantes de tokenizer, mas o código fonte registra warning e recua ao head completo. Subset adicional ocupa memória; o backend escolhido para a cópia pode ser CPU/VRAM conforme a residência de `model.output`.

## Verificação documental

1. Verificar o ramo de head compartilhado no manifesto e em `qwen35.cpp` por refs congeladas; classificar como dedução até conferir índice binário.
2. Conferir cada condição de `mtp_draft_vocab_get`, guard BPE, atributos e a política de buffer/cache.
3. Verificar a correspondência da chamada em `llama-context.cpp`, configuração pública, `qwen35.cpp` e suporte a `SET_ROWS/FILL` no backend.
4. Analisar a distribuição de IDs especiais no tokenizer publicado, **sem tratar arquivo upstream como equivalência demonstrada do GGUF quantizado**.
5. Não solicitar teste, dump de vocabulário, logs, compilação, comando local ou benchmark.

## Próximos passos

- Estudar uma opção de subset maior ou menor **somente como trade-off de memória versus espaço de candidatos**, sem recomendar número ótimo sem distribuição de aceitação.
- Separar a ideia de uma **view zero-copy** das restrições atuais: o código da origem faz cópia compactada, não view de linhas arbitrárias.
- Estabelecer dependências mínimas de API/cparams, guarda do head, construção/compartilhamento do subset e scatter F32, antes de qualquer proposta de port.
- Continuar verificações documentais no `llama_vocab` e o vínculo com metadados GGUF públicos.

## Referências

- [Manifesto RCO](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF/blob/main/rco_types.tsv)
- [Origem: setup e guard BPE](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-model.cpp#L2944-L3085)
- [Origem: contexto e ativação](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/llama-context.cpp#L812-L823)
- [Origem: Qwen35 MTP subset](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/src/models/qwen35.cpp#L659-L673)
- [Destino: Qwen35 LM head](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp#L659-L664)
- [Destino: SET_ROWS CUDA](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/set-rows.cu)

## Revisão dos agentes R05 — BPE, subset e proteção de LoRA (25/10/2026)

**Agente 1:** relatou três arquivos `tokenizer.json` públicos coincidentes pelo SHA-256 `0997f410c57a1f4e53b09e4be8f4a172d90edd9564368fb0847030937229b9f3` e `merges.txt` com cerca de 247.587 linhas, superando 124.160 para metade de 248.320 IDs. Não há prova de que o `text_to_token` do GGUF recupere IDs únicos suficientes, nem de que as inversões respeitem `floor(n_first/100)`. Tokens `CONTROL|USER_DEFINED` dependem de atributos internos do GGUF, não apenas da flag `special` publicada pelo HF. **Evidência favorável de procedência; habilitação não confirmada.** O hash e a contagem foram relatados pelo agente, não recomputados nesta revisão.

**Agente 2:** afirmou que o destino já dispõe dos operadores `ggml_fill` e `ggml_set_rows` no HIP. O port do patch 0013 deve se concentrar em construção/cache do subset, `ctx_type=MTP`, `n_outputs==1`, scatter e fallback; o head original IQ4_XS de 644,14 MiB continua presente, e as primeiras 98.304 linhas custam no mínimo 255 MiB de cópia extra.

**Risco novo:** `build_lora_mm` pode resolver adaptações LoRA pelo **ponteiro do tensor de head original**. Usar `mtp_draft->head` como um novo tensor sem preservar a relação pode ignorar adaptações; **não foi demonstrado que isso acontece com a configuração do usuário**. Antes de declarar o patch compatível com LoRA, o Agente 2 deve classificar a política de lookup e um guard/fallback apropriado. Sem análise completa desse mecanismo, não recomendar ativação irrestrita do subset com LoRA.

**Estado:** elegibilidade BPE não comprovada; compatibilidade de implementação em princípio; proteção de LoRA pendente. Detalhes e proveniência em [RODADA-05-RESULTADOS.md](RODADA-05-RESULTADOS.md). Não houve implementação, teste ou benchmark.

## Histórico

- 2026-10-25: auditoria estática específica do patch 0013, seleção por merge-order BPE, cobertura de tokens especiais, cache por buffer, ativação `n_outputs==1` e trade-off do subset IQ4_XS. Nenhum kernel alterado.
