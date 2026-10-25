# Resultados da Rodada 04 — MTP real, MMQ, GDN e FA verify

**Data:** 25/10/2026. **Modo:** pesquisa documental remota, sem benchmarks, testes, código compilado, execução em GPU ou alteração dos kernels.

**Modelo único:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` (publicador `ajgazin`, aprox. 9,7 GiB); Radeon RX 7800 XT `gfx1101`, VRAM 16 GiB.

**Material recebido:** o usuário colou **quatro resumos de relatórios da Rodada 04** (MTP, MMQ, GDN e Flash Attention). Os arquivos completos nomeados `RELATORIO-R04-*.md` **não foram anexados nesta mensagem**; cálculos pormenorizados que só constariam desses relatórios não foram assumidos como auditados. A conferência independente cobriu manifesto público e funções selecionadas do código-fonte nas revisões abaixo.

- Destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`
- Origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`
- Documentação na branch `deep-research`, [plano da rodada](RODADA-04-PLANO.md).
- [Manifesto público por tensor `rco_types.tsv`](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF/blob/main/rco_types.tsv).

## Resumo executivo e grau de confiança

| Frente | Resultado principal | Grau de evidência | Decisão documental |
| --- | --- | --- | --- |
| MTP | `blk.64` tem 8 projeções Q6_K; head opcional não aparece no manifesto; `model.output` é IQ4_XS | Manifesto confirmado, código do fallback confirmado, binário não inspecionado | Classificar head compartilhado IQ4_XS como hipótese **fortemente sustentada** |
| MMQ | `IQ3_S`, `IQ3_XXS`, `IQ2_XXS` conservam elegibilidade MMQ em >128 colunas no ramo RDNA3; `IQ2_S/XS` não | `ggml_cuda_should_use_mmq` confirmado, restantes dos dispatchers não totalmente mapeados | Separar escolha do seletor de execução observada |
| GDN | `n_rs_batch`, K, D, cauda sequencial e snapshots são interdependentes; plano da rodada existe | Origem e docs conferidos; nenhum fluxo multissequência end-to-end auditado nesta etapa | Preservar contrato conjunto GDN+conv+rollback; não declarar prova total |
| FA | Destino pode alternar VEC W1–2 para TILE W3–8 em Q8_0; origem usa TILE uniforme com KV nativo quando elegível | Predicados do seletor e alocação comparados em código | Priorizar coerência seletor/launcher/scratch e largura especulativa |

## 1. MTP: identidade real do LM head

O [`rco_types.tsv`](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF/blob/main/rco_types.tsv) informa `output.weight: iq4_xs` na coluna `RCO-IQ3_XXS`. Lista estes **oito** tensores Q6_K em `blk.64`, em todas as variantes RCO:

| Grupo | Tensores Q6_K de `blk.64` |
| --- | --- |
| Atenção | `attn_q.weight`, `attn_k.weight`, `attn_v.weight`, `attn_output.weight` |
| FFN | `ffn_gate.weight`, `ffn_up.weight`, `ffn_down.weight` |
| Projeção MTP | `nextn.eh_proj.weight` |

O manifesto **não contém** `blk.64.nextn.shared_head_head.weight`. No [loader/grafo](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp#L105-L122), o head é opcional; em [`build_graph_mtp`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp#L659-L664), `head_w = layer.nextn.shared_head_head ? layer.nextn.shared_head_head : model.output`.

**Conclusão de inferência:** o LM head do draft deve ser **`model.output` IQ4_XS compartilhado com o target**, se o manifesto representar fielmente os tensores do binário. **Não é prova de inspeção do GGUF**. Ausência do nome em manifesto é evidência forte, mas não garante ausência no índice binário.

### Custo dos pesos (não memória total de inferência)

O GGML armazena `IQ4_XS` em blocos de 256 pesos ocupando 136 bytes. Para `248.320 × 5.120`, o head ocupa teoricamente `675.430.400 bytes ≈ 644,14 MiB`; a operação densa requer aproximadamente `2 × 248.320 × 5.120 = 2,543 GFLOP` por token draft, excluindo softmax, desquantização, truncamento e overhead.

O resumo do Agente 1 informa para **oito Q6_K internos** cerca de **332,23 MiB e 0,849 GFLOP/token**. Não reproduzimos aqui a tabela completa de shapes da qual esses valores foram obtidos; manter como **estimativa recebida**, não como auditoria independente.

Um subconjunto de 98.304 IDs no patch `0013`, quando materializado em `IQ4_XS`, ocupa minimamente **267.386.880 bytes = 255 MiB**, além do head completo e custos auxiliares; o target não deixa de usar `output.weight`. Pré-condições descritas no resumo: caminho compartilhado, `n_outputs==1`, tokenizer BPE, integridade de IDs especiais. **Aplicação condicional, não otimização garantida.**

## 2. MMQ: limite por colunas e helper

O [destino `mmq.cu`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq.cu#L355-L471) confirma suporte declarado aos cinco IQ2/IQ3 e necessidade de >=48 KiB de shared memory por bloco. No ramo RDNA3 WMMA, com MMQ habilitado e `n_experts<64`:

| Formato | 9–128 colunas, se chega a MMQ | >128 colunas, política `should_use_mmq` |
| --- | --- | --- |
| `IQ3_S`, `IQ3_XXS`, `IQ2_XXS` | Elegível | Elegível |
| `IQ2_S`, `IQ2_XS` | Elegível | Não elegível nessa regra |

Para 1–8 colunas, o resumo propõe MMVQ, mas a escolha definitiva depende de outros predicados de dispatch; **não descrever a tabela como trace executado**. Os cinco unpackers MMQ em [`mmq-load-tiles.cuh` da origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/mmq-load-tiles.cuh) utilizam `apply_ksigns`, ao passo que o [destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq-load-tiles.cuh) ainda implementa comparações e subtrações vetoriais; `vecdotq.cuh` sozinho não transforma as funções MMQ.

O manifest `RCO-IQ3_XXS` possui 314 tensores nesses cinco formatos. **Contagem não é custo em bytes/tempo e nem número de launches MMQ**. A origem também pode selecionar MMB antes do MMVQ/MMQ, afetando quais helpers seriam alcançados.

## 3. GDN: invariantes de rollback

A [origem `gated_delta_net.cu`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/gated_delta_net.cu) lê `n_rs_batch` de `op_params[1]` e define `D=max(K>16?K:16,n_rs_batch)`, `K=n_rs_seq+1`. Caso `T>D`, a região de prefixo pode usar os kernels chunked FP32 KKT/scan, deixando **D tokens finais** para o sequencial que grava snapshots. `T<=D` permanece sequencial.

A implementação correta exige integrar **estado GDN matricial e convolução causal**, snapshot pré-batch, `GDN→CPY`, `split_equal`, buffers e ordem de stream. Sem o relatório completo, não declarar verificados todos os casos de múltiplos seq_ids ou de alias.

**Scratch teórico para um prefixo de T tokens** com `CS=64`, `H_v=48`, `H_k=16` e `PACKED_CS=2080`: `ceil(T/64)*64*2080*4` bytes por sequência. Exemplo T=2.048: 16,25 MiB; T=8.192: 65 MiB. **Na integração real, o prefixo pode ser menor que T por causa da cauda D**, portanto esses números caracterizam o custo de processamento de T tokens em chunks, não o pico da operação completa.

O Agente 3 não conseguiu acessar `research/RODADA-04-PLANO.md`; o arquivo **existe** nesta branch, por isso registrar apenas uma limitação de acesso do agente, não de criação da documentação.

## 4. Flash Attention: política do verify

Para `head dimension=256`, `24 Q / 4 KV heads`, razão GQA 6:1, K/V alinhado e máscara válida, os predicados de [`fattn.cu` do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu#L634-L752) apontam:

| K/V | W1–2 | W3–8 | Tipo de caminho para scratch |
| --- | --- | --- | --- |
| `Q8_0` | VEC | TILE | VEC pode ler nativamente; TILE solicita F16 |
| `BF16` | TILE | TILE | TILE solicita F16 no destino |
| `F16` | TILE | TILE | TILE aceita F16; não há conversão nova necessária |

O seletor tem condicionais adicionais de máscara, padding, dimensões e arquitetura; os resultados acima são **deduções estáticas sob hipóteses**, não uma propriedade universal do modelo. O backend pode usar outras rotas quando esses pré-requisitos não se aplicam.

Na origem `stew675` ([`fattn.cu`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn.cu)), o fallback VEC da faixa de verify foi eliminado para uniformizar `TILE` em W1–8. A leitura Q8_0/BF16 nativa é **condicional a compatibilidade de tipo, layout, arquitetura e política de habilitação**, descrita em [`fattn-rdna.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh). A origem compartilha a função de tipo de tile entre seletor do launcher e cálculo do scratch; assim, o port exigiria **ambas as partes, não apenas um flag de alocação**. A banda WMMA de verify especial é **RDNA4**, não gfx1101.

A 32.768 tokens, o KV convencional teórico das 16 camadas corresponde a 1,0625 GiB (`Q8_0`) ou 2 GiB (`F16`). A conversão simultânea K+V F16 **por camada** pode ocupar ~128 MiB de scratch; o tráfego lógico idealizado de ler Q8, escrever F16 e reler F16 através das 16 camadas soma ~5,0625 GiB. Não equivale a um pico de 5 GiB de VRAM.

## 5. Estado da entrega e pendências

| Item | Estado | Limitação |
| --- | --- | --- |
| 4 resumos da Rodada 04 | Recebidos | Não recebemos os `.md` completos anunciados |
| Manifesto do GGUF e 8 Q6_K | Verificado publicamente | Não houve leitura do índice binário GGUF |
| Compartilhamento de LM head IQ4_XS | Dedução forte | Ausência do tensor opcional inferida do manifesto |
| Limiares MMQ para IQ2/IQ3 | Confirmados no seletor | Não foi traçada toda a árvore de despacho |
| Regra GDN K/D e tail | Confirmada na origem | Múltiplas sequências e aliases não auditados end-to-end |
| Fronteira FA W2/W3, scratch TILE | Confirmada sob condições | Não é comportamento observado em runtime |

### Próximas investigações exclusivamente documentais

1. Cruzar o mapa de shapes de `blk.64` para conferir bytes/GFLOPs das oito projeções Q6_K e distinguir alocação total de tráfego por passo do draft.
2. Completar a árvore host `MUL_MAT` -> MMVQ/MMQ/BLAS/MMB e condicionar a seleção a shapes de `rco_types.tsv` sem supor prioridade por contagem.
3. Auditar o grafo GDN com multi-seq/alias e distinguir contextos target/draft no rollback.
4. Congelar o contrato `selector + tile case type + launcher + scratch` de Q8_0/BF16 no RDNA3, incluindo guards arquiteturais e fallback.

Nenhuma tarefa inclui executar o modelo, criar scripts de teste ou pedir logs.

## Aprofundamento posterior: duas propostas de recorte mínimo

Após a consolidação R04, nova leitura das fontes congeladas `e8bd52069ca049cd5213366363451abbb5383865` e `31288c9c66e59377f7788d920678a565bb89dd37` detalhou **dois contratos de portabilidade**:

1. **[MTP subset IQ4_XS](mtp-subset-iq4xs-contrato.md):** `mtp_draft_vocab_get` exige tokenizer BPE com ordenação de merges suficientemente monotônica, preserva IDs `CONTROL|USER_DEFINED` fora do cutoff, compartilha a cópia entre contextos equivalentes e só altera logits quando `mtp_draft`, head compartilhado e `n_outputs==1` coexistem. A validação do tokenizer específico do GGUF continua documentalmente aberta.
2. **[FA TILE nativo](fa-verify-tile-kv-gfx1101.md):** selecionador TILE, instância de Q8_0/BF16, leitura nativa e scratch precisam usar um único predicado de tipo; `bf16_mma_hardware_available(cc)` é verdadeiro em RDNA3 pelo código analisado. Um port restrito ao verify W1..8 pode preservar o prefill antigo em vez de trazer inicialmente a arena da origem. Isso é desenho, não código provado em gfx1101.

Os **dois documentos são propostas de integração futuras, não commits de implementação**.

## Histórico

- 2026-10-25: recebimento de quatro resumos R04, cruzamento com `rco_types.tsv` e código fonte congelado; ganhos numéricos não atribuídos a gfx1101.
