# Revisão dos quatro agentes — Experiments 2 (R01)

**Recebido:** 2026-10-25. **Base comum dos agentes:** `carlaun12/llama.gfx1101@0e6c51e48c93c69fcbe15ce96a8120032aa9a6ee` (branch `experiment_2-1`). **Origem comparada:** `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Proveniência:** o usuário compartilhou quatro **resumos** identificados como `RELATORIO-E2-IQ3-MMVQ.md`, `RELATORIO-E2-IQ2S-MMVQ.md`, `RELATORIO-E2-IQ4XS-HEAD.md` e `RELATORIO-E2-DISPATCH-AMDAHL.md`. Não foram anexados os arquivos Markdown completos. Os pontos a seguir reproduzem e conciliam conclusões dos agentes; **não afirmam revisão integral dos relatórios nem medição própria**.

## Conclusão conjunta

| Formato | Tempo dentro de MMVQ no perfil de “U” | Diagnóstico estático relatado na branch `experiment_2-1` | Próximo recorte |
| --- | ---: | --- | --- |
| `IQ3_S` | ~22,5% | Expressão de sinais equivalente a `apply_ksigns` já em linha; `ggml_cuda_mul_small` ainda é candidato distinto | Considerar escala separadamente, sem tratar o helper como novo ganho |
| `IQ3_XXS` | ~20,8% | Ainda usa `__vcmpne4` no tratamento de sinais; candidato mais localizado de IQ3 | Avaliar equivalência/port pontual de sinais |
| `IQ2_S` | ~18,0% | Já forma máscaras por operações inteiras equivalentes; origem encapsula em duas chamadas a helper | Port mínimo pode ser **refatoração**, não redução demonstrada de instruções |
| `IQ2_XS` e `IQ2_XXS` | Não discriminados na imagem | Especialização HIP e comparação vetorial/XOR+adição em caminhos diferentes | Investigar individualmente, após IQ2_S |
| `IQ4_XS` | ~12,9% | `vec_dot_iq4_xs_q8_1` já usa lookup IQ4_NL, permute AMD e `ggml_cuda_dp4a`; `output.weight` IQ4_XS | Evitar portar novamente otimizações existentes; estudar tráfego/escalas |
| Outros | ~25,8% | Não detalhados | Sem ranking |

**Correção de prioridade pela evidência disponível:** `IQ2_S` continua importante na imagem, mas **importância de tempo não é prova de ganho ao trocar sua expressão de máscara**. Já `IQ3_XXS` apresenta uma diferença sintática concreta e localizada (`__vcmpne4`), embora o speedup também não esteja demonstrado. O caminho `IQ3_S` tem a transformação já em linha. Separar troca de sinal e multiplicação de escala evita atribuição especulativa de efeitos.

## Agente 1 — IQ3_S e IQ3_XXS

**Relatório anunciado:** `RELATORIO-E2-IQ3-MMVQ.md`.

- `IQ3_S`: tratamento de sinais já implementa a fórmula equivalente ao helper `apply_ksigns()` diretamente. Converter para chamada de helper é prioritariamente manutenção/clareza de fonte, não otimização nova comprovada.
- `IQ3_XXS`: caminho ainda passa por `__vcmpne4`, havendo diferença concreta para investigação com origem; os índices e signos da grade devem continuar preservados.
- Ambos possuem escalas com multiplicação convencional e podem ser estudados **separadamente** para `ggml_cuda_mul_small()`. O relatório alega limites conservadores de multiplicação signed 24-bit sob os domínios mapeados; falta o relatório completo para reproduzir todos os bounds.
- `ggml_cuda_dp4a` AMD já está no destino; não duplicar. Preservar política de warps/VDR.
- **Sem demonstração:** redução de ISA, VGPRs, ocupação, latência ou tokens/s na RX 7800 XT.

## Agente 2 — IQ2_S, IQ2_XS, IQ2_XXS

**Relatório anunciado:** `RELATORIO-E2-IQ2S-MMVQ.md`.

- `IQ2_S`: construção de máscara por aritmética inteira em linha; origem dispõe de duas chamadas a `apply_ksigns()`, descritas como substituição mínima. A equivalência depende de grades positivas não nulas e de alinhamento signo-byte. A alteração **pode ser apenas refatoração**.
- `IQ2_XS`: caminho HIP especializado; não assumir que mesma expressão de IQ2_S é adequada.
- `IQ2_XXS`: existe rota de comparação vetorial seguida de XOR e adição; investigar após as duas anteriores.
- A evidência do perfil de “U” atribui ~18% a IQ2_S, mas **não** comprova ganho com refatoração nem perfil na gfx1101.
- Evitar combinar com `mul_small`, VDR, waves e geometria.

## Agente 3 — IQ4_XS e head de saída

**Relatório anunciado:** `RELATORIO-E2-IQ4XS-HEAD.md`.

- O agente relata a confirmação de `output.weight=IQ4_XS` pelo manifesto público de alocação do RCO-IQ3_XXS, com acesso indireto ao material ISTA; `rco_types.tsv` específico não esteve diretamente disponível na sua consulta. Registrar a **limitação de origem** em vez de atribuir-lhe leitura direta da TSV.
- Matriz `[5120,248320]`: `248320*5120*136/256 = 675.430.400` bytes ≈ **644,14 MiB** em IQ4_XS, sob geometria GGML, por leitura integral lógica.
- Lookup de valores IQ4_NL, permute AMD `get_int_from_table_16`, `ggml_cuda_dp4a` e escalas existentes tornam um novo port dessas partes redundante.
- Hipóteses restantes: reuso de escalas, acesso e leituras redundantes, sujeitas a pressão de registradores e ocupação.
- A parcela de **12,9%** não isola `output.weight` nem foi vinculada à RX 7800 XT.

## Agente 4 — dispatch e Amdahl

**Relatório anunciado:** `RELATORIO-E2-DISPATCH-AMDAHL.md`.

Tabela relatada para **`MUL_MAT` denso**, pesos quantizados elegíveis, ativações/saídas F32 e demais guardas satisfeitos em `gfx1101`. **Mapa de código condicional, não trace executado**:

| Tipo | W=1 | W=2–8 | W=9–128 | W>=129 |
| --- | --- | --- | --- | --- |
| `IQ3_S` | MMVQ | MMVQ | MMQ | MMQ |
| `IQ3_XXS` | MMVQ | MMVQ | MMQ | MMQ |
| `IQ2_S` | MMVQ | MMVQ | MMQ | Dequantização/BLAS |
| `IQ4_XS` | MMVQ | MMVQ | MMQ | MMQ |

Há decisões anteriores/fallbacks por tipo, forma, memória compartilhada e arquitetura. `MUL_MAT_ID` é um caso diferente, irrelevante ao backbone denso escolhido.

**Cenário de Amdahl do perfil de “U”:** os quatro grupos somam **74,2%** de MMVQ. Aplicar a fração de 82–84% resulta em **60,844–62,328%** da soma de tempo de kernels daquela janela, aproximadamente **60,8–62,3%**, desde que os denominadores e métodos de soma coincidam. Este número **não** representa latência ponta a ponta e **não é** fração acelerável por um patch único.

A lei de Amdahl `S=1/((1-f)+f/r)` só entrega uma aceleração após conhecer `f` (parte efetivamente acelerável de todo o trabalho) e `r` (fator de aceleração dessa parte), ambos desconhecidos neste GGUF/gfx1101.

## Revisão cruzada: conflitos e limites

1. **Fato novo para esta branch:** resultados históricos da `deep-research` **não podem ser transportados literalmente** para `experiment_2-1`: há otimizações já implementadas em linha (IQ3_S e IQ2_S), portanto `apply_ksigns` seria em grande medida um encapsulamento em alguns caminhos.
2. **Candidato de port mínimo mais distinto:** `IQ3_XXS` tratamento de sinais. **Candidato de prioridade de tempo em perfil externo:** `IQ2_S`, mas sua mudança para helper pode não alterar a ISA.
3. **Outros caminhos:** `IQ4_XS` já tem permute/dot4; `IQ3_S` e `IQ3_XXS` devem ter a aritmética de escala estudada separadamente do unpack.
4. **Não existe medição local:** perfil de “U” tem procedência não fornecida; as participações não descrevem necessariamente o GGUF, o contexto ou a GPU do usuário.
5. **Sem relatórios completos:** bounds de `__mul24`, códigos exatos de helper e árvore completa de dispatch são atribuídos aos resumos; exigir referências detalhadas dos agentes antes de classificar um patch como formalmente especificado.

## Próximos passos atribuídos aos agentes

- **Agente 1:** especificar mudança mínima de sinais em `IQ3_XXS` e delimitar prova/risco, **sem implementar**.
- **Agente 2:** distinguir formalmente a aritmética IQ2_S já presente de qualquer benefício que reste ao helper, sem alegar aceleração.
- **Agente 3:** decompor custo teórico de `output.weight` IQ4_XS por caminho e as hipóteses de reuso de escalas, sem atribuir 12,9% ao head.
- **Agente 4:** refinar tabela de dispatch por guards host e diferenciar elegibilidade de seleção real, mantendo Amdahl condicional.

## Estado

**Quatro resumos recebidos; quatro relatórios completos anunciados mas não anexados.** Não foi executado teste, compilação, benchmark, inferência nem alteração de kernel. A próxima rodada de prompts deve ser enviada diretamente no chat, conforme a preferência do usuário.
