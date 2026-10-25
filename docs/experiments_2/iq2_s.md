# IQ2_S — primeira hipótese de MMVQ

**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` de `ajgazin`; AMD Radeon RX 7800 XT (`gfx1101`, 16 GiB). **Branch:** `deep-research`.

**Referências de comparação já registradas:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Modo:** documentação e pesquisa pública exclusivamente. Não executar, pedir ou sugerir testes, builds, benchmarks, scripts, traces, logs, acesso local nem GPU remota. Não modificar kernels ou `master`.

**Proveniência dos percentuais:** imagem enviada pelo usuário na conversa em 25/10/2026, atribuída no próprio texto ao **“perfil de U”**. O arquivo bruto de profiling, sua URL/publicação, hardware, compilação, parâmetros, método de medição e identificação completa de “U” **não foram fornecidos**. Não tratar esse retrato como medida do GGUF/alvo nem prever speedup.

## Prioridade e motivação

O perfil da imagem atribui a `IQ2_S` **~18,0% do tempo MMVQ na janela de “U”**. Esse percentual não está comprovado para este GGUF e GPU. `IQ2_S` aparece em **72 tensores** do inventário RCO publicado, mas a quantidade de tensores não define seu custo temporal.

**Prioridade da frente:** investigar primeiro, por decisão do usuário a partir da imagem; **não** afirmar que otimização de IQ2_S terá maior retorno efetivo que IQ3_S/XXS ou IQ4_XS.

## Propostas herdadas da pesquisa anterior (não novas descobertas)

- Em [`research/mmvq-iq-mistos-rco.md`](../../research/mmvq-iq-mistos-rco.md), o tratamento dos sinais por `apply_ksigns()` foi documentado como candidato de transformação do dot product, com validade condicionada às grades de quantização e índices de sinais.
- A multiplicação de pequenas escalas `ggml_cuda_mul_small`/`__mul24`, quando aplicável e dentro dos limites matemáticos, é **hipótese separada**.
- Alterações de VDR, warp e layout não devem ser feitas junto da troca de sinais; isso confundiria os efeitos e o risco de correção.
- As possíveis diferenças em `mmq-load-tiles.cuh` são de outra superfície (**MMQ/prefill**) e não demonstram benefício para **MMVQ/decode**.

## Perguntas atribuídas ao Agente 1

1. Localizar a função `vec_dot_iq2_s_q8_1` e a chamada host de MMVQ com commits congelados, formatos dos operandos e caminhos de fallback.
2. Construir uma tabela de operações do unpack: grade, máscaras de sinal, cálculo de escala, conversão para inteiros assinados e dot product; indicar o que a origem alterou e o que o destino já faz.
3. Demonstrar por fórmula os limites de correção de `apply_ksigns` e `ggml_cuda_mul_small` especificamente em `IQ2_S`, identificando premissas sobre overflow, signedness e layouts.
4. Examinar **teoricamente** custo de load versus unpack/instruções e recursos potencialmente sensíveis à arquitetura gfx1101, sem alegar números de ISA não observados.
5. Avaliar se a participação de ~18% é atribuível ao alvo; na falta de procedência, marcar como evidência externa **não transferível**.
6. Entregar sugestões de alteração mínimas, cada uma com risco, fallback e critério de verificação **documental**.

## Questão decisiva e resultado esperado

**Qual transformação localizada de IQ2_S apresenta menor risco semântico e justificativa arquitetural mais forte, considerando que o perfil não é do alvo comprovado?**

**Estado:** aguardando relatório documental do Agente 1. Sem código modificado ou medição.
