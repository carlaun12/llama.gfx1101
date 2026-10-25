# Flash Attention com leitura nativa de KV BF16 e quantizado

> **Estado:** proposta registrada / análise estática. **Prioridade:** 3 - contexto longo e memória. **Bloco(s) de origem:** 0004/0005.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Ajuste ao modelo-alvo RCO-IQ3_XXS

**Prioridade: contexto longo, após baseline e IQ/GDN.** A arquitetura oficial informa 16 camadas de atenção, 4 heads KV e head dimension 256. Em cache K/V F16, a conta teórica por sequência é **64 KiB por token**, ou aproximadamente 0,5 GiB a 8.192 tokens e 2 GiB a 32.768. Esse valor exclui recorrência GDN, MTP e buffers de runtime. A relevância da leitura KV nativa depende do tipo de KV configurado e da frequência do caminho MMA/TILE nesse modelo.


## Sobre a proposta

O destino já implementa Flash Attention VEC, TILE e MMA, mas os relatórios identificaram oportunidades de evitar staging F16 em determinados formatos de K/V, adicionar leitura BF16 nativa e refinar a seleção de kernels RDNA3.

A proposta é particionar o bloco 0005 em mudanças pequenas, começando por um formato realmente usado no GGUF, como Q8_0. O band especializado para RDNA4 não deve ser copiado como otimização padrão de gfx1101.

**Implementação mínima investigada**

1. Confirmar a rota atual de KV F16/BF16/Q8_0 na arquitetura Qwen3.5.
2. Adicionar uma especialização de leitura KV nativa de cada vez, começando por Q8_0 caso o workload use esse cache.
3. Manter VEC/TILE/MMA e conversão F16 atuais como fallback.
4. Tratar WMMA head-512 e máscara derivada como subprojetos independentes.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Médio/alto em contexto longo com KV quantizado e forte participação de atenção; baixo em contexto curto ou com GDN predominante.

**Hipótese de ganho:** Reduzir conversões/staging pode economizar trabalho e memória temporária. A quantização do KV também reduz armazenamento: Q8_0 usa 1,0625 byte/elemento, 46,875% menos que F16; Q4_0 usa 0,5625, 71,875% menos. Essas porcentagens descrevem o formato de armazenamento, não o ganho incremental de velocidade da leitura nativa.

**Condições que podem anular o benefício:** Custos de dequantização, divergência de máscara, aumento de variantes compiladas, indisponibilidade de memória e geometria WMMA inadequada para head/shape.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Resultados da pesquisa — relatório Flash Attention (25/10/2026)

**Diferença material em código:** no [`fattn.cu` do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu) o cálculo de scratch define `need_f16_K=true` e `need_f16_V=true` para os caminhos `TILE` e `MMA_F16`; `VEC` condiciona staging ao tipo/fallback. A origem adiciona leitores KV nativos e despacho especializado para RDNA, mas **não basta trocar o alocador**: seletor, kernel e reserva devem concordar.

**Geometria do alvo:** 16 camadas com atenção convencional, 24 query heads, 4 KV heads e `D=256`: razão GQA **6:1**. Teoricamente `16*4*256*2*(34/32)=34.816 bytes/token` para K e V Q8_0, e **65.536 bytes/token** em F16/BF16. Em 32.768 tokens: Q8_0 **1,0625 GiB** e F16 **2 GiB**.

**Custo hipotético de staging por passagem de 32K:** ler Q8_0 (1,0625 GiB) + escrever F16 (2 GiB) + reler F16 (2 GiB) = **5,0625 GiB de tráfego lógico**, versus pelo menos **1,0625 GiB** de leitura Q8_0 nativa na mesma hipótese. Trata-se de soma de operações de leitura/escrita, não pico de scratch. Uma conversão de K+V F16 de **uma única camada** consome aproximadamente **128 MiB** em 32K, se executada integralmente e sem reuso adicional; alocações podem ser reutilizadas entre camadas.

**Dispatcher:** o relatório sugere `VEC` em decode estreito Q8_0 e transição para `TILE` em verify largo. É uma leitura condicional do seletor, **não uma observação em gfx1101**. Também não afirmar que Q8_0 será escolhido pelo usuário; ele é uma configuração de KV hipotética independente da quantização dos pesos `RCO-IQ3_XXS`.

**Correção de escopo:** o relatório compara pesos de variantes `IQ3_XXS` com **12,32 GB** em algumas tabelas; o arquivo definido para a pesquisa é o **RCO-IQ3_XXS de 9,7 GiB**. Não usar aquelas taxas ideais de streaming de pesos como valores do alvo. Evidências de Qwen3.5-9B em RX 7900 XTX (`gfx1100`) são **referências externas**, não estimativas percentuais válidas para `gfx1101`.

**Pontos de leitura posteriores:** alocador e launcher FA Q8_0/BF16, seleção do kernel, guard de head-256 e contrato de K/V nativos no verify, sem coletar logs ou benchmarks.

**Revisão cruzada:** [REVISAO-AGENTES-2026-10-25.md](REVISAO-AGENTES-2026-10-25.md).

## Descobertas e observações

- O Qwen3.8-27B auditado utiliza atenção convencional em 16 das 64 camadas; as demais são recorrentes.
- Há histórico de regressão com WMMA head-512 em gfx1100, e exceções posteriores ajustadas para alguns workloads; nenhuma delas foi medida em gfx1101.
- As políticas de decode e verify podem usar ordens de redução distintas quando o dispatcher troca VEC por TILE.
- O histórico da origem revelou falso PASS de testes `W=1..8` com prefixo de 256 tokens: em certos caminhos o kernel relevante só é atingido com contexto usado >= 4096.
- A máscara derivada altera interface de grafo/allocator, portanto não cabe no primeiro patch.


### Segunda rodada - diferença de alocação e critérios de pureza (25/10/2026)

**Diferença funcional verificada:** no destino, `ggml_cuda_flash_attn_ext_get_alloc_size()` marca `need_f16_K = need_f16_V = true` para os caminhos `BEST_FATTN_KERNEL_TILE` e `BEST_FATTN_KERNEL_MMA_F16`. A origem calcula o tipo efetivamente escolhido pelo TILE e, para MMA, consulta `ggml_cuda_fattn_kv_native_type()` individualmente para K e V. Portanto, portar somente o reader é perigoso: **launcher e estimativa de scratch precisam concordar** sobre quais tensores terão staging.

**Experimento mínimo sugerido:** escolher uma configuração comprovadamente usada pela arquitetura alvo com K/V Q8_0, preservar todos os controles não elegíveis e revisar a função de alocação, o lançamento e a especialização de kernel juntos. A sequência BF16 TILE é um experimento separado. A máscara derivada não entra no primeiro corte porque altera interfaces de grafo/allocator.

**Defeito histórico que deve orientar testes:** no registro de 25/10/2026, o caminho de FA band RDNA4 com um bloco de 64 colunas fazia W=5..8 usar outra partição de redução e alterava o texto greedy. O probe com prefixo real P=256 dava PASS porque não atingia a condição de KV utilizado >=4096. Com P=4096, o kernel defeituoso teve maxdiff de logits 0,199764 em KV Q8_0; a variante corrigida testada na origem teve maxdiff 0. A causa demonstrada é **RDNA4** e não deve ser atribuída a um defeito já existente de gfx1101.

**Condição da verificação:** para qualquer caminho capaz de mudar a família de kernel entre decode e verify, instrumentar o dispatch e testar W=1..8 em prefixos P=256, P=4096 e profundidades maiores. Não aceitar um PASS se o ramo sob análise não foi executado.

**Evidências:**
- [Destino: cálculo de need_f16_K/V](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu)
- [Origem: cálculo de scratch KV nativo](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/fattn.cu)
- [Origem: diagnóstico de pureza W=5..8](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/benchmarks/2026-10-25-fa-band-width-purity.md)

## Riscos, correção e fallback

- Leitura de linhas mascaradas, sinal de zero BF16, offsets de K/V, divergência entre decode W=1 e verify W=2..8.
- Aumentar especializações implica tempo de compilação e tamanho do binário.
- Preservar a política de seleção original para dtypes e heads não validados.

## Plano de validação

- `test-backend-ops -o FLASH_ATTN_EXT` para o dtype selecionado, incluindo máscara parcial/total, head 256 e GQA real.
- Comparar cache F16, BF16 e Q8_0 sem atribuir benefícios de economia de armazenamento ao kernel em si.
- `W=1..8`, prefixo >=4096 e profundidades maiores, com comparação de logits e hash quando o contrato exigir.
- A/B por contexto (8K, 32K e longo contexto apenas se couber), separando pp/tg e VRAM de pico.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Fechar diff dos caminhos `need_f16_K/V` e escolha TILE/MMA.
2. Prototipar um único par K/V.
3. Revisar guards de máscara e numéricos.
4. Isolar eventual teste WMMA head-512.

## Referências

- [Destino: fattn.cu](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu)
- [Origem: fattn-rdna.cuh](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh)
- [Origem: bloco FA e dependências](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)
- [Origem: regressões de largura de verify](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/benchmarks/2026-10-25-fa-band-width-purity.md)

## Rodada 04 — fronteira W2/W3 e K/V nativo (25/10/2026)

Verificado nos commits congelados: o [seletor do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu#L634-L752), para `head-256`, máscara válida, KV alinhado, `GQA=24/4=6` e `W=Q->ne[1]` no regime decode/verify, tende a:

| K/V | W=1–2 | W=3–8 | Scratch/conversão |
| --- | --- | --- | --- |
| `Q8_0` | `VEC` | `TILE` | `VEC` tem suporte direto ao tipo; `TILE` solicita F16 para K/V |
| `BF16` | `TILE` | `TILE` | `TILE` solicita F16 para K/V |
| `F16` | `TILE` | `TILE` | kernel usa entrada F16; não confundir `need_f16=true` com nova conversão se tipo já F16 |

**Condições:** o mapeamento pressupõe predicados de máscara/layout do seletor, GQA apropriado e caminho AMD usual; não é trace nem descrição universal. No código original, a regra `VEC` para Q8_0 `Q->ne[1]<=2` está no ramo sem tensor cores, enquanto `MMA_F16` depende da arquitetura e batch efetivo. Em gfx1101, W<=8 não cruza o limiar WMMA típico do head-256, sob essas condições.

Na [origem RDNA Boosts](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn.cu), o fallback `VEC` da faixa decode/verify foi removido para que W=1..8 use `TILE` de maneira uniforme; isso evita mudança de família de redução ao cruzar W=2/3. [`fattn-rdna.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh) define seletores de leitura de Q8_0/BF16 nativos **condicionados a tipo, stride, suporte da arquitetura e política de ativação**. O tipo consumido pelo launcher é compartilhado com a regra de alocação `ggml_cuda_fattn_tile_type(K,V,cc)`, de modo que scratch e kernel façam escolhas consistentes.

**Não generalizar:** a banda WMMA especial de verify descrita na origem é RDNA4-gated; não atribuir essa variante ao gfx1101. A origem observa regressões/pureza em outros GPUs; não prova divergência real nem speedup no modelo RCO nesta placa.

**Orçamento teórico em 32K tokens:** Q8_0 K/V **1,0625 GiB**, F16 K/V **2 GiB** (16 camadas convencionais), staging de um nó/layer para F16 **128 MiB** se K e V completos forem materializados. Soma lógica de leitura Q8_0, escrita F16 e leitura F16 das 16 camadas: **5,0625 GiB** idealizados. Tráfego não equivale ao pico simultâneo do alocador.

Ver [resultados R04](RODADA-04-RESULTADOS.md).

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
