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

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
