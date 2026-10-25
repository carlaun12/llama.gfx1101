# Experiments 2 — resultados da Rodada 02

**Data:** 2026-10-25. **Branch:** `experiment_2-1`. **Código investigado pelos agentes:** `0e6c51e48c93c69fcbe15ce96a8120032aa9a6ee`; comparação `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Proveniência:** quatro **resumos enviados pelo usuário** dos relatórios `RELATORIO-E2-R02-IQ3XXS.md`, `RELATORIO-E2-R02-IQ2S.md`, `RELATORIO-E2-R02-IQ4XS.md` e `RELATORIO-E2-R02-DISPATCH.md`. Os relatórios Markdown integrais **não estão anexados**; registrar as conclusões como relatadas pelos agentes, não como prova independente adicional.

**Escopo:** pesquisa documental sem código de kernel modificado, execução, compilação, benchmark, testes, logs ou medição em RX 7800 XT.

## Decisões resumidas

| Tema | Resultado relatado | Decisão |
| --- | --- | --- |
| `IQ3_XXS` sinais | Equivalência matemática demonstrada para grades com bytes de 4 a 62; origem substitui `__vcmpne4` por `apply_ksigns()` | **Candidato técnico localizado**, ganho em gfx1101 desconhecido |
| `IQ2_S` sinais | Fórmula equivalente já presente em linha; duas chamadas a `apply_ksigns()` não removem operações/dependências após expansão | **Somente manutenção/refatoração**, não priorizar por desempenho |
| `IQ4_XS` | Lookup/permute AMD/dot4 já implementados; head IQ4_XS ~644,14 MiB; possibilidade de reuso de unpack/escala entre colunas | **Hipótese condicionada a W=2..8**, não se aplica a W=1 |
| Dispatch denso | W=1..8 -> MMVQ, W=9..128 -> MMQ, W>=129 pode depender do formato | **Guardas e fallbacks obrigatórios**, não assumir cobertura de prefill |

## Agente 1 — sinais IQ3_XXS

O Agente 1 documentou equivalência da aplicação de sinais para entradas válidas do formato `IQ3_XXS`. A implementação anterior expande oito bits de sinais em máscaras para bytes usando `__vcmpne4`; o helper `apply_ksigns()` da origem emprega máscaras por aritmética e lógica de bits. Como todos os bytes da tabela `iq3xxs_grid` estão no intervalo **[4, 62]**, a negação condicional não carrega entre bytes, condição essencial para equivalência entre operação uint32 e quatro negações independentes em `int8`.

**Proposta mínima relatada:** introduzir/reusar o helper e substituir somente as duas expressões de sinais em `vec_dot_iq3_xxs_q8_1()`. Preservar acesso à tabela, escalas, oito operações `dp4a`, VDR, warps e geometria. **Prova dos valores não prova menor número de instruções de máquina, ocupação ou speedup.**

**Status:** candidato de modificação pontual para **eventual** implementação posterior, não autorizado por este documento.

## Agente 2 — IQ2_S

O Agente 2 relatou que o arquivo `vecdotq.cuh` na branch e no commit fixo analisado apresentava **o mesmo SHA** e expressões IQ2_S iguais. A forma existente de máscaras já é equivalente à implementação `apply_ksigns()` da origem; após expansão inline, não há redução de operações inteiras/dependências demonstrada.

**Veredito:** **refatoração de manutenção**, de baixo interesse como otimização de performance. Não combinar com mudanças de escalas, warps, MMQ, VDR ou políticas de dispatch. O 18% da imagem de “U” refere-se a tempo acumulado de kernels naquele perfil, **não à parte acelerável por esse refactor**.

## Agente 3 — IQ4_XS e colunas de verify

O Agente 3 documentou que `output.weight` do manifesto RCO-IQ3_XXS é `IQ4_XS` e tem geometria `5120×248320`. Em blocos de 256 pesos / 136 bytes, uma leitura integral equivale teoricamente a **675.430.400 bytes ≈ 644,14 MiB**. Isso é **bytes lógicos de pesos**, não tráfego físico medido, custo real por chamada ou latência.

Já existem lookup `IQ4_NL`, permutação AMD e `ggml_cuda_dp4a` em `vec_dot_iq4_xs_q8_1`; não duplicar. Candidato novo **apenas condicional**: reutilizar parte das transformações de escala e lookup para mais de uma coluna de verify (W=2..8) **se** o dispatcher selecionar MMVQ e **se** o kernel permitir reuso dentro de sua estrutura. Não se aplica a decode W=1. Aumento de registros/menor ocupação pode contrariar o benefício esperado.

Os **12,9%** do perfil “U” não isolam o head de saída nem representam medição da GPU-alvo.

## Agente 4 — dispatch de MUL_MAT denso

O Agente 4 relatou, para operandos compatíveis e todas as demais guardas atendidas, o mapa de código estático:

| Pesos | W=1–8 | W=9–128 | W>=129 |
| --- | --- | --- | --- |
| `IQ3_S` | MMVQ | MMQ | MMQ |
| `IQ3_XXS` | MMVQ | MMQ | MMQ |
| `IQ2_S` | MMVQ | MMQ | BLAS/dequantização |
| `IQ4_XS` | MMVQ | MMQ | MMQ |

A largura `W` e a seleção dependem também dos tipos efetivos de operandos, layout, arquitetura, recursos e fallbacks anteriores. **Elegibilidade por função não é trace real de execução**. Não transferir automaticamente a tabela para `MUL_MAT_ID`, prefill ou configurações arbitrárias de MTP.

A participação relatada de MMVQ de **82–84%** é de **soma de tempos de kernels no perfil de “U”**; não é ganho potencial do patch, nem fração demonstrada de latência ponta a ponta na RX 7800 XT.

## Ordem de investigação documental após R02

1. **P0 — IQ3_XXS:** transformar a prova matemática em uma especificação inequívoca de dependências de código e fallback, com isolamento de apenas duas expressões de sinais. **Agente 1**.
2. **P1 — IQ4_XS:** examinar se há reuso real de pesos/escala entre colunas W=2..8 no MMVQ atual antes de propor novos registradores ou buffers. **Agente 3**, em conjunto com critérios de dispatch do **Agente 4**.
3. **P1 — dispatch/guardas:** documentação final das condições sob as quais os kernels MMVQ são selecionados no alvo, sem inferir perfil. **Agente 4**.
4. **Manutenção, não performance — IQ2_S:** manter `apply_ksigns` apenas como refactor eventual; pesquisar outro gargalo só em tarefa nova e explicitamente atribuída. **Agente 2**.

**Decisão de coordenação:** não abrir imediatamente port de kernels, nem testes. A evolução depende das entregas dos agentes, e os próximos prompts serão fornecidos **no chat**.

## Referências

- [Branch experiment_2-1](https://github.com/carlaun12/llama.gfx1101/tree/experiment_2-1)
- [Código base analisado](https://github.com/carlaun12/llama.gfx1101/tree/0e6c51e48c93c69fcbe15ce96a8120032aa9a6ee)
- [Origem comparada](https://github.com/stew675/llama.cpp/tree/e8bd52069ca049cd5213366363451abbb5383865)
- [Experiments 2 / revisão R01](03-RESULTADOS-R01.md)
