# Modelo-alvo: Swift 1.5 Qwen3.8 27B RCO-IQ3_XXS com MTP

**GGUF:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`
**Repositório:** [ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF)
**Caminho publicado:** `RCO/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`.
**GPU-alvo:** Radeon RX 7800 XT (Navi 32, gfx1101, 16 GiB).
**Fork:** `carlaun12/llama.gfx1101`, pesquisa na branch `deep-research`.

> **Origem dos dados:** ficha pública do autor e [configuração oficial Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/config.json), consultadas em 2026-10-25. O GGUF não está disponível para execução pelos agentes. Formato, metadados e execução devem ser conferidos com o arquivo local antes de afirmar resultados na GPU.

## Identidade e arquitetura

- Checkpoint Swift 1.5 ajustado/abliterado sobre a arquitetura densa Qwen3.8-27B; **não é MoE** e não requer cache de especialistas.
- 64 camadas do backbone: **48 Gated DeltaNet (GDN)** e **16 atenção convencional**; dimensão interna 5120, FFN 17408.
- Atenção convencional com 24 query heads, **4 KV heads**, dimensão por cabeça 256. GDN com 48 value heads e 16 key/query heads, dimensão 128.
- Publicador declara 65 blocos no GGUF: 64 do backbone e **`blk.64`**, a camada extra MTP com 15 tensores, `nextn_predict_layers=1`.
- Head MTP dentro do GGUF, sem arquivo draft separado: `--spec-type draft-mtp` em build compatível com Qwen3.5. A capacidade/ganho MTP desse GGUF exato ainda não foi medida na RX 7800 XT.
- `mmproj-BF16.gguf` de aproximadamente 0,9 GiB é **separado**, necessário para imagem/vídeo e dispensável para texto puro.

## Quantização e distribuição de tensores

**9,7 GiB** é o tamanho do GGUF publicado, não a VRAM final. `RCO-IQ3_XXS` é um **layout misto por tensor** baseado em alocação ISTA-DASLab/UkisAI, mas o publicador afirma quantização normal `llama-quantize`, **sem a etapa de refinamento GSQ**. Não confundir esse arquivo com os pesos GSQ-RCO de UkisAI.

| Tipo por tensor (exceto F32 e similares) | Quantidade publicada |
| --- | ---: |
| IQ3_S | 97 |
| BF16 | 96 |
| IQ3_XXS | 83 |
| IQ2_S | 72 |
| IQ4_XS | 33 |
| IQ2_XS | 32 |
| IQ2_XXS | 30 |
| Q2_K | 28 |
| Q4_K | 19 |
| Q6_K | 8 |
| IQ1_S | 4 |
| IQ1_M | 4 |

As 96 projeções BF16 citadas na ficha são `ssm_alpha` e `ssm_beta`. A alocação atribui Q6_K ao MTP head, mas o tipo efetivo de cada tensor deve ser consultado no `rco_types.tsv` e no header GGUF. **Contagem de tensores não equivale a tempo gasto**: ponderar por shapes, bytes, número de chamadas e despacho realmente selecionado.

**Qualidade reportada pelo publicador, exclusivamente como desvio da própria referência BF16 do modelo:** mean KLD 0,1774; same top-1 86,4% no corpus inglês de avaliação da ficha. Não são métricas de aceleração e não indicam o erro de um kernel frente à implementação baseline usando o **mesmo** GGUF. Uma alternativa maior UD-IQ3_XXS tem 10,2 GiB e mean KLD 0,1353 sob o mesmo protocolo; não substitui o alvo escolhido sem decisão do usuário.

## Ganhos estimados e memória

**Nenhum ganho de desempenho comprovado para gfx1101.** O novo tamanho melhora a viabilidade da residência de pesos em 16 GiB em relação a variantes Q4_K_XL de 16,4 GiB, mas a residência completa e o throughput dependem dos buffers efetivos.

Limite superior **teórico de espaço restante** após armazenar apenas o arquivo: `16 - 9,7 = 6,3 GiB`. A memória livre real é menor devido a GPU/driver, modelo carregado, buffers de runtime, recorrência, snapshots, MTP, alocador e possível projector.

**KV F16 teórico da atenção convencional**, assumindo `n_layer_attn=16`, 4 heads KV, head_dim 256, K e V F16, 1 sequência e contexto totalmente cacheado: `16 * 4 * 256 * 2 (K+V) * 2 bytes = 65.536 bytes/token`, isto é, **64 KiB/token**.

| Tokens efetivamente armazenados | KV F16 teórico |
| ---: | ---: |
| 8.192 | 0,5 GiB |
| 32.768 | 2 GiB |
| 65.536 | 4 GiB |

Esses valores não incluem estados recorrentes GDN, overhead de buffers e eventual KV a mais de outros componentes; não são predições de pico real de VRAM. O uso de KV Q8_0/BF16 também muda o orçamento.

## Priorização específica

1. **Baseline reproduzível:** conferir logs do modelo, offload real, KV, contexto, VRAM e funcionamento de `draft-mtp`; comparar `none` versus `draft-mtp` **antes** de tentar controlador adaptativo.
2. **MMVQ de IQ mistos:** `IQ3_S`, `IQ3_XXS`, `IQ2_S`, `IQ2_XS`, `IQ2_XXS`, `IQ4_XS`; identificar pesos/FFN e dispatch dominante; otimizar com uma mudança por vez e preservar pureza `W=1..8`.
3. **GDN chunked FP32:** atuar no prefill de 48 camadas de recorrência, incluindo `n_rs_batch`, tail sequencial e rollback; BF16/WMMA somente após correção.
4. **MTP adaptativo e head reduzido:** testar apenas depois que aceitação, pureza e disponibilidade de VRAM do head embutido forem conhecidos.
5. **Flash Attention e KV nativo:** dimensionar para 16 camadas de atenção head-256/GQA4, sobretudo em contexto longo; atacar staging apenas se for gargalo.
6. **Fusões e GEMM IQ:** dependem de profiling do prefill e do decode; MMB restrito a Q4_K não deve ser prioridade padrão desse GGUF.
7. **Q4_K VDR4 isolado:** estudo complementar, pois apenas 19 tensores publicados usam Q4_K.
8. **Cache de experts MoE:** fora do escopo para este backbone denso.

## Resultados e descobertas

**Estado:** perfil documental. Não foi feito download/parse completo do GGUF, build ROCm, execução, perfilamento ou medição de A/B na placa do usuário. Nada disso será solicitado para este projeto de pesquisa.

| Data | Build | Contexto | Quant KV | MTP | Offload | Pico VRAM | pp t/s | tg t/s | Erro/pureza |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | Não medido | Não medido | Não medido | Não verificado |

**Método exclusivo da pesquisa:** comparar por leitura das fontes os dispatchers plain/MTP, analisar a aritmética e o contrato de estado, estimar bytes e dependências e classificar fontes publicadas como evidência externa. Não pedir execução, logs, testes, builds ou benchmarks. A KLD da ficha pública compara o GGUF com BF16 e não pode ser usada para inferir erro de um kernel.

## Fontes

- [Ficha de origem, qualidade, alocação RCO e testes de carga](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF)
- [Configuração oficial Qwen/Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/config.json)
- [Proposta MMVQ para quantização IQ mista](mmvq-iq-mistos-rco.md)
- [Proposta GDN chunked](gdn-chunked-gfx1101.md)
- [Proposta MTP adaptativo](mtp-adaptativo.md)

## Histórico

- 2026-10-25: GGUF definido pelo usuário como alvo principal; pesquisa documental inicial. Sem benchmark de gfx1101.
