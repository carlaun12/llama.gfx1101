# TODO — pesquisa Swift RCO / Radeon RX 7800 XT gfx1101

**Atualizado:** 2026-10-25
**Branch exclusiva para documentos:** `deep-research` — **não alterar `master`**.
**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` (`ajgazin`, RCO-IQ3_XXS) em RX 7800 XT, gfx1101, 16 GiB.
**Modo de trabalho:** quatro agentes externos pesquisam; o assistente **coordena as tarefas, revisa os relatórios e consolida**. O assistente não substitui agentes como pesquisador. Nenhum agente foi acionado automaticamente por este registro.

## P0 — prioridades decididas

- [ ] **P0.1 — Compatibilidade BPE do GGUF com o guard do patch 0013.**
  - **Agente 1:** determinar documentalmente se o tokenizer do GGUF exato satisfaz os requisitos da origem: BPE, merges disponíveis, pelo menos metade dos IDs recuperados, inversões <= 1% e semântica de IDs `CONTROL | USER_DEFINED`. Distinguir tokenizer público upstream de metadados realmente atribuíveis ao GGUF.
  - **Agente 2:** mapear a cadeia do patch 0013 no fork: criação de subset `IQ4_XS`, `n_keep` versus `n_sel`, ativação MTP `n_outputs==1`, cache por buffer, scatter `-INFINITY`, fallbacks e memória adicional. Não repetir o trabalho de ordenação BPE do Agente 1.
  - **Critério de conclusão:** relatório com evidência por arquivo/linha/ref, decisão **confirmado / condicional / não comprovado**, e implicações concretas para `model.output` IQ4_XS. Se a ordenação dos merges não puder ser comprovada com fontes públicas, encerrar como **não comprovado**, sem solicitar arquivo local, dump ou teste.
  - **Referência existente:** [contrato de subset IQ4_XS](research/mtp-subset-iq4xs-contrato.md).

- [ ] **P0.2 — Equivalência numérica do carregamento nativo Q8_0 versus staging F16.**
  - **Agente 3:** comparar **apenas por leitura** as expressões do staging `dequantize_block_q8_0_f16` e do carregamento `ggml_cuda_fattn_dequantize_q8_0_chunk`; analisar FP16 `__hmul2`, conversão de int8, escala, arredondamento, representação de `-0`, subnormais e FTZ, sem afirmar identidade de ISA não verificada.
  - **Agente 4:** mapear a integração específica para gfx1101: seletor `VEC/TILE` em `W=1..8`, tipos K/V, `ggml_cuda_fattn_tile_type`, instâncias, launcher e `get_alloc_size`; incluir guard para pares mistos, layout, BF16 e fallback F16, com escopo mínimo de verify. Não repetir a prova aritmética do Agente 3.
  - **Critério de conclusão:** tabela de invariantes e divergências potenciais por operador, e matriz `selector -> instância -> leitura -> scratch`, separando equivalência local de equivalência completa dos logits e do MTP. Qualquer hipótese de diferença de precisão deve permanecer assinalada como tal.
  - **Referência existente:** [FA TILE e KV nativo no gfx1101](research/fa-verify-tile-kv-gfx1101.md).

## Sequência de revisão e dependências

1. **Agente 1 -> Agente 2:** a prova ou limitação sobre merges/tokens especiais define a elegibilidade real do subset; Agente 2 pode documentar dependências em paralelo, mas não marcar viabilidade como confirmada antes disso.
2. **Agente 3 -> Agente 4:** a equivalência do carregamento Q8_0 determina a força da conclusão sobre pureza em verify; Agente 4 pode mapear os caminhos em paralelo, mas não afirmar bit-identidade de resultados.
3. **Assistente:** recebe os quatro relatórios completos, coteja divergências, devolve questões para os agentes quando necessário e só então incorpora achados sustentados em `research/`.
4. **Estado:** quatro tarefas especificadas, **aguardando encaminhamento aos agentes**. O registro não inicia trabalhos externos em segundo plano.

## Entregas e acompanhamentos

| Agente | Missão | Entrega proposta | Estado |
| --- | --- | --- | --- |
| 1 | BPE, merges, atributos do tokenizer do GGUF | `RELATORIO-R05-BPE-GGUF.md` | [ ] Aguardando agente |
| 2 | Contrato patch 0013 e subset IQ4_XS | `RELATORIO-R05-MTP-SUBSET.md` | [ ] Aguardando agente |
| 3 | Equivalência FP16 do dequant Q8_0 | `RELATORIO-R05-Q8-ROUNDING.md` | [ ] Aguardando agente |
| 4 | Guardas/dispatch e alocação de FA verify | `RELATORIO-R05-FA-CONTRATO.md` | [ ] Aguardando agente |

**Plano e prompts de encaminhamento:** [research/RODADA-05-PLANO-AGENTES.md](research/RODADA-05-PLANO-AGENTES.md).

## Limites inegociáveis

- **Somente pesquisa estática e pública:** repositórios, código, docs, metadados e provas matemáticas. Sem execução de scripts, builds, benchmarks, testes reais/locais, GPU na nuvem, profiler, dumps ou pedido de logs.
- **Zero edição de kernels pelo assistente ou agentes nesta etapa.** Não editar `master`. Documentação somente na `deep-research`.
- Toda afirmação identificada como **código confirmado**, **cálculo teórico**, **hipótese** ou **lacuna**; nenhum ganho de tokens/s inventado.
- Metadados de outros GGUFs não substituem os do `RCO-IQ3_XXS` selecionado.
- As tarefas para os agentes são **instruções prontas para envio**, não alegações de que estão em execução.
