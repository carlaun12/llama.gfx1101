# MMVQ e MMQ para quantização IQ mista RCO no gfx1101

> **Estado:** investigação estática e dimensionamento pendente por tensor. **Prioridade:** primeira otimização de matvec específica do modelo escolhido. **Escopo:** Qwen3.8-27B Swift 1.5 `RCO-IQ3_XXS`, RX 7800 XT `gfx1101`.

## Sobre a proposta

O GGUF `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` usa uma alocação **mista**, não um formato IQ3_XXS homogêneo. O publicador documenta 97 tensores IQ3_S, 83 IQ3_XXS, 72 IQ2_S, 33 IQ4_XS, 32 IQ2_XS, 30 IQ2_XXS e apenas 19 Q4_K, além de outros formatos. Por isso o port de `Q4_K` VDR4 não deve representar sozinho a campanha de otimização de decode desse modelo.

O destino contém implementação e dispatch dos dot products `vec_dot_iq3_s_q8_1`, `vec_dot_iq3_xxs_q8_1`, `vec_dot_iq2_s_q8_1`, `vec_dot_iq2_xs_q8_1`, `vec_dot_iq2_xxs_q8_1` e `vec_dot_iq4_xs_q8_1`, além de limites RDNA3_0 por quantização.

**Escopo mínimo proposto:** mapear `rco_types.tsv` para grupos de tensores por layer e shape; identificar quais entradas efetivamente acionam MMVQ, MMQ, GEMM ou outro backend para o GGUF no decode e no prefill. Depois selecionar **uma única** especialização IQ para experimento, sem reescrever todos os quantizers e sem misturar configuração de warps com transformação de unpack/permute.

## Ganhos estimados

**Ganho percentual:** indeterminado, sem medição ou perfil do GGUF na RX 7800 XT.

**Potencial qualitativo:** médio/alto se os dot products de IQ dominarem o decode com pesos inteiramente residentes na GPU; menor se o custo dominante for GDN, CPU, transferência ou MTP verify.

**Hipóteses:**
- Reduzir instruções de consulta de tabelas, dequantização e multiplicações inteiras pode beneficiar formatos IQ de alto volume.
- O número de tensores por formato é um indício de presença no workload, **não** do custo: avaliar bytes, shapes, utilização e número de chamadas.
- Mudar `nwarps` deve ser testado separadamente de mudanças no dot product; decode `W=1` e verify `W=2..8` precisam preservar a mesma partição de redução quando a igualdade é exigida.

**Evidência já verificada no repositório:** no destino, `vecdotq.cuh` declara VDR=2 para IQ3_S, IQ3_XXS, IQ2_S, IQ2_XS e IQ2_XXS; VDR=4 para IQ4_XS. As configurações não autorizam prever uma melhoria mudando esses números arbitrariamente.

## Resultados da pesquisa

### Resultado documental 1 - delta exato de vecdotq.cuh (25/10/2026)

Versões comparadas: [destino `vecdotq.cuh` em `31288c9c66e59377f7788d920678a565bb89dd37`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/vecdotq.cuh) e [origem `vecdotq.cuh` em `e8bd52069ca0`](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh). Esta é comparação estática dos corpos dos operadores, não compilação ou medição.

| Operador | Mudança material na origem | Interpretação |
| --- | --- | --- |
| `vec_dot_iq3_s_q8_1` | `__vcmpne4` + `__vsub4` por byte de sinais -> `apply_ksigns`; produto por escala via `ggml_cuda_mul_small` | Candidato forte por simplicidade e presença de 97 tensores IQ3_S |
| `vec_dot_iq3_xxs_q8_1` | Mesma substituição de sinais e multiplicação pequena do acumulador | Candidato forte para 83 tensores IQ3_XXS |
| `vec_dot_iq2_s_q8_1` | Mesmo helper de sinais, 2 produtos por escala com `ggml_cuda_mul_small` | Candidato para 72 tensores |
| `vec_dot_iq2_xs_q8_1` | Mesmo helper de sinais, 2 produtos por escala com `ggml_cuda_mul_small` | Candidato para 32 tensores |
| `vec_dot_iq2_xxs_q8_1` | Mesmo helper de sinais e produto por escala com `ggml_cuda_mul_small` | Candidato para 30 tensores |
| `vec_dot_iq4_xs_q8_1` | O lookup HIP já usa `__builtin_amdgcn_perm` no destino; a diferença concreta do corpo do operador é a multiplicação da escala por `ggml_cuda_mul_small` | Não duplicar trabalho com lookup já presente; estudar somente produto pequeno e dispatch |

**Observação:** o helper `ggml_cuda_mul_small` chama `__mul24(a,b)` sob HIP e `a*b` nas demais plataformas. O cabeçalho do destino não implementa esse helper. O HIP documenta `__mul24` para operandos inteiros **com sinal** de 24 bits; isso demonstra a semântica especificada, mas não comprova throughput ou código de máquina em gfx1101.

### Resultado documental 2 - prova de validade do helper de sinais

O novo `apply_ksigns(grid, signs, shift)` gera uma máscara de 1 bit no bit zero de cada byte selecionado, computa `grid XOR (0xFF por byte selecionado)`, depois soma 1 por byte selecionado:

```c
const uint32_t lsb = (((signs >> shift) & 0x0F) * 0x00204081) & 0x01010101;
return (grid ^ (lsb * 0xFF)) + lsb;
```

Para byte não selecionado, o valor é mantido. Para byte selecionado de valor positivo `g` em `[1,127]`, o byte resultante é `(~g + 1) mod 256 = -g mod 256`; como `g != 0`, a adição não carrega para o byte seguinte. É a mesma representação de byte com sinal do caminho `__vcmpne4/__vsub4`, desde que a ordem dos quatro bits de sinal corresponda ao layout do formato, como nos seletores da origem.

**Domínios extraídos das tabelas de constantes publicadas em [`ggml-common.h` do destino](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-common.h):**

| Grade | Entradas | Menor byte | Maior byte | Zero presente? |
| --- | ---: | ---: | ---: | --- |
| `iq2xxs_grid` | 256 | 8 | 43 | Não |
| `iq2xs_grid` | 512 | 8 | 43 | Não |
| `iq2s_grid` | 1024 | 8 | 43 | Não |
| `iq3xxs_grid` | 256 | 4 | 62 | Não |
| `iq3s_grid` | 512 | 1 | 15 | Não |

A verificação foi feita por **leitura das constantes hexadecimais**, sem executar kernel ou código HIP. O domínio é fundamental: se o helper fosse reaproveitado para outra tabela com zeros, a prova deixaria de valer.

### Resultado documental 3 - limites suficientes para `__mul24`

Para os operadores acima, cada `ggml_cuda_dp4a` processa quatro produtos `int8 x int8`. Um bound conservador é `4 * max_abs_grade * 128` por chamada, usando o limite de módulo 128 para cada valor de `Q8_1`. Cada função considerada efetua oito chamadas por grupo completo, com somas separadas em dois acumuladores em `IQ2_S` e `IQ2_XS`.

| Formato | `max_abs_grade` | Bound de `abs(soma)` completa | Maior fator de escala inteiro | Bound do produto |
| --- | ---: | ---: | ---: | ---: |
| IQ3_S | 15 | 61.440 | 31 | 1.904.640 |
| IQ3_XXS | 62 | 253.952 | 15 | 3.809.280 |
| IQ2_S / IQ2_XS | 43 | 176.128 (dois acumuladores de 88.064) | 15 por acumulador | 1.320.960 por termo |
| IQ2_XXS | 43 | 176.128 | 31 | 5.459.968 |
| IQ4_XS | 127 (da tabela `kvalues_iq4nl`) | 520.192 | `abs(ls-32) <= 32` | 16.646.144 |

Todos os **operandos** de cada `__mul24` proposto estão dentro do intervalo de inteiros assinados de 24 bits (`[-2^23, 2^23-1]`) e os **produtos** cabem em `int32`; não se espera truncamento em comparação com `a*b` nesses casos. Isso sustenta equivalência da multiplicação, **não** identidade total de logits em todos os caminhos, nem ganho do compilador. Os bounds são conservadores e pressupõem os layouts de grade e Q8_1 documentados no código examinado.

**Fonte de semântica:** [HIP Math API - `__mul24`](https://rocmdocs.amd.com/projects/HIP/en/develop/reference/math_api.html).

### Resultado documental 4 - separar os dispatchers

O destino [`mmvq.cu`](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu) contém `get_mmvq_mmid_max_batch_rdna3()`, que limita batch do operador **`MUL_MAT_ID` (especialistas roteados)**, não o matvec denso `MUL_MAT`. Assim, valores como `IQ3_S=4` ou `IQ4_XS=6` nessa função não podem ser usados como prova de seleção de kernel para o modelo Qwen3.8-27B denso.

Em `calc_nwarps()` para `MMVQ_PARAMETERS_RDNA3_0`, os tipos IQ3_S/XXS, IQ2_S/XS/XXS e IQ4_XS caem no retorno padrão de 1 warp; aumentar para 8 indiscriminadamente **não é indicado pela origem**, que explicitamente observa regressões de IQ complexos. Para Q6_K, há regra diferente de 2 warps no destino quando `ncols_dst==1`; na origem há proposta de 8 por banda, mas sem demonstração em gfx1101.

**Conclusão desta rodada:** a primeira proposta de baixo escopo para o GGUF deve ser o **helper de sinais, em cada formato separadamente**, seguido da multiplicação por `__mul24` em casos matematicamente limitados. Não priorizar alteração de VDR, números de warps ou limites `MUL_MAT_ID` no mesmo diff. **Speedup em gfx1101: indeterminado.**


## Descobertas e observações

- O arquivo RCO-IQ3_XXS contém mistura relevante de `IQ3_S`, `IQ3_XXS`, `IQ2_S` e outros; a prioridade Q4_K anterior foi rebaixada para **este checkpoint**, sem invalidar o estudo genérico.
- O destino já tem kernels de IQ, então a questão é otimizar caminhos existentes, não adicionar suporte ausente.
- O head de MTP embutido possui quantização própria (o autor registra alocação Q6_K); distinguir chamadas do target e do drafter.
- `GGML_CUDA_CC_IS_RDNA3_0` cobre a família gfx11 apropriada, mas o alvo concreto é Navi32 gfx1101; não transformar dados medidos em gfx1100 em garantia no gfx1101.
- A origem usa otimizações como `ggml_cuda_mul_small()` para quantizações K/IQ no HIP; a equivalência matemática, a faixa de operandos e efeitos numéricos precisam ser revisados **por função**, não portados indiscriminadamente.

## Riscos, correção e fallback

- `IQ*` frequentemente utiliza tabelas, bits de sinais e subblocos: erro de indexação pode gerar saída plausível, porém incorreta.
- Diferentes reduções FP32 podem mudar logits e tokens escolhidos, particularmente sob MTP.
- Não modificar `IQ3_S` e `IQ3_XXS` simultaneamente, nem aplicar ajustes globais sem guards/fallback.
- Testes sem seleção do kernel otimizado não provam nem correção nem ganho.

## Verificação documental

1. Comparar `ggml_cuda_dp4a`, `__vcmpne4`, `__vsub4` e a nova expressão de bits, incluindo a ordem das assinaturas nos cinco operadores, por inspeção das fontes congeladas.
2. Confirmar o domínio de cada tabela e os bounds dos acumuladores em `ggml-common.h` e `vecdotq.cuh`.
3. Revisar, documentalmente, a expansão de `__mul24` no LLVM AMDGPU e suas possíveis diferenças de custo em RDNA3 sem presumir que a instrução seja mais rápida.
4. Distinguir `MUL_MAT` e `MUL_MAT_ID` e mapear regras host/device da seleção para `gfx1101`.
5. Relacionar metadados públicos de tipos por tensor a suas funções no modelo; se o mapa de shapes não estiver acessível, registrar a lacuna.
6. Não executar/solicitar testes locais, benchmark, compilações ou logs. Critérios práticos históricos estão fora do escopo atual.

## Próximos passos

- Determinar, usando os metadados públicos, quais tensores com IQ3_S/IQ3_XXS são grandes e frequentes e quais são exceções.
- Auditar os seletores de `calc_nwarps`, `get_mmvq_mmid_max_batch_rdna3`, `vec_dot_iq3_*` e `get_vdr_mmvq`.
- Produzir um desenho de alteração mínimo por operador com argumentos de equivalência, guards e riscos, exclusivamente documental.

## Referências

- [Ficha pública, distribuição por tensor e qualidade do alvo](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF)
- [Destino: implementação IQ em vecdotq.cuh](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/vecdotq.cuh)
- [Destino: dispatch MMVQ para IQ](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu)
- [Origem: operações vetoriais quantizadas](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh)

## Histórico

- 2026-10-25: proposta aberta após identificação do GGUF-alvo, somente análise remota.
- 2026-10-25: comparação linha a linha dos seis vec-dot, domínios das cinco grades, prova dos bounds de __mul24 e distinção entre MUL_MAT e MUL_MAT_ID. Sem compilação ou medição.
