# Flash Attention verify no gfx1101: leitura nativa Q8_0/BF16 sem staging F16

> **Estado:** auditoria documental de seletores, launcher, tile case e scratch em 2026-10-25. Proposta de port **mínimo e restrito à faixa W=1..8**, não implementação. Ganhos quantitativos desconhecidos.

**GGUF:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`; **GPU:** RX 7800 XT gfx1101, 16 GiB.
**Destino fixo:** `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; **origem fixa:** `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

## Sobre a proposta

O modelo tem 16 camadas de atenção convencional, 24 heads Q, quatro heads KV e dimensões K/V 256 (**GQA=6:1**). A quantização `RCO-IQ3_XXS` descreve **pesos**; o formato de KV (`F16`, `BF16` ou `Q8_0`) é uma configuração independente e **não foi informado pelo usuário**.

O [seletor de FA do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu#L634-L752) pode mudar de `VEC` para `TILE` entre `W=2` e `W=3` com KV `Q8_0`. Quando seleciona `TILE`, o [alocador](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu#L721-L752) define `need_f16_K/V=true`. O backend da origem remove essa fronteira de família na faixa W1..8 e contém caminhos nativos de Q8_0 e BF16 com launcher e alocador em acordo.

**Benefício alvo:** evitar conversão global para F16 por passo de verify quando os predicados de leitura nativa são satisfeitos, e reduzir diferenças de família de redução entre decode e verify. Isso **não prova** aceitação MTP idêntica nem throughput superior.

## Ganhos estimados — somente limites teóricos

Memória KV em 32K tokens, 16 camadas, quatro KV heads, `D=256`:

- F16: `16*32768*4*256*2*2 = 2 GiB`;
- Q8_0: blocos de 32 em 34 bytes -> `1,0625 GiB`;
- conversão F16 K+V de **uma camada** de 32K: `128 MiB`, supondo materialização completa;
- volume lógico idealizado por passagem com Q8_0->F16: leitura 1,0625 GiB + escrita F16 2 GiB + leitura F16 2 GiB = **5,0625 GiB**, antes de reuso/caches e demais operações. É **tráfego lógico agregado**, não scratch simultâneo.

As somas anteriores servem para mostrar ordem de grandeza, não para prever latency ou speedup. Com K e V em F16, marcar necessidade de entrada F16 **não** cria uma conversão adicional.

## Resultados da pesquisa: política do seletor

O código do destino, com `K->ne[1]` alinhado à constante `FATTN_KQ_STRIDE`, máscara válida, `max_bias=0`, Q/K/V shapes admitidos e `W=Q->ne[1]`, possui a seguinte política **condicional** em gfx1101 (sem outros guards que forcem `NONE`):

| KV homogêneo | W1–2 | W3–8 | Justificativa |
| --- | --- | --- | --- |
| `Q8_0` | `VEC` | `TILE` | `VEC` para quantizado com `W<=2`, senão tile |
| `BF16` | `TILE` | `TILE` | GQA ativo impede ramo vector para não-quantizado |
| `F16` | `TILE` | `TILE` | Idêntica família a BF16 no destino |

A origem remove o fallback VEC em W<=8 no seletor e faz a faixa ir para TILE, **desde que nenhuma outra seleção com maior prioridade entre**. A banda WMMA específica de verify no topo do seletor é limitada a **RDNA4**: não transportar o suposto ganho RDNA4 a gfx1101.

## Resultados: contrato nativo de TILE na origem

### Predicados Q8_0

Em [`fattn-rdna.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh#L53-L111), `ggml_cuda_fattn_kv_native_supported(t)` exige:

1. `FAST_FP16_AVAILABLE` definido;
2. política `GGML_CUDA_FA_KV_NATIVE` diferente de zero (modo padrão `auto=-1`, ativado);
3. tensor não nulo com tipo `Q8_0`;
4. `t->ne[0]` múltiplo de 8;
5. `t->nb[0] == ggml_type_size(GGML_TYPE_Q8_0)` (blocos contíguos).

O kernel **TILE** tem um único parâmetro de tipo K/V; ambos precisam qualificar para o **mesmo formato nativo**. A função `ggml_cuda_fattn_tile_kv_native_type(K,V)` recusa pares mistos. Em gfx1101, head-256 e blocos Q8_0 contíguos satisfazem as condições de shape (o layout concreto ainda depende de stride). Não generalizar a qualquer view de K/V.

### Predicado BF16 — detalhe gfx1101

A [`ggml_cuda_fattn_tile_type(K,V,cc)`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh#L301-L311) retorna **`GGML_TYPE_BF16` diretamente** quando K e V são BF16 e `bf16_mma_hardware_available(cc)` é verdadeiro. [`common.cuh` do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/common.cuh#L339-L343) define esse predicado como verdadeiro para a família RDNA3. Logo, **para esse par homogêneo e com tile BF16 disponível, gfx1101 não precisa de conversão global F16**, mesmo que os comentários históricos mencionem um braço BF16 opcional. Se o predicado não valer em outro hardware, a função pode cair em `F16` com staging.

A [instanciação TILE da origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-tile.cu#L5-L51) possui caso `GGML_TYPE_BF16` explícito, além de Q8_0 e outros formatos quantizados. Portanto, **native BF16** pode significar leitura BF16 direta pelo tile (sem F16 interposto), enquanto uma instância MMA pode converter valores individualmente ao gerar tiles. Não fundir mecanicamente as duas implementações.

### Seletor, launcher e alocador precisam coincidir

A origem usa o mesmo `ggml_cuda_fattn_tile_type` em **`fattn-tile.cu` (instanciação)** e em **`ggml_cuda_flash_attn_ext_get_alloc_size` (scratch)**. No caso TILE, o alocador faz `need_f16_K=(K->type != tile_type)` e equivalente para V; a decisão seleciona o kernel que realmente consome a representação nativa. Alterar apenas o tamanho do scratch antes de acrescentar o kernel correspondente criaria escrita não alocada ou interpretação de bits incorreta.

| Caso TILE na origem | Instância do kernel | Staging global |
| --- | --- | --- |
| K=V=Q8_0, elegível | Q8_0 | Nenhum F16 para K/V |
| K=V=BF16, RDNA3 e elegível | BF16 | Nenhum F16 para K/V |
| K=V=F16 | F16 | Nenhum F16 adicional |
| K=Q8_0, V=F16 | F16 (um único tipo TILE) | Converter K; V já F16 |
| K=Q8_0, V=BF16 | F16, na ausência de tipo compartilhado | Converter K e V |

A origem oferece `GGML_CUDA_FA_KV_NATIVE=0` como controle do caminho nativo quantizado; o caso BF16 puro no TILE depende antes do suporte BF16 de hardware. Diferenciar esse predicado de um override ambiental global.

### Por que um port de W<=8 pode ser menor do que a origem completa

O [`launch_fattn` da origem](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-common.cuh#L1580-L1695) possui ainda política de **prefill**: para >8 linhas e em RDNA3_0, pode preferir converter KV quantizado para scratch F16 numa arena temporária, porque reutilizar tiles em prefill muda a economia do kernel. Essa arena controla buffers reutilizáveis, limitação de capacidade e fallback se faltarem recursos.

**Proposta mínima DOCUMENTAL:** restringir a nova seleção de tipo TILE e leitura KV nativa **à banda W1..8**, preservar o caminho atual para prefill >8 e seus buffers existentes. Isso evita importar de início a arena/otimizações RDNA4, mas ainda exige harmonizar seleção do kernel, fallback para tipos mistos, alocador de scratch, `fattn-tile.cu` e `fattn-common.cuh`/loaders específicos. A compatibilidade das interfaces do destino com esse recorte permanece por demonstrar. Não sugerir simplesmente copiar o `fattn-rdna.cuh` completo.

## Riscos, correção e fallback

1. **Pureza de verify:** mudar W1/2 de VEC para TILE pode alterar a ordem de softmax/redução; maior uniformidade por família não é prova de igualdade bit a bit do target em todas as larguras ou contexto longo.
2. **Q8_0 nativo:** dequantização inline precisa reproduzir o arredondamento F16 que o staging anterior aplicava. A origem afirma equivalência de arredondamento para seus chunks; o recorte deve preservar a mesma regra de carga e conversão.
3. **BF16 nativo:** ler BF16 sem converter para F16 antes da aritmética pode produzir resultados diferentes dos do destino que usava staging F16. Distinguir semântica matemática, modo do kernel e igualdade bit a bit.
4. **Pares K/V de tipos diferentes:** o TILE só usa um `type_KV`; qualquer mistura deve cair no kernel F16 e reservar scratch correto por operando.
5. **Layouts de view e strides:** head-256 sozinho não garante que `nb[0]`, `mask`, `K->ne[1]` e `V->ne[1]` obedeçam aos guards.
6. **Otimizações RDNA4:** banda WMMA exclusiva de RDNA4 e tunings de gfx1201 **não** são recomendação para gfx1101.

## Verificação documental

- Ler conjuntamente `ggml_cuda_get_best_fattn_kernel`, `fattn-tile.cu`, `launch_fattn`, `ggml_cuda_flash_attn_ext_get_alloc_size` e `ggml_cuda_fattn_tile_type`.
- Desenhar diffs mínimos por função e tipo nativo de KV; manter fallback F16 antigo para demais cenários.
- Conferir `FAST_FP16_AVAILABLE`, `bf16_mma_hardware_available`, formas do KV e limites `W`.
- Não atribuir ganhos observados ou afirmar que o usuário usa KV Q8_0/BF16 sem confirmação; não pedir logs, executar scripts ou compilar.

## Próximos passos

1. Produzir matriz exata de includes, instâncias de `fattn-tile.cuh`, dequant Q8_0 e regras de scratch, sem código executável.
2. Examinar a correspondência entre rounding inline Q8_0 e `dequantize_block_q8_0_f16` do staging no domínio de escala F16.
3. Cruzar o custo de KV e a memória extra de subset MTP com o teto de 16 GiB em contexto longo.
4. Tratar prefill >8 e arena como **proposta independente**, somente se o caminho mínimo preservar todos os invariantes.

## Referências

- [FA do destino e scratch](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/fattn.cu#L634-L752)
- [Origem: seletor RDNA](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn.cu)
- [Origem: tipos nativos e condições](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-rdna.cuh)
- [Origem: tile case](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-tile.cu)
- [Origem: launcher e prefill staging](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/fattn-common.cuh#L1580-L1698)
- [Destino: característica BF16 RDNA3](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/common.cuh#L339-L343)

## Revisão dos agentes R05 — equivalência Q8_0 e contrato TILE (25/10/2026)

**Agente 3:** apresentou uma prova **condicionada** de equivalência por elemento entre o staging `dequantize_block_q8_0_f16` e a rotina nativa `ggml_cuda_fattn_dequantize_q8_0_chunk`. Ambos usam escala FP16 e int8 com multiplicação FP16; o produto exato cabe em FP32, o que permite raciocinar sobre arredondamento único RNE. A conclusão exige semântica consistente de FP16, **sem FTZ/denormals divergentes**, e não cobre identidade de ISA, subfluxos especiais, ordem da redução, softmax nem logits do MTP. A prova completa foi anunciada, mas o arquivo `RELATORIO-R05-Q8-ROUNDING.md` não foi disponibilizado aqui.

**Agente 4:** recomendou apenas a faixa **W1..8**, `TILE` com KV Q8_0/BF16 nativos no gfx1101, reaproveitando o prefill atual. Os componentes do contrato devem permanecer sincronizados: `selector`, predicados do tipo nativo, `fattn-tile.cu/.cuh`, `launch_fattn`, alocador `get_alloc_size` e fallback F16 por forma/tipo/layout. Não carregar banda WMMA RDNA4 nem arena de prefill longo para esse recorte.

**Risco numérico BF16 independente:** nativo BF16 pode diferir do caminho que faz conversão BF16->F16 antes de KQ/PV; **não aplicar a prova do Q8_0 automaticamente a BF16**. A escolha de famílias distintas de FA pode igualmente reordenar reduções, mesmo se K/V individualmente coincidirem.

**Estado:** proposta documental definida, sem implementação nem velocidade medida. Pendentes os limites da prova FP16, a semântica BF16 e revisão final de fallback/scratch. Detalhes em [RODADA-05-RESULTADOS.md](RODADA-05-RESULTADOS.md).

## Histórico

- 2026-10-25: pesquisa aprofundada das condições nativas Q8_0 e BF16 e desenho documental de port W1..8, sem modificar código.
