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

## Resultados

Nenhum kernel foi recompilado ou medido em gfx1101. Nenhum número de ganho será preenchido até receber medições reais.

| Data | Tipo IQ | Tensor/shape | Dispatch A/B | W/contexto | latência A | latência B | Ganho observado | Log e pureza |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificado |

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

## Plano de validação

1. Reunir o manifesto de tipos por tensor publicado (`rco_types.tsv`) e relacioná-lo com as chamadas reais, sem afirmar que os arquivos remotos foram executados.
2. Revisar diferenças semânticas origem/destino em `vecdotq.cuh`, `mmvq.cu` e tabelas de `mmq` por tipo.
3. Propor um par A/B com mesmo GGUF, compilação HIP `gfx1101`, `test-backend-ops -o MUL_MAT`, teste de operadores de quantização selecionados, pp/tg e perfil de kernels.
4. Confirmar `W=1..8` e prefixo P>=4096 quando dispatch de verify/mul_mat puder mudar; comparar logits do mesmo GGUF.
5. Coletar tokens confirmados/s com MTP e sem MTP; comparar intercaladamente, com A/A para estimar ruído.
6. A coleta local depende do usuário. Nenhum agente assume acesso remoto à GPU.

## Próximos passos

- Determinar, usando os metadados públicos, quais tensores com IQ3_S/IQ3_XXS são grandes e frequentes e quais são exceções.
- Auditar os seletores de `calc_nwarps`, `get_mmvq_mmid_max_batch_rdna3`, `vec_dot_iq3_*` e `get_vdr_mmvq`.
- Propor uma única alteração de baixo risco e os testes de aceitação para discussão antes de implementar.

## Referências

- [Ficha pública, distribuição por tensor e qualidade do alvo](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF)
- [Destino: implementação IQ em vecdotq.cuh](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/vecdotq.cuh)
- [Destino: dispatch MMVQ para IQ](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu)
- [Origem: operações vetoriais quantizadas](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh)

## Histórico

- 2026-10-25: proposta aberta após identificação do GGUF-alvo, somente análise remota.
