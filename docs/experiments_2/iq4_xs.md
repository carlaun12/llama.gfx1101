# IQ4_XS — participação reportada e custo do output.weight

**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` de `ajgazin`; AMD Radeon RX 7800 XT (`gfx1101`, 16 GiB). **Branch:** `deep-research`.

**Referências de comparação já registradas:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Modo:** documentação e pesquisa pública exclusivamente. Não executar, pedir ou sugerir testes, builds, benchmarks, scripts, traces, logs, acesso local nem GPU remota. Não modificar kernels ou `master`.

**Proveniência dos percentuais:** imagem enviada pelo usuário na conversa em 25/10/2026, atribuída no próprio texto ao **“perfil de U”**. O arquivo bruto de profiling, sua URL/publicação, hardware, compilação, parâmetros, método de medição e identificação completa de “U” **não foram fornecidos**. Não tratar esse retrato como medida do GGUF/alvo nem prever speedup.

## Evidência que motivou a frente

A imagem atribui a `IQ4_XS` **~12,9% do tempo total de MMVQ da janela de “U”**. O modelo RCO usa IQ4_XS em **33 tensores** no manifesto público; `output.weight` tem quantização `IQ4_XS`, com forma teórica `248.320 × 5.120` e cerca de **644,14 MiB** de dados quantizados. Esse grande head **pode** importar no decode, mas não é prova de execução de `IQ4_XS` no mesmo perfil externo.

## Hipóteses herdadas da pesquisa existente

- O destino já contém caminhos AMD de consulta/permute de `IQ4_XS`; não propor reimplementá-los sem demonstrar lacuna de código.
- A interação entre tamanho do `output.weight`, número de logits calculados e banda de memória é hipótese de gargalo, não medição. Não usar o subset do **draft MTP** como se reduzisse automaticamente o head **target**.
- `MUL_MAT` denso, `MMVQ`, `MMQ` e a política de `MUL_MAT_ID` são rotas distintas.

## Questões para o Agente 4

1. Mapear o despacho MMVQ `IQ4_XS`, função de produto vetorial, tratamento de escala e otimizações AMD já existentes.
2. Identificar por código quais partes ainda diferem entre a origem e o fork e quais seriam duplicações de implementações.
3. Analisar separadamente a matriz `output.weight` (bytes, acessos teóricos por token) e as demais matrizes IQ4_XS. Não usar contagem simples como tempo.
4. Explicar em que cenário a leitura do head completo domina e quando contexto/MTP/dispatch modificariam a hipótese; sem estimativas empíricas.
5. Produzir uma recomendação comparativa de prioridade frente a IQ2_S/IQ3_S/IQ3_XXS, **não** uma previsão percentual de aceleração.
6. Especificar alterações pontuais admissíveis, riscos semânticos e fallbacks existentes.

**Estado:** aguardando relatório documental do Agente 4. Sem execução e sem benchmark.
