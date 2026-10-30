# Experiments 2 — Rodada 08: RMSNorm ponderado → q8_1

Base examinada pelos agentes: experiment_2-1@91f0d7ab54f17b0af57fef95d28781cf1257ba85. Alvo: gfx1101, GGUF Swift-1.5-Qwen3.8-27B-RCO.

Proveniência: quatro resumos fornecidos no chat, não os relatórios integrais. Sem execução de GPU, scripts, builds, testes ou benchmarks. Sem ganhos de desempenho demonstrados.

## Veredito

**Candidato geometricamente mais natural que SwiGLU, mas condicionado ao grafo, dispatch e exatidão.** A fusão RMSNorm + MUL pelos pesos já existe em casos elegíveis; a oportunidade adicional é produzir block_q8_1 dos valores F32 *depois* da multiplicação pelos pesos, para consumidor MMVQ. MMQ usa outra representação de ativação. Priorizar hipótese de produtor duplo F32 + q8_1, como opção conservadora, não afirmar ganho.

## Agente 1 — grafo

Padrão candidato RMS_NORM → MUL(pesos) → MUL_MAT. Casos estruturais incluem attn_norm seguido de projeções Q/K/V, atenção linear, FFN após attn_post_norm e MTP, mas dispatch MMVQ específico ainda não está demonstrado. As normalizações Q/K internas antes de RoPE, hnorm/enorm antes de concatenação e saídas não são automaticamente elegíveis. Fusão RMSNorm+MUL já existente precisa ser descontada. Múltiplos consumidores F32 exigem preservação dos dados ou compatibilidade expressa de compartilhamento.

## Agente 2 — geometria

Para D_model=5120, caminho RMSNorm vetorizado: 1024 threads/CTA, 32 waves32, vpt=4. Cada CTA possui os 5120 valores de uma linha/token: 160 blocos q8_1 completos, sem colaboração entre CTAs. Cada thread lê float4 e as primeiras 256 threads leem outro float4 segundo o agente. Quantizar requer 160 reduções adicionais independentes de amax e soma; reduzir 8 lanes com 4 valores cada não reproduz automaticamente uma árvore de 32 lanes. Ausência de necessidade estrutural de LDS extra não comprova conservação numérica ou boa ocupação.

## Agente 3 — contrato e custos

A norma usa soma de quadrados da entrada ANTES dos pesos, com fator rsqrtf(soma/D + epsilon). Quantizar os valores ponderados finais, preservando exata ordem F32, amax, soma pré-arredondamento, d, roundf e conversões FP16. Igualdade bit a bit não demonstrada apenas por fonte.

Para D=5120 e W=1: F32 intermediário = 20.480 B; buffer q8_1 MMVQ = 5.760 B. Eliminar escrita+releitura do F32 permite até 40.960 B lógicos por token/camada elegível. **Produzir simultaneamente F32 e q8_1 mantém a escrita F32**, portanto o máximo de acessos F32 eliminados nesse caso cai a 20.480 B (uma releitura evitada), presumindo que o consumidor possa usar q8_1 diretamente. Valores são contabilidade lógica, não DRAM, latência nem tokens/s. W2–8 exige avaliar dispatch e layouts separadamente.

## Agente 4 — integração adversarial

A) só q8_1 bloqueado como substituição geral; B) F32 + q8_1 condicional e preferível inicialmente; C) selecionar A/B por consumidores condicional, adiar; D) F32 seguido de quantização separada é o fallback atual.

Reconhecer padrão no executor sem suprimir fusões preexistentes RMSNorm→MUL e variantes RoPE. Um produtor único de q8_1 precisa de lifetime e propriedade explícitos; MMVQ deve consumir buffer pré-produzido sem requantizar, preservando os usos F32. Validar tipos, shapes, strides, W, dados após MUL, padding, arredondamento, ownership, streams e fallback. MMQ/BLAS e casos incompatíveis permanecem originais.

## Cruzamento e decisão

1. Geometria favorável (linha inteira por CTA) resolve o bloqueio de comunicação entre CTAs encontrado em SwiGLU, mas **não** resolve automaticamente a redução q8_1 nem seu custo numérico.
2. Proposta B é conservadora para semântica do grafo, porém economiza potencialmente **20.480 B lógicos**, não 40.960 B: a escrita F32 permanece. A só q8_1 exige demonstrar uso único do F32; não habilitar como substituição geral.
3. Muitas projeções podem compartilhar ativação ponderada; produção única q8_1 deve preservar esse compartilhamento e não quantizar por CTA do consumidor.
4. Não confundir F32 da RMSNorm bruta com o F32 pós-MUL exigido pelo MMVQ.
5. Próximo bloqueador documental: mapear um caso concreto de grafo+dispatch MMVQ sem conflitos de consumo, mapear redução exata de 32 elementos e especificar interface q8_1 compartilhável com fallback.
6. Nenhuma melhora de desempenho demonstrada; não autorizar implementação generalizada.

Status: documentação, sem alterações nos kernels ou master.
