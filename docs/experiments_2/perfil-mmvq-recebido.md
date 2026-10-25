# Registro da evidência recebida: participação de MMVQ por quantização

**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` de `ajgazin`; AMD Radeon RX 7800 XT (`gfx1101`, 16 GiB). **Branch:** `deep-research`.

**Referências de comparação já registradas:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Modo:** documentação e pesquisa pública exclusivamente. Não executar, pedir ou sugerir testes, builds, benchmarks, scripts, traces, logs, acesso local nem GPU remota. Não modificar kernels ou `master`.

**Proveniência dos percentuais:** imagem enviada pelo usuário na conversa em 25/10/2026, atribuída no próprio texto ao **“perfil de U”**. O arquivo bruto de profiling, sua URL/publicação, hardware, compilação, parâmetros, método de medição e identificação completa de “U” **não foram fornecidos**. Não tratar esse retrato como medida do GGUF/alvo nem prever speedup.

## Transcrição fiel da imagem

O material afirma: **“os kernels MMVQ quantizados concentraram aproximadamente 82–84% da soma dos tempos de kernels na janela analisada”** no chamado “perfil de U”.

| Formato dos pesos | Participação reportada dentro do tempo MMVQ |
| --- | ---: |
| `IQ3_S` | ~22,5% |
| `IQ3_XXS` | ~20,8% |
| `IQ2_S` | ~18,0% |
| `IQ4_XS` | ~12,9% |

A imagem destaca que os três primeiros compõem aproximadamente **61%** do tempo de MMVQ da janela, ou aproximadamente metade do tempo total de kernels da mesma janela. O GGUF descrito mistura quantizações; o sufixo `IQ3_XXS` não significa que todos os pesos estejam nesse formato. O material propõe examinar `IQ2_S` primeiro por ser uma hipótese ainda não resolvida.

## O que a evidência sustenta — e o que não sustenta

**Evidência recebida (não auditada):** uma distribuição reportada de tempos acumulados dos kernels MMVQ numa janela específica, ordenada por formato. A imagem **não contém** data da captura, hardware, modelo GGUF, duração da janela, número de chamadas, configuração de contexto, lote, software de profiling ou dados brutos.

**O que não se pode concluir:**

- Que 82–84% seja a fração do tempo de geração ponta a ponta; o denominador declarado é **a soma de tempos dos kernels** da janela, que pode diferir de latência total por sincronizações, transferência CPU–GPU, sobreposição e outros componentes.
- Que cada porcentagem corresponda ao tempo da RX 7800 XT `gfx1101`, à mesma revisão do fork ou ao arquivo RCO-IQ3_XXS selecionado.
- Que o grupo com maior tempo seja automaticamente o mais otimizável; frequência, bytes, escolha do kernel, custo de dequantização e dependências podem produzir esse perfil por motivos diferentes.
- Que qualquer alteração de `apply_ksigns`, escalas, warp/VDR ou lookup produza ganho percentual específico; esses são **candidatos de código**, não resultados observados.

## Ligação com a pesquisa existente

A pesquisa já registrada em [`research/mmvq-iq-mistos-rco.md`](../../research/mmvq-iq-mistos-rco.md) documenta os formatos mistos, o helper `apply_ksigns` e a distinção entre `MMVQ` e `MMQ`. Para que a imagem oriente priorização no alvo, os agentes devem primeiro avaliar **se o perfil tem condições comparáveis**, ou tratar as frações apenas como pista externa.

Esta etapa investiga **MMVQ de decode e verify estreito**, não transfere conclusões de MMQ/pre-fill nem das políticas `MUL_MAT_ID` para o modelo denso.

## Lacunas a resolver pelos agentes

1. Fonte primária do “perfil de U” identificável? Se não, declarar **procedência insuficiente**.
2. O perfil registra tempo por categoria de kernel, ou por chamada? Qual foi a agregação e janela?
3. Os formatos e seletores correspondem aos kernels e shapes desse GGUF? Qual o grau de certeza?
4. Que partes do custo observado seriam leituras de pesos, dequantização, dot product e outras operações? Fazer **classificação teórica**, não profiling novo.

## Estado

**Imagem recebida e transcrita; números registrados como relato externo, sem auditoria de origem e sem medição do alvo.** Os quatro agentes externos receberão as missões **diretamente no chat**. Seus relatórios, após revisão, podem preencher as fichas deste diretório.
