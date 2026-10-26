# Experiments 2 — Rodada 04: MMVQ multilinha/multicoluna no gfx1101

**Data de consolidação:** 2026-10-25. **Branch:** `experiment_2-1`. **Alvo:** RX 7800 XT (`gfx1101`), MMVQ denso em `MUL_MAT` com IQ3_S, IQ3_XXS, IQ2_S e IQ4_XS.

**Proveniência:** quatro **resumos** apresentados pelo usuário de `RELATORIO-E2-R04-GEOMETRIA.md`, `RELATORIO-E2-R04-RECURSOS.md`, `RELATORIO-E2-R04-REUSO.md` e `RELATORIO-E2-R04-DISPATCH.md`. Os corpos integrais não foram fornecidos; detalhes de provas/bounds mencionados nesses relatórios não foram verificados neste registro. Não há resultado empírico do GGUF na RX 7800 XT.

## Decisão executiva

**Não habilitar 2 nem 4 linhas por CTA como otimização recomendada neste momento.** Preservar **1 linha por CTA** para IQ3_S, IQ3_XXS, IQ2_S e IQ4_XS na tabela `MMVQ_PARAMETERS_RDNA3_0`.

A estrutura genérica do kernel admite `rows_per_cuda_block` maior que 1, mas **a segurança das leituras da cauda da matriz** e os custos de VGPR/ocupação não estão resolvidos. O melhor candidato de investigação, caso essas condições sejam demonstradas por fonte/matemática, é **2 linhas**, especialmente no caso W=1/2; quatro linhas permanece bloqueado. Aqui **W designa a largura `ncols_dst` (colunas/tokens)**; **R designa linhas de saída por CTA**. Os resumos do Agente 1 usaram “W” para linhas; para evitar ambiguidade adotamos R/W.

## Matriz de política conservadora relatada — RDNA3_0

| W = colunas por operação | R=1 | R=2 | R=4 |
| --- | --- | --- | --- |
| **1** | **manter** | hipótese condicional | não habilitar |
| **2** | **manter** | hipótese de menor prioridade | não habilitar |
| **4** | **manter** | não habilitar inicialmente | não habilitar |
| **8** | **manter** | não habilitar inicialmente | não habilitar |

Matriz válida apenas se o dispatch escolher o caminho MMVQ denso elegível. Não se aplica automaticamente a MMQ, BLAS, MMVF/MMF, `MUL_MAT_ID` ou ao kernel multi-token MoE.

## Agente 1 — geometria, redução e segurança

- `mul_mat_vec_q()` parametriza pelo mesmo `rows_per_cuda_block` os acumuladores, offsets de linhas, reduções e escrita. `calc_launch_params()` deve derivar a grade do **mesmo** valor. Uma mudança unilateral criaria inconsistência.
- `calc_nwarps()` é distinto de R: no caminho RDNA3 para os formatos IQ prioritários, R=1 e uma wave32 por CTA. Aumentar R não obriga aumentar waves.
- **Bloqueador de correção:** a escrita da última CTA tem condição `row0+i < stride_col_dst`, mas o loop de vec-dot pode **ler pesos de linhas i fora da altura lógica** antes dessa condição. É preciso estabelecer padding/endereço seguro **ou** proteger as leituras e seus efeitos sem invalidar redução/fusões. Máscara na escrita não torna leitura válida.
- O caminho `mul_mat_vec_q_moe_launch()` tem geometria própria, já usa duas linhas e guarda a saída com `row0+threadIdx.x < nrows_x`; não misturar com `MUL_MAT` denso.

## Agente 2 — recursos

- A política `MMVQ_PARAMETERS_RDNA3_0` seleciona, nos tipos em análise, **1 wave32** e **R=1** para W=1,2,4,8. Propostas R=2/4 mantêm o mesmo número de threads inicialmente e acrescentam trabalho por thread.
- Acumuladores principais `tmp[W][R]`: contagens **lógicas de floats por thread**:

| R \\ W | W=1 | W=2 | W=4 | W=8 |
| --- | ---: | ---: | ---: | ---: |
| **1 (atual)** | 1 | 2 | 4 | 8 |
| **2 (hipotético)** | 2 | 4 | 8 | 16 |
| **4 (hipotético)** | 4 | 8 | 16 | 32 |

- Fusões com gate podem acrescentar `tmp_gate[W][R]`. Registradores temporários (grids, escalas, ponteiros) também contribuem; estes valores **não são contagem de VGPR compilada**.
- Com 1 wave por CTA, a redução funcional é intrawave; uma declaração de `__shared__` não comprova alocação LDS após otimização do compilador. Aumentar R reduz CTAs e pode degradar ocupação, inclusive diante das 60 CUs da RX 7800 XT.

## Agente 3 — duas formas distintas de reuso

- **Entre colunas W:** o mesmo thread itera `j` e invoca repetidamente o vec-dot para a mesma linha de pesos com ativações `q8_1` diferentes. Há possibilidade de compartilhar decodificação (índices, sinais, grades, escalas) de IQ3_S, IQ3_XXS, IQ2_S e IQ4_XS; não está demonstrado que o compilador não elimine partes da redundância.
- **Entre linhas R:** cada linha tem pesos próprios, mas usa a mesma ativação na mesma posição/coluna. Ampliar R permite reuso lógico de `q8_1`; não elimina leitura de pesos distintos e **não garante redução no tráfego físico**, devido a cache/codegen.
- Reuso explícito de ativações, reestruturação dos vec-dot e eventual extensão de vida útil de valores podem aumentar VGPRs. Não combinar automaticamente reuso intra-W e R>1 no mesmo patch.
- **Não está demonstrado** que R=2 seja ótimo; é opção conservadora de pesquisa.

## Agente 4 — seleção e isolamento

- Manter R=1 no caminho RDNA3_0 de IQ3_S, IQ3_XXS, IQ2_S e IQ4_XS.
- Condicionar propostas R=2 ao tipo, W, layout e às garantias de endereço/cauda. R=4 fica pendente de provas de correção e recursos, não habilitado por padrão.
- Não alterar a política de `MUL_MAT_ID` (incluindo caminho MoE), nem caminhos MMQ/BLAS/especializados. Elegibilidade de MMVQ não comprova execução no GGUF.

## Revisão cruzada: prioridades e impedimentos

1. **Bloqueio P0 — segurança da cauda:** demonstrar que todo acesso de linha por CTA é válido, inclusive quando `nrows_x % R != 0`, e separar limites de `nrows_x` de `stride_col_dst`. Não habilitar R>1 sem esse contrato.
2. **P1 — coerência da geometria:** `calc_rows_per_block()` e `calc_launch_params()` devem derivar o mesmo R; redução e gravação devem reconhecer linhas válidas.
3. **P1 — recursos:** tabelar `tmp`, `tmp_gate`, dados de decodificação e paralelismo de R=1/2/4 para cada W, sem inventar VGPR físico.
4. **P1 — otimização independente:** priorizar proposta de reuso da preparação dos pesos **entre colunas** no R=1 atual, que evita simultaneamente o bloqueio de leituras multilinha e o crescimento R×W de acumuladores.
5. **P2 — R=2 condicional:** apenas hipótese documental para W=1 e W=2, após correção estática e seleção condicional. R=4/W4–8 não habilitar como próximo passo.

## Veredito

**Viabilidade estrutural: sim. Segurança da alteração direta: não estabelecida. Aceleração: desconhecida.** A recomendação anterior de começar diretamente com 2 linhas × W2–4 precisa ser **rebaixada** diante do risco de leitura na cauda e da ausência de vantagem estática sustentada.

**Restrições:** nenhuma compilação, script, profiler, teste GPU ou benchmark; nenhum kernel alterado. A documentação permanece em `experiment_2-1`; `master` intacta.
