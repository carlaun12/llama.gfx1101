# Experiments 2 — revisão cruzada da Rodada 03

**Recebimento:** 2026-10-25. **Branch:** `experiment_2-1`. **Código dos agentes:** `0e6c51e48c93c69fcbe15ce96a8120032aa9a6ee`; comparação com `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Proveniência:** quatro **resumos enviados pelo usuário** dos documentos `RELATORIO-E2-R03-IQ3XXS-SPEC.md`, `RELATORIO-E2-R03-IQ2-NOVO.md`, `RELATORIO-E2-R03-IQ4XS-REUSO.md` e `RELATORIO-E2-R03-DISPATCH-FINAL.md`. **Os arquivos completos não vieram anexados.** Conclusões abaixo são resultados relatados pelos agentes e revisão de compatibilidade entre os quatro resumos, não benchmarks nem auditoria independente de todo o código.

## Decisões da rodada

| Frente | Achado relatado | Decisão |
| --- | --- | --- |
| **IQ3_XXS sinais** | Trocar quatro linhas por duas chamadas a `apply_ksigns()`; `unpack_ksigns()` já existe e deve ser preservado | **Candidato técnico localizado**; equivalência aritmética demonstrada sob domínio de grades [4,62]; efeito em ISA e throughput desconhecido |
| **IQ2_XS / IQ2_XXS escalas** | Origem usa `ggml_cuda_mul_small()` / `__mul24` em HIP, enquanto destino multiplica inteiros com operador convencional | **Candidato novo isolado**, sujeito a limites signed-24 e codegen desconhecido |
| **IQ4_XS verify W2–8** | O mesmo thread itera colunas `j`, repete vec-dot e pode recalcular unpack/escala por coluna | **Candidato algorítmico local**, sem mudar geometria do CTA; risco de VGPR/ocupação |
| **Dispatch** | MMVQ para `MUL_MAT` quantizado elegível F32 em W1–8; MMQ/BLAS em larguras maiores; filtros MMVF/MMF/fusões anteriores | **Mapa condicional**, nunca afirmar execução observada no GGUF |

Os percentuais do perfil externo de “U” (MMVQ ~82–84% do tempo agregado de kernels da janela; IQ3_S 22,5%, IQ3_XXS 20,8%, IQ2_S 18,0%, IQ4_XS 12,9% dentro de MMVQ) continuam **pistas de priorização apenas para aquele perfil**, não medição da RX 7800 XT ou prova de benefício de um patch.

## Agente 1 — especificação mínima IQ3_XXS

O agente informa que `vec_dot_iq3_xxs_q8_1()` usa duas expressões com `__vcmpne4` para oito sinais. A origem oferece `apply_ksigns()` que constrói máscaras equivalentes por operações inteiras. Como a tabela `iq3xxs_grid` contém 256 entradas com bytes no intervalo positivo de **4 a 62**, cada byte permanece dentro do domínio em que a negação condicional não propaga carry entre bytes.

**Escopo de port proposto, ainda não implementado:** acrescentar definição de `apply_ksigns()` em `ggml/src/ggml-cuda/vecdotq.cuh` e substituir as **quatro linhas** de sinais por **duas chamadas**. `unpack_ksigns()` HIP já existente é outra rotina e **não deve ser alterado**. Preservar lookup, escala, oito `dp4a`, VDR, warps, geometria.

O agente não encontrou `apply_ksigns()` nesse arquivo; a ausência de definição homônima em toda a árvore permanece **não verificada**. Prova das grades e sinais **não** estabelece menor número de instruções ou speedup em gfx1101.

## Agente 2 — multiplicações inteiras em IQ2_XS/XXS

Após a rodada anterior encerrar `IQ2_S -> apply_ksigns()` como refatoração sem relevância de desempenho demonstrada, o Agente 2 identificou uma diferença distinta: nos vec-dot `IQ2_XS` e `IQ2_XXS`, os produtos inteiros por escalas permanecem multiplicações genéricas no fork e usam `ggml_cuda_mul_small()` na origem, com especialização HIP via `__mul24`.

Segundo o agente, bounds das somas e escalas sustentam **semântica exata de multiplicação signed-24** nos domínios mapeados, mas esses limites detalhados só constam no relatório completo anunciado. O ganho de throughput depende de o compilador já gerar uma instrução equivalente e da pressão de registradores; **não está demonstrado**. Manter proposta isolada, sem simultaneamente mudar sinais, VDR, warps ou MMQ.

## Agente 3 — reutilização local em IQ4_XS

O agente descreve que, para `MUL_MAT` denso normal, as colunas de saída podem ser processadas no laço `j` **pelo mesmo thread**. O vec-dot `IQ4_XS` é chamado novamente a cada coluna, recalculando etapas invariantes dos pesos (escala e transformação de índices IQ4_NL).

**Possibilidade estrutural relatada:** separar preparação dos pesos de acumulação por coluna, permitindo reuso dentro do mesmo thread/CTA com geometria preservada em W2–8. Para W1 não existe reuso entre colunas. Compartilhamento entre CTAs ou remapeamento de warps seriam propostas maiores **fora de escopo**.

**Restrições:** não assumir eliminação real de loads físicos (caches/codegen podem atuar), reduzir número de instruções, diminuir registros ou acelerar gfx1101. O ganho líquido pode ser negativo se VGPRs crescerem. O head `output.weight` IQ4_XS de ~644,14 MiB permanece um argumento de tráfego lógico, não de tempo observado nem prova de que todo custo MMVQ IQ4_XS da imagem se refere a esse head.

## Agente 4 — dispatch e condições de execução

Matriz relatada para `GGML_OP_MUL_MAT` denso com pesos quantizados elegíveis, entradas/saídas F32, layout e recursos admitidos e nenhum ramo anterior que intercepte:

| Formato | W1–8 | W9–128 | W>=129 |
| --- | --- | --- | --- |
| `IQ3_S` | MMVQ | MMQ | MMQ |
| `IQ3_XXS` | MMVQ | MMQ | MMQ |
| `IQ2_S` | MMVQ | MMQ | BLAS/dequantização |
| `IQ4_XS` | MMVQ | MMQ | MMQ |

**Correção de alcance:** a árvore host pode considerar MMVF, MMF ou fusões do grafo **antes** do MMVQ. A matriz caracteriza elegibilidade condicionada, não garante que cada operação do GGUF entre no vec-dot. `MUL_MAT_ID` é diferente, e MMQ não executa os vec-dot MMVQ quando W>8.

## Pontos cruzados e dependências

1. **IQ3_XXS** está suficientemente delimitado como patch candidato de sinais em fonte, com prova aritmética **relatada**, mas sem demonstração de ganho de desempenho.
2. **IQ2_XS/XXS** possui uma otimização de escala distinta de refatorar os sinais de `IQ2_S`; deve ser tratada como proposta separada para não misturar causalidade.
3. **IQ4_XS W2–8** depende diretamente do resultado do Agente 4: o kernel precisa atingir o caminho MMVQ, e reuso entre colunas só se justifica caso haja mais de uma coluna processada pelo mesmo thread.
4. O efeito do código `__mul24` e da preparação IQ4_XS sobre ISA, cache, VGPRs e desempenho **não pode ser inferido apenas de fonte**. Sem executar testes (limite permanente do usuário), classificar como hipótese.
5. Os três candidatos não são automaticamente cumulativos; cada um atua em formatos e condições diferentes. Uma alteração de despacho pode mudar a participação de cada kernel.
6. O usuário forneceu **resumos**, não o corpo dos quatro relatórios; não atribuir ao projeto dados de bounds específicos ou resultados numéricos que não aparecem aqui.

## Registro de próxima etapa (somente coordenação)

- **P0 — IQ3_XXS:** proposta de patch mínimo em documentação, aguardando decisão humana sobre eventual implementação; nenhum patch de código autorizado nesta rodada.
- **P1 — IQ2_XS/XXS:** documentar os bounds detalhados de `__mul24` recebidos do agente antes de transformar proposta em alteração de código.
- **P1 — IQ4_XS W2–8:** preservar o desenho de reuso local e a necessidade de comparação de custos/risco de VGPR na documentação, sem alegar ganho.
- **Guarda transversal:** preservar filtros MMVF/MMF e fallback; não presumir MMVQ universal.

**Restrições cumpridas:** somente documentação; nenhum kernel, código de inferência, benchmark, build, script, log ou teste executado.
