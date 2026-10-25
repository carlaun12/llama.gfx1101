# IQ3_S — contribuição reportada e revisão MMVQ

**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` de `ajgazin`; AMD Radeon RX 7800 XT (`gfx1101`, 16 GiB). **Branch:** `deep-research`.

**Referências de comparação já registradas:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Modo:** documentação e pesquisa pública exclusivamente. Não executar, pedir ou sugerir testes, builds, benchmarks, scripts, traces, logs, acesso local nem GPU remota. Não modificar kernels ou `master`.

**Proveniência dos percentuais:** imagem enviada pelo usuário na conversa em 25/10/2026, atribuída no próprio texto ao **“perfil de U”**. O arquivo bruto de profiling, sua URL/publicação, hardware, compilação, parâmetros, método de medição e identificação completa de “U” **não foram fornecidos**. Não tratar esse retrato como medida do GGUF/alvo nem prever speedup.

## Evidência que motivou a frente

A imagem atribui `IQ3_S` **~22,5% do tempo dentro de MMVQ**, a maior participação individual da tabela reportada para “U”. Esse dado **não prova** distribuição equivalente no GGUF RCO do usuário. O manifesto RCO selecionado registra **97 tensores IQ3_S**, sem medir quanto cada um contribui no decode.

## Hipóteses existentes e limites

A proposta [MMVQ IQ misto](../../research/mmvq-iq-mistos-rco.md) registra o delta de `vec_dot_iq3_s_q8_1` para aplicação de sinais `apply_ksigns()` e a análise conservadora de multiplicação de escalas. A possível economia na preparação de valores quantizados é **hipótese**, não speedup estabelecido no gfx1101. `MMQ` e `MUL_MAT_ID` não são equivalentes ao MMVQ denso.

## Questões para o Agente 2

1. Reconstruir por fonte o despacho MMVQ para `IQ3_S` e o caminho do vec-dot em destino/origem congelados.
2. Listar diferenças de unpack, máscaras, escalas, dot product e tratamento do tipo, separando partes já otimizadas no destino.
3. Revisar a validade de `apply_ksigns` especificamente para os bytes da grade `IQ3_S`, incluindo sinais e limites.
4. Descrever riscos de VGPRs, ocupação e bound de instruções **apenas como inferências arquiteturais**, não como medições.
5. Classificar efeito possível versus custo de transferir muitos pesos; o perfil de “U” não informa bytes por tensor nem seleção efetiva no GGUF.
6. Comparar qualitativamente prioridade de IQ3_S versus IQ2_S **sem inventar ganho ou extrapolar o percentual da imagem**.

**Estado:** aguardando relatório documental do Agente 2. Sem teste ou port.
