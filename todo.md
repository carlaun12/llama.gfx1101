# TODO — pesquisa Swift RCO / Radeon RX 7800 XT gfx1101

**Atualizado:** 2026-10-25 — quatro resumos R05 recebidos; revisão cruzada registrada
**Branch exclusiva para documentos:** `deep-research` — **não alterar `master`**.
**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` (`ajgazin`, RCO-IQ3_XXS) em RX 7800 XT, gfx1101, 16 GiB.
**Modo de trabalho:** quatro agentes externos pesquisam; o assistente **coordena as tarefas, revisa os relatórios e consolida**. O assistente não substitui agentes como pesquisador. Os quatro agentes foram acionados externamente e retornaram resumos da R05; nenhum agente novo foi acionado automaticamente por esta atualização.

## Nova frente — MMVQ IQ em docs/experiments_2/ (25/10/2026)

**Decisão do usuário:** investigar os grupos `IQ3_S`, `IQ3_XXS`, `IQ2_S` e `IQ4_XS` indicados em imagem de um **“perfil de U”**, dando atenção inicial a **IQ2_S**.

- [ ] **Agente 1:** `IQ2_S` — prova de sinais, `vec_dot_iq2_s_q8_1`, dispatch MMVQ, riscos `__mul24`. [Ficha](docs/experiments_2/iq2_s.md).
- [ ] **Agente 2:** `IQ3_S` — unpack/vec-dot e fatores de custo. [Ficha](docs/experiments_2/iq3_s.md).
- [ ] **Agente 3:** `IQ3_XXS` — grades, sinais, operadores e custo relativo. [Ficha](docs/experiments_2/iq3_xxs.md).
- [ ] **Agente 4:** `IQ4_XS` — caminho do head `output.weight` e otimizações AMD já existentes. [Ficha](docs/experiments_2/iq4_xs.md).

**Fonte:** [transcrição e limites do perfil recebido](docs/experiments_2/perfil-mmvq-recebido.md). O retrato afirma MMVQ com 82–84% da soma dos tempos de kernels na janela, e participações internas de 22,5% IQ3_S, 20,8% IQ3_XXS, 18,0% IQ2_S e 12,9% IQ4_XS. **São números externos de proveniência insuficiente, não benchmarks confirmados em gfx1101 ou neste GGUF.**

**Estado:** fichas abertas, aguardando relatórios dos quatro agentes. **Prompts entregues somente no chat**; não publicar prompts no GitHub. O assistente coordena e consolida, sem conduzir a investigação técnica em substituição aos agentes.

## Situação atual após a Rodada 05

**Relatórios R05:** 4/4 resumos recebidos e revisados; os quatro arquivos `RELATORIO-R05-*.md` completos foram anunciados, **mas não anexados ao chat**. Consolidado em [research/RODADA-05-RESULTADOS.md](research/RODADA-05-RESULTADOS.md).

**Tarefas restantes para os agentes, não para investigação substitutiva do assistente:**

- [ ] **P0 — BPE do GGUF:** fechar, se possível por evidência pública, a desigualdade de inversões dos IDs válidos `n_out_of_order <= floor(n_first/100)` e os atributos especiais do `llama_vocab`; caso impossível, registrar **elegibilidade não comprovada** em vez de prosseguir com habilitação presumida. **Responsável: Agente 1.**
- [ ] **P0 — Integridade LoRA no patch 0013:** documentar se a substituição do tensor `model.output` por `mtp_draft->head` altera a associação de adaptadores em `build_lora_mm`; propor guard/fallback somente em documento. **Responsável: Agente 2.**
- [ ] **P0 — Semântica Q8_0:** delimitar condições de arredondamento RNE, subnormais/FTZ, zeros assinados e fatores compilador/arquitetura para a equivalência **por elemento**, sem confundir com identidade de logits. **Responsável: Agente 3.**
- [ ] **P1 — BF16 direto vs BF16->F16:** isolar diferenças numéricas potencialmente relevantes para KQ/PV; manter independente da prova Q8_0. **Responsável: Agente 4**, articulado com Agente 3.
- [ ] **P1 — Contrato de port restrito a verify:** completar matriz `seletor -> TILE -> launcher -> scratch -> fallback` por W=1..8 e formato K/V, sem prefill longo nem hardware RDNA4. **Responsável: Agente 4.**

**Política de coordenação:** as próximas missões detalhadas são enviadas diretamente no chat, não em novos arquivos de prompts no GitHub. Esta atualização registra prioridades e conclusões, **não inicia nova investigação**.

## P0 — prioridades da Rodada 05 (histórico das missões concluídas em resumo)

- [x] **P0.1 — Relatório de investigação BPE recebido em resumo; elegibilidade do GGUF ainda não comprovada.**
  - **Agente 1:** determinar documentalmente se o tokenizer do GGUF exato satisfaz os requisitos da origem: BPE, merges disponíveis, pelo menos metade dos IDs recuperados, inversões <= 1% e semântica de IDs `CONTROL | USER_DEFINED`. Distinguir tokenizer público upstream de metadados realmente atribuíveis ao GGUF.
  - **Agente 2:** mapear a cadeia do patch 0013 no fork: criação de subset `IQ4_XS`, `n_keep` versus `n_sel`, ativação MTP `n_outputs==1`, cache por buffer, scatter `-INFINITY`, fallbacks e memória adicional. Não repetir o trabalho de ordenação BPE do Agente 1.
  - **Critério de conclusão:** relatório com evidência por arquivo/linha/ref, decisão **confirmado / condicional / não comprovado**, e implicações concretas para `model.output` IQ4_XS. Se a ordenação dos merges não puder ser comprovada com fontes públicas, encerrar como **não comprovado**, sem solicitar arquivo local, dump ou teste.
  - **Referência existente:** [contrato de subset IQ4_XS](research/mtp-subset-iq4xs-contrato.md).

- [x] **P0.2 — Relatórios Q8_0/FA recebidos em resumo; prova local condicional e port ainda proposto.**
  - **Agente 3:** comparar **apenas por leitura** as expressões do staging `dequantize_block_q8_0_f16` e do carregamento `ggml_cuda_fattn_dequantize_q8_0_chunk`; analisar FP16 `__hmul2`, conversão de int8, escala, arredondamento, representação de `-0`, subnormais e FTZ, sem afirmar identidade de ISA não verificada.
  - **Agente 4:** mapear a integração específica para gfx1101: seletor `VEC/TILE` em `W=1..8`, tipos K/V, `ggml_cuda_fattn_tile_type`, instâncias, launcher e `get_alloc_size`; incluir guard para pares mistos, layout, BF16 e fallback F16, com escopo mínimo de verify. Não repetir a prova aritmética do Agente 3.
  - **Critério de conclusão:** tabela de invariantes e divergências potenciais por operador, e matriz `selector -> instância -> leitura -> scratch`, separando equivalência local de equivalência completa dos logits e do MTP. Qualquer hipótese de diferença de precisão deve permanecer assinalada como tal.
  - **Referência existente:** [FA TILE e KV nativo no gfx1101](research/fa-verify-tile-kv-gfx1101.md).

## Sequência de revisão e dependências

1. **Agente 1 -> Agente 2:** a prova ou limitação sobre merges/tokens especiais define a elegibilidade real do subset; Agente 2 pode documentar dependências em paralelo, mas não marcar viabilidade como confirmada antes disso.
2. **Agente 3 -> Agente 4:** a equivalência do carregamento Q8_0 determina a força da conclusão sobre pureza em verify; Agente 4 pode mapear os caminhos em paralelo, mas não afirmar bit-identidade de resultados.
3. **Assistente:** recebe relatórios (aqui vieram resumos), coteja divergências, devolve questões aos agentes quando necessário e incorpora somente achados e ressalvas sustentados em `research/`.
4. **Estado:** quatro resumos entregues e revisados; permanecem pendências P0 e P1. Nenhum trabalho novo foi iniciado em segundo plano.

## Entregas e acompanhamentos

| Agente | Missão | Entrega proposta | Estado |
| --- | --- | --- | --- |
| 1 | BPE, merges, atributos do tokenizer do GGUF | `RELATORIO-R05-BPE-GGUF.md` | [x] Resumo recebido; documento integral não anexado |
| 2 | Contrato patch 0013 e subset IQ4_XS | `RELATORIO-R05-MTP-SUBSET.md` | [x] Resumo recebido; documento integral não anexado |
| 3 | Equivalência FP16 do dequant Q8_0 | `RELATORIO-R05-Q8-ROUNDING.md` | [x] Resumo recebido; documento integral não anexado |
| 4 | Guardas/dispatch e alocação de FA verify | `RELATORIO-R05-FA-CONTRATO.md` | [x] Resumo recebido; documento integral não anexado |

**Plano e prompts de encaminhamento:** [research/RODADA-05-PLANO-AGENTES.md](research/RODADA-05-PLANO-AGENTES.md).

## Limites inegociáveis

- **Somente pesquisa estática e pública:** repositórios, código, docs, metadados e provas matemáticas. Sem execução de scripts, builds, benchmarks, testes reais/locais, GPU na nuvem, profiler, dumps ou pedido de logs.
- **Zero edição de kernels pelo assistente ou agentes nesta etapa.** Não editar `master`. Documentação somente na `deep-research`.
- Toda afirmação identificada como **código confirmado**, **cálculo teórico**, **hipótese** ou **lacuna**; nenhum ganho de tokens/s inventado.
- Metadados de outros GGUFs não substituem os do `RCO-IQ3_XXS` selecionado.
- As tarefas históricas foram respondidas em resumo; os novos itens pendentes requerem designação e entrega dos agentes, não execução automática.
