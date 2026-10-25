# MMQ de prefill: unpack IQ2/IQ3 por apply_ksigns (RCO/gfx1101)

> **Estado:** proposta exclusivamente documental, derivada do quarto relatório de agente recebido em 2026-10-25. **Prioridade:** linha de prefill distinta de MMVQ, condicionada ao formato das matrizes e seleção do backend. **Sem implementação ou benchmark.**

**GGUF-alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` (publicador `ajgazin`).
**GPU-alvo:** RX 7800 XT / gfx1101 / RDNA3 (16 GiB).
**Revisões:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca0`.

## Sobre a proposta

O relatório do quarto agente observou que a substituição `__vcmpne4` + `__vsub4` por `apply_ksigns()` **não se restringe ao produto vetorial MMVQ em `vecdotq.cuh`**. Na preparação de tiles do MMQ existe uma família separada de cinco helpers de dequantização em `ggml/src/ggml-cuda/mmq-load-tiles.cuh`.

O destino já inclui `vecdotq.cuh` nesse arquivo, mas os **corpos dos helpers MMQ continuam usando o unpack antigo**. A origem muda explicitamente cada função MMQ IQ2/IQ3 para `apply_ksigns()`, mantendo o restante das operações de preparação de tile.

**Não se trata de novo formato de quantização nem de substituição do dot product AMD.** O objetivo é estudar a redução de etapas inteiras para chegar aos mesmos bytes com sinal dentro dos tiles, somente nas variantes em que a equivalência é demonstrável.

### Correspondência exata dos cinco helpers

| Tipo | Helper no destino | Trecho do destino / origem |
| --- | --- | --- |
| IQ2_XXS | `ggml_cuda_mmq_load_tiles_iq2_xxs` | destino L1118-1170 / origem L1118-1167 |
| IQ2_XS | `ggml_cuda_mmq_load_tiles_iq2_xs` | destino L1182-1235 / origem L1180-1231 |
| IQ2_S | `ggml_cuda_mmq_load_tiles_iq2_s` | destino L1247-1303 / origem L1243-1297 |
| IQ3_XXS | `ggml_cuda_mmq_load_tiles_iq3_xxs` | destino L1315-1368 / origem L1309-1360 |
| IQ3_S | `ggml_cuda_mmq_load_tiles_iq3_s` | destino L1379-1438 / origem L1371-1428 |

As referências de linha ajudam a localizar, mas os commits fixos são a autoridade; futuros merges podem deslocar as funções.

## Ganhos estimados

**Ganho observado em gfx1101: não determinado. Ganho numérico estimável em tokens/s: não determinado.**

Potencial qualitativo **condicional**: diminuir o custo de preparação de operandos IQ para MMQ/GEMM em prefill, caso esses caminhos sejam selecionados e a preparação não esteja inteiramente encoberta pelo tráfego de memória ou pela multiplicação matriz-matriz.

- Os cinco formatos somam **314 tensores** no inventário publicado (97 IQ3_S + 83 IQ3_XXS + 72 IQ2_S + 32 IQ2_XS + 30 IQ2_XXS). Essa contagem indica cobertura de formatos, **não custo relativo em FLOPs/bytes ou frequência de MMQ**.
- Qualquer ganho global obedece ao limite de Amdahl `S=1/((1-f)+f/r)`, onde `f` e `r` são desconhecidos para o workload do usuário.
- A troca pode reduzir instruções inteiras do unpack, mas pode igualmente mudar VGPRs, dependências de dados ou código gerado pelo compilador. **Não atribuir porcentagens de melhoria**.

## Resultados da pesquisa

### Diferença estática reproduzível por leitura

Foram cotejados os arquivos correspondentes em:

- [Destino: `mmq-load-tiles.cuh` no commit 31288c9c66e59377f7788d920678a565bb89dd37](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq-load-tiles.cuh)
- [Origem: `mmq-load-tiles.cuh` no commit e8bd52069ca0](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/mmq-load-tiles.cuh)
- [Origem: implementação de `apply_ksigns()`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh#L134-L137)

Nos cinco helpers, o destino produz máscaras de byte por `__vcmpne4(...)` e em seguida aplica `__vsub4(grid ^ mask, mask)`; a origem passa `grid` e os bits de sinal a `apply_ksigns(grid, signs, 0|4)`, preservando índices das grades e estrutura geral do tile.

**Invariante aritmético:** para cada valor de grade `g` não nulo e sinal `s`, ambos geram `g` se `s=0`, ou `(-g) mod 256` se `s=1`. O novo helper evita carry entre bytes porque as grades têm todos os bytes estritamente positivos. Domínios já verificados em `ggml-common.h`: `IQ3_S=[1,15]`, `IQ3_XXS=[4,62]`, `IQ2_S/IQ2_XS/IQ2_XXS=[8,43]`.

**Limite importante:** o mesmo argumento **não autoriza** aplicar `apply_ksigns()` indiscriminadamente a formatos com zeros ou layout diferente. Índices e deslocamentos dos sinais precisam permanecer específicos do helper.

### Candidato por superfície

| Caminho | Arquivo de operação | Tipo de economia hipotética | Dependência |
| --- | --- | --- | --- |
| MMVQ, decode/verify estreito | `vecdotq.cuh` | Unpack de sinais nos `vec_dot_iq*` | [MMVQ IQ misto](mmvq-iq-mistos-rco.md) |
| MMQ, prefill | `mmq-load-tiles.cuh` | Unpack de sinais nos `ggml_cuda_mmq_load_tiles_iq*` | **Esta proposta**, distinta de MMVQ |
| IQ4_XS | `vecdotq.cuh` / tiles específicos | Multiplicação de escala e lookup já otimizado | Sem `apply_ksigns` nos cinco codebooks |

As duas superfícies compartilham a ideia e o cabeçalho do helper, **mas são funções de execução diferentes**. Alterar os vec-dot não modifica automaticamente os kernels de preparação MMQ.

## Descobertas e observações

1. O destino **já usa `__builtin_amdgcn_sudot4`** em `ggml_cuda_dp4a` em `common.cuh` sob o caminho AMD, de modo que trocar o dot product novamente é trabalho duplicado.
2. A origem modifica exatamente cinco helpers MMQ associados às grades IQ2/IQ3. Não é justificável estender a mudança sem prova aos helpers de Q/K, IQ1 ou IQ4.
3. A diferenciação MMVQ/MMQ impede concluir que uma alteração do unpack vetorial acelera automaticamente prefill.
4. Para o modelo denso selecionado, as políticas de `MUL_MAT_ID` de especialistas MoE não devem guiar a escolha de MMQ/MUL_MAT.
5. Nenhuma observação de compilador, ocupação, ISA efetiva, temperatura, VRAM ou throughput foi coletada.

## Riscos e fallback

- Preservar byte ordering, endianness assumida pelo layout de quatro bytes, índice das grades e o mapeamento `signs -> nibble`.
- Evitar reordenação de escalas, somatórios FP32, acumulação e geometria do MMQ; se a proposta algum dia for implementada, manter fallback ao unpack existente por arquitetura/tipo.
- Uma redução no número de operações de fonte não garante redução de instruções de máquina; o compilador pode gerar outro código ou aumentar VGPRs.
- Esta pesquisa estabelece equivalência local da representação quantizada sob os invariantes descritos, **não equivalência observada do modelo inteiro**.

## Verificação documental

1. Fixar as duas versões do `mmq-load-tiles.cuh` e mapear os cinco diffs função a função.
2. Verificar os limites e códigos das cinco grades em `ggml-common.h`.
3. Comparar o seletor de `MUL_MAT` e a elegibilidade de MMQ por tipo; separar claramente `MUL_MAT_ID`.
4. Estudar se alguma regra específica de `RDNA3_0/gfx1101` restringe a aplicação da expressão de bits, sem extrapolar benchmark de gfx1100.
5. Produzir somente conclusões derivadas de fonte/código e estimativas teóricas. Não solicitar testes locais, compilações ou scripts.

## Próximos passos

- Desenhar, em documento, mudanças mínimas independentes para `IQ3_S`, `IQ3_XXS`, `IQ2_S`, `IQ2_XS` e `IQ2_XXS` nos tiles de MMQ.
- Vincular cada formato aos shapes efetivos no manifesto RCO público e distinguir número de tensores de bytes de pesos, custo de memória e uso no prefill.
- Manter `ggml_cuda_mul_small` e alterações de warps/VDR em documentos/etapas separados: nenhum benefício está demonstrado para gfx1101.

## Referências

- [Relatório do quarto agente, recebido em 2026-10-25](REVISAO-AGENTES-2026-10-25.md)
- [MMVQ IQ misto RCO](mmvq-iq-mistos-rco.md)
- [Destino: MMQ tile unpack](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq-load-tiles.cuh)
- [Origem: MMQ tile unpack](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/mmq-load-tiles.cuh)
- [Origem: sinais e mul24](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh)
- [Destino: instrução AMD `sudot4`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/common.cuh#L712-L719)
- [Inventário público do RCO selecionado](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF)

## Rodada 04 — política RDNA3 por largura da multiplicação (25/10/2026)

O resumo do Agente 2 foi confrontado com [`ggml_cuda_should_use_mmq` no destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmq.cu#L355-L471). O seletor exige tipo quantizado suportado, pelo menos **48 KiB de shared memory por bloco** e condições de arquitetura/shape. Para matrizes **densas** no ramo `amd_wmma_available(cc)` e `GGML_CUDA_CC_IS_RDNA3(cc)`, com `n_experts<64`, a regra específica é:

| Tipo | 1–8 colunas (quando caminho pequeno usa MMVQ) | 9–128 colunas (quando MMQ elegível) | >128 colunas no `should_use_mmq` |
| --- | --- | --- | --- |
| `IQ3_S`, `IQ3_XXS` | MMVQ, sujeito ao seletor de multiplicação | MMQ | MMQ |
| `IQ2_XXS` | MMVQ, sujeito ao seletor | MMQ | MMQ |
| `IQ2_S`, `IQ2_XS` | MMVQ, sujeito ao seletor | MMQ | `false` -> candidato a fallback BLAS |

**Importante:** `should_use_mmq` não é o dispatcher inteiro; o retorno indica **elegibilidade/preferência de MMQ** e não garante que todo tensor/shape vá executar MMQ. Não foi obtido trace de execução e não foi feita comparação com saída do modelo. Para `ne11>128`, em `IQ2_S/XS`, o caminho MMQ é recusado por essa regra sob essas condições, não uma prova de que toda configuração cai em BLAS.

A origem [`mmq-load-tiles.cuh`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/mmq-load-tiles.cuh) substitui `__vcmpne4/__vsub4` por `apply_ksigns()` em cinco helpers; isso está **separado de `vecdotq.cuh`** e dos formatos efetivamente escolhidos por MMB, cuja origem pode interceptar parte da multiplicação antes de MMQ.

A lista de cinco famílias IQ2/IQ3 do manifesto soma 314 tensores, mas não fornece perfil de custo ou comprovante de que 314 operações MMQ sejam feitas. Peso `output.weight` IQ4_XS é outro caminho e deve ser classificado pelo shape.

Ver [consolidação R04](RODADA-04-RESULTADOS.md).

## Histórico

- 2026-10-25: criada proposta documental própria para MMQ após auditoria do quarto agente; confirmação estática dos cinco helpers e correlação com MMVQ. Nenhuma alteração de kernel.
