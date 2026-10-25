# IQ3_XXS — unpack e caminho MMVQ

**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` de `ajgazin`; AMD Radeon RX 7800 XT (`gfx1101`, 16 GiB). **Branch:** `deep-research`.

**Referências de comparação já registradas:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Modo:** documentação e pesquisa pública exclusivamente. Não executar, pedir ou sugerir testes, builds, benchmarks, scripts, traces, logs, acesso local nem GPU remota. Não modificar kernels ou `master`.

**Proveniência dos percentuais:** imagem enviada pelo usuário na conversa em 25/10/2026, atribuída no próprio texto ao **“perfil de U”**. O arquivo bruto de profiling, sua URL/publicação, hardware, compilação, parâmetros, método de medição e identificação completa de “U” **não foram fornecidos**. Não tratar esse retrato como medida do GGUF/alvo nem prever speedup.

## Evidência que motivou a frente

O perfil de “U” atribui a `IQ3_XXS` **~20,8% do tempo dentro dos kernels MMVQ**. O GGUF alvo possui **83 tensores IQ3_XXS** no manifesto publicado. Nem o percentual nem a contagem permitem inferir participação de tráfego do usuário ou ganho de otimização no gfx1101.

## Hipótese herdada

O documento [MMVQ IQ misto RCO](../../research/mmvq-iq-mistos-rco.md) registra `vec_dot_iq3_xxs_q8_1`, o candidato de transformação de sinais `apply_ksigns()` e seus limites. Uma aplicação ao unpack de `IQ3_XXS` precisa preservar índice de grade, ordem de subgrupos e sinais. A análise de MMQ é mantida separada.

## Questões para o Agente 3

1. Comparar o vec-dot `IQ3_XXS` da origem e do fork, com função, commit e trecho de evidência.
2. Detalhar indexação da grade, bits de sinal, operações de desquantização e reagrupamento, e provar os invariantes necessários para `apply_ksigns`.
3. Separar custo potencialmente dominado por bytes versus custo de instruções sem assumir perfil transferível.
4. Avaliar matematicamente limites de escalas e multiplicações pequenas, caso aplicável, sem extrapolar `__mul24` a operandos não provados.
5. Registrar alternativas de mudança mínima, riscos de order/overflow e fallback; não combinar simultaneamente VDR/warps/tiles.
6. Informar quais resultados do agente IQ3_S podem ser compartilhados e quais diferenças tornam os formatos não intercambiáveis.

**Estado:** aguardando relatório documental do Agente 3. Sem medição ou alteração de kernels.
