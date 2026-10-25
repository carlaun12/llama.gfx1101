# Fonte da hipótese — imagem do usuário

**Fonte primária desta rodada:** imagem apresentada pelo usuário em 2026-10-25, com título conceitual de MMVQ como multiplicações de pesos quantizados pelas ativações. O texto diz explicitamente **“No perfil de U”** e **“na janela analisada”**.

## Dados transcritos, sem extrapolação

- MMVQ quantizado: **aproximadamente 82–84% da soma dos tempos de kernels** da janela analisada.
- Participações dentro dos kernels MMVQ: `IQ3_S~22,5%`, `IQ3_XXS~20,8%`, `IQ2_S~18,0%`, `IQ4_XS~12,9%`.
- Soma dos três primeiros: `22,5+20,8+18,0=61,3%`.
- Produto indicativo com a fração atribuída a MMVQ: `0,613*[0,82;0,84]=[0,50266;0,51492]`, isto é, **50,3–51,5%** do agregado de tempo de kernels dessa janela. *Isto pressupõe que as porcentagens têm o mesmo universo e que são medidas de tempo compatíveis, conforme a redação da imagem; não é uma medição independente.*

## O que a imagem não estabelece

- Identidade de “U”; GPU, driver, backend, modelo ou GGUF efetivo.
- Se o intervalo descreve decode single-token, verify MTP, prefill ou mistura deles.
- Se os percentuais são tempo acumulado, tempo sobreposto, eventos sobrepostos, média por chamada ou soma simples de duração.
- Se o limite é bandwidth, uso de ALU, carregamento de tabelas de grade, registros, latência ou ocupação.
- Ganhos esperáveis ao mudar unpack em `IQ2_S` ou os demais tipos.

## Hipóteses a serem estudadas pelos agentes

| Hipótese | Categoria | Evidência suficiente para sustentar documentalmente |
| --- | --- | --- |
| `IQ2_S` merece atenção ao lado de `IQ3_S/XXS` | Priorização **da fonte** | Participação de 18,0% *naquela janela* |
| `IQ2_S` é o melhor alvo para otimizar `gfx1101` | **Não estabelecido** | Comparação de código e custos por peso/shape, não apenas percentual de outro perfil |
| `apply_ksigns` reduz etapas no decode quantizado | **Hipótese por código** | Diff estático, equivalência de bytes assinados e efeitos possíveis sobre custos |
| `output.weight` IQ4_XS participa materialmente | **Hipótese por geometria** | Shape, tipo, dispatch e potencial tráfego da matriz |
| Kernel com maior tempo agregado rende maior ganho | **Não demonstrado** | Amdahl exige fração acelerável e razão de aceleração desconhecida |

A referência ao perfil de “U” **não deve ser convertida em benchmark da RX 7800 XT** no relatório final. Sem proveniência, o perfil é um ponto de partida para perguntas, não validação do resultado do usuário.
