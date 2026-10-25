# Speculative MTP de profundidade adaptativa

> **Estado:** proposta registrada / análise estática. **Prioridade:** 6 - depende de baseline correto de decode/verify. **Bloco(s) de origem:** 0002.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Ajuste ao modelo-alvo RCO-IQ3_XXS

**Prioridade: alta como baseline de geração, mas controlador adaptativo somente após pureza.** O publicador declara um head MTP embutido em `blk.64` com 15 tensores e `nextn_predict_layers=1`; não requer arquivo de draft à parte. O primeiro ensaio deve ser `--spec-type none` versus `--spec-type draft-mtp`, com **o mesmo** GGUF, antes de adaptar profundidade. O publicador **não mediu taxa de aceitação MTP** para essa variante. Um ganho de throughput não pode ser presumido a partir da simples existência do head.


## Sobre a proposta

O destino já possui `draft-mtp` para a família Qwen3.5. A origem acrescenta controle dinâmico de profundidade e políticas relacionadas ao estado recorrente.

Objetivo: otimizar tokens de saída efetivamente confirmados, não apenas a velocidade do draft ou a taxa de propostas geradas.

**Implementação mínima investigada**

1. Documentar a lógica atual de `draft-mtp` e limites `n_max`.
2. Desenhar um controlador que adapte a profundidade usando aceitação e custo de verificação, com limites conservadores.
3. Preservar rollback e a escolha do kernel de GDN/FA em W=1..8.
4. Deixar profundidade fixa disponível como comparação e fallback.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Condicional: pode ser expressivo se draft barato e aceitação alta; pode ser negativo se verify caro ou memória escassa.

**Hipótese de ganho:** Ajustar quantidade de tokens propostos ao regime efetivo de aceitação pode evitar verificações inúteis e aumentar tokens confirmados por segundo.

**Condições que podem anular o benefício:** Baixa aceitação, largura de verify que aciona outro kernel, custos de contexto MTP e snapshots em 16 GiB e divergência numérica entre W=1 e W=2..8.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Resultado adicional de pesquisa: Q6_K e a largura MTP (25/10/2026)

O publicador aloca os **oito tensores Q6_K** no head MTP do `blk.64`. Ao contrário da quantização IQ das matrizes principais, esse caminho exige inspeção separada: o destino [`mmvq.cu`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu) escolhe **2 warps para Q6_K com `ncols_dst == 1` e 1 warp para outras larguras** na política RDNA3_0. A [origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/mmvq-rdna.cuh) propõe uma configuração diferente para a banda de decode/verify.

**Limite:** a diferença de warps é um fato de código, não demonstra divergência de logits ou uso obrigatório do caminho MMVQ em todas as fases do MTP. Nem toda operação `Q6_K` é decode e as larguras escolhidas pelo dispatcher precisam ser entendidas por leitura do grafo. Priorizar mapeamento de dispatch, contrato de estado e estimativas de custo, nunca testes locais.

## Resultados da pesquisa — relatório MTP (25/10/2026)

O alvo inclui **64 camadas principais** (`blk.0`–`blk.63`) e uma adicional **`blk.64`** de MTP. O [grafo `qwen35.cpp` do fork](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp) exige `n_layer_nextn==1`, reaplica a mesma cabeça MTP autoregressivamente e seleciona **`nextn.shared_head_head` quando disponível, senão `model.output`**. O draft possui contexto/cache próprios; o target retém o estado GDN para rollback.

**Custo de estado teórico por plano e por sequência:** `48 camadas * 48 value-heads * 128 * 128 * 4 bytes = 144 MiB` em matriz GDN FP32, mais `48*(2*16*128+48*128)*(4-1)*4 = 5,625 MiB` em estado de conv1d, total **149,625 MiB por plano**. O [alocador recorrente](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/llama-memory-recurrent.cpp) dimensiona `n_rows=mem_size*(1+n_rs_seq)`, implicando, sob a hipótese `n_rs_seq=n_max`:

| Profundidade máxima | Planos | Estado teórico |
| --- | ---: | ---: |
| Sem MTP (`n_max=0`) | 1 | 149,625 MiB |
| `n_max=3` | 4 | 598,5 MiB |
| `n_max=7` | 8 | 1.197 MiB |
| `n_max=15` | 16 | 2.394 MiB |

O controlador adaptativo ajusta os **passos efetivos**, mas não reduz automaticamente o número de planos reservado por `n_max`. Isto é resultado da análise de estruturas e fórmula, não observação de VRAM.

**Modelo analítico de utilidade:** para profundidade `d`, `E[A_d]=1+sum_{j=1..d}P(j` primeiros tokens aceitos`)`; draft é vantajoso quando `(T_draft(d)+T_verify(d+1)+T_overhead)/E[A_d] < T_decode`. Sem distribuição de aceitação do GGUF escolhido e custos efetivos, não projetar speedup.

**Correção crítica de atribuição:** o relatório compara variantes Q6_K de **outros GGUFs** e um cenário hipotético de `output.weight` Q6_K com 994,6 MiB. No **RCO-IQ3_XXS especificado**, `output.weight` é **IQ4_XS** e existem oito tensores Q6_K no bloco MTP; esses fatos não autorizam afirmar que o LM head selecionado pelo draft é Q6_K. A quantização real do head depende da presença de `nextn.shared_head_head` ou do fallback `model.output`, conforme o loader.

**Análise de Q6_K:** no destino, `VDR_Q6_K_Q8_1_MMVQ=2`, a política `RDNA3_0` usa 2 warps para `W=1` e 1 para outras larguras; `get_mmvq_mmid_max_batch_rdna3()` é de `MUL_MAT_ID`, não do matvec denso. São diferenças de política, sem prova de ganho ou divergência de logits.

**Próximo trabalho exclusivamente documental:** derivar a tabela de quais matrizes `blk.64` estão em Q6_K, qual LM head é escolhido e o custo dos estados e de cada proposta em função de `n_max`. Os números públicos do agente sobre R9700/32 GiB, outra quantização e versão anterior de Swift são **evidências externas**, não benchmarks do alvo.

**Revisão cruzada:** [REVISAO-AGENTES-2026-10-25.md](REVISAO-AGENTES-2026-10-25.md).

## Descobertas e observações

- O destino implementa MTP básico; não é necessário recriar `qwen35` ou o grafo de draft.
- A origem define preocupação explícita com pureza de largura e rollback recorrente.
- A otimização deve medir taxa de aceitação e throughput confirmado; throughput bruto de draft não basta.
- O limite de profundidade exato requer inspeção do checkpoint e das flags disponíveis.


### Segunda rodada - evidência arquitetural e escopo de controlador (25/10/2026)

**Suporte confirmado no destino:** `common/speculative.cpp` registra `draft-mtp`, implementa a criação de contexto `LLAMA_CONTEXT_TYPE_MTP` e possui um driver MTP com estado por sequência. Esse é o ponto de partida; não portar novamente o suporte à arquitetura Qwen3.5.

**Dependência de correção:** o uso de MTP exige que as larguras de verify não acionem caminhos divergentes de GDN/MMVQ/FA sem validação. O GDN da origem transmite `n_rs_batch` justamente para evitar que um verify batch seja atendido pelo chunked sem snapshots. O controlador adaptativo é posterior ao fechamento desse contrato.

**Métrica primária:** tokens **confirmados** por segundo em relação a `--spec-type none` e MTP fixo, junto com aceitação, VRAM, latência e invariância numérica. Taxa de draft e número bruto de propostas não medem ganho de usuário.

**Protocolo remoto:** registrar primeiro os pontos de controle do driver e flags de profundidade, depois desenhar um controlador com kill-switch. Não afirmar ganho na RX 7800 XT antes de execução com checkpoint real.

**Evidências:**
- [Destino: common/speculative.cpp](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/common/speculative.cpp)
- [Origem: pureza do speculative decode](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/GREEDY-PURITY.md)

## Riscos, correção e fallback

- Alterar texto final por divergência entre decode e verify, alocação excessiva de snapshots ou controller instável.
- O caminho sem especulação deve permanecer disponível e reproduzível.
- Evitar misturar mudança de controlador com novas variantes BF16/WMMA.

## Plano de validação

- Comparar `--spec-type none` com MTP fixo e MTP adaptativo no mesmo GGUF.
- Validar `W=1..8` com contexto >=4096, KLD e rollback por sequência.
- Registrar propostas, aceitação, verificações, tokens confirmados/s, VRAM e latência.
- Separar ensaios com prompting curto de contexto já preenchido.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Inventariar métricas de custo e aceitação da origem.
2. Determinar invariantes da profundidade e do estado recorrente.
3. Definir algoritmo adaptativo reversível e telemetria.
4. Implementar somente após o baseline de pureza.

## Referências

- [Destino: speculative.cpp](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/common/speculative.cpp)
- [Origem: metodologia de pureza](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/GREEDY-PURITY.md)
- [Origem: blocos](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
