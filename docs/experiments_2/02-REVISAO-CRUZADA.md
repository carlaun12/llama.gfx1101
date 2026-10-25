# Revisão cruzada — Experiments 2

**Estado atualizado:** quatro resumos de agentes recebidos (2026-10-25); quatro documentos Markdown completos não foram anexados. [Revisão consolidada](03-RESULTADOS-R01.md). Os percentuais abaixo são somente transcrição da imagem fornecida pelo usuário.

| Frente | Participação relatada dentro de MMVQ (perfil U) | Análise designada | Relatório |
| --- | ---: | --- | --- |
| IQ3_S | ~22,5% | Agente 1, com IQ3_XXS | Resumo recebido |
| IQ3_XXS | ~20,8% | Agente 1, com IQ3_S | Resumo recebido |
| IQ2_S | ~18,0% | Agente 2 | Resumo recebido |
| IQ4_XS | ~12,9% | Agente 3 | Resumo recebido |
| Política MMVQ e Amdahl | MMVQ ~82–84% de tempo de kernels | Agente 4 | Resumo recebido |

## Critérios de consolidação

1. Afirmar ganho somente como **hipótese** enquanto não houver evidência externa aplicável — e, neste projeto, não solicitar nem executar testes para obtê-la.
2. Separar `MUL_MAT` de `MUL_MAT_ID`, decode/verify/prefill e `MMVQ` de `MMQ`.
3. Registrar o commit exato de `experiment_2-1` analisado por cada agente, sem transferir automaticamente achados de `deep-research`.
4. Evidências primárias de perfil ausentes permanecem ausentes; não inventar identificação de “U”.
5. Ao receber relatórios, revisar divergências e registrar propostas por arquivo/função, com prioridade condicionada.


## Resultado de coordenação

**Hipótese priorizada por diferença de código:** sinais de `IQ3_XXS`. **Possível refatoração sem benefício ISA demonstrado:** helper de sinais em `IQ3_S` e `IQ2_S`. **Linha separada:** multiplicações pequenas de escala. **IQ4_XS:** head grande e operações já otimizadas no destino. O mapa W=1–8 MMVQ, W=9–128 MMQ, W>=129 dependente de tipo/guard permanece condicional. Nenhum valor da imagem pode ser convertido em benchmark de gfx1101.

[Relatório cruzado](03-RESULTADOS-R01.md).


## Rodada 02

[Revisão consolidada R02](04-RESULTADOS-R02.md): **IQ3_XXS** — candidato pontual; **IQ2_S** — não priorizar por desempenho; **IQ4_XS** — reuso entre colunas somente se MMVQ escolhido; **dispatch** — W1..8/MMVQ e W9..128/MMQ sob guards, W>=129 varia por tipo. Quatro resumos recebidos; relatórios completos não anexados. Sem testes.


## Rodada 03 — revisão cruzada

Quatro resumos recebidos: **IQ3_XXS** (port mínimo de sinais), **IQ2_XS/XXS** (`__mul24` isolado), **IQ4_XS** (reuso de preparação entre colunas W2–8 no mesmo thread) e **dispatch** (filtros MMVF/MMF/fusões antes de MMVQ). [Detalhamento](05-RESULTADOS-R03.md). Sem implementação e sem métricas novas da RX 7800 XT.
