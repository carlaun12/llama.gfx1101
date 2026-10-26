# TODO RED — prioridades de otimização RX 7800 XT (gfx1101)

**Atualizado:** 2026-10-25. **Branch de referência:** `experiment_2-1`.
**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`; Radeon RX 7800 XT (16 GiB), RDNA3 `gfx1101`.
**Status:** fila **documental** de investigações; nenhum ganho confirmado na GPU-alvo. Não executar nem pedir testes, benchmarks, compilações, scripts, perfis ou GPU local/remota. Não modificar kernels nesta etapa; não alterar `master`.

## Ranking por impacto potencial no modelo-alvo

**Estimativas qualitativas, não previsão de tokens/s.** O impacto final depende de gargalos reais ainda não estabelecidos, seleção de kernels, tráfego, memória disponível e taxa de aceitação MTP. O ranking privilegia **tokens/s efetivos com MTP** e considera separadamente esforço e portabilidade.

| Ordem | Ideia | Impacto potencial | Esforço/risco | Condição principal |
| --- | --- | --- | --- | --- |
| **1** | **MTP + n-gramas** | Muito alto | Alto | Drafts aceitos compensarem custo de gerar/verificar/rollback |
| **2** | **MMVQ com quatro linhas por bloco e várias colunas** | Alto | Médio–alto | Verify `W=2..8` alcançar MMVQ, com reuso real e VGPR controlado |
| **3** | **Fusões que produzem `q8_1` junto de RMSNorm/SwiGLU** | Alto | Alto | Fusões ainda ausentes, com equivalência numérica e dependências corretas |
| **4** | **ReplaySSM e streaming de KV** | Alto, sobretudo contexto longo | Muito alto | Estado GDN, rollback, memória e KV consistentes |
| **5** | **Ajustar waves/registradores no MMVQ** | Médio–alto | Médio | Parâmetros adequados a RDNA3 e pressão de VGPR/ocupação |
| **6** | **Sobrepor projeções independentes** | Médio | Alto | Independência de dados e segurança de streams/graphs |
| **7** | **Tiles MMQ mais estreitos** | Médio no prefill | Médio | Shapes pequenos alcançarem MMQ e não terem kernel melhor |
| **8** | **Atenção/GDN com WMMA gfx12** | Incerto em gfx1101 | Muito alto | Exigiria desenho próprio para `gfx11`, não port direto RDNA4 |
| **9** | **Barreiras restritas à LDS** | Baixo–médio, condicional | Alto | Prova de sincronização e inexistência de dependências globais |
| **10** | **Reinterpretar bits de acumuladores inteiros e subtrair constante** | Baixo/incerto | Médio–alto | Prova de domínio matemático, overflow e semântica ISA gfx1101 |

### Prioridade por fase de execução

| Objetivo | 1ª linha | 2ª linha | 3ª linha |
| --- | --- | --- | --- |
| **Tokens/s efetivos com MTP** | MTP + n-gramas | MMVQ multicoluna/quatro linhas | ReplaySSM / KV |
| **Decode W=1** | Fusões `q8_1` | Waves/registradores MMVQ | MMVQ multilinha, se houver reuso |
| **Prefill** | Tiles MMQ estreitos | Fusões `q8_1` | Waves/registradores |

**Distinção importante:** a prioridade **#1 é a maior oportunidade teórica de ganho sistêmico**, não a alteração mais barata ou segura. O reuso de IQ4_XS em W=2..8 e outras propostas de `docs/experiments_2/` já são alvos de pesquisa mais delimitados, enquanto MTP + n-gramas e ReplaySSM exigem desenho arquitetural.

## Quatro frentes para os agentes — pendentes de encaminhamento

Os prompts operacionais dos agentes devem ser disponibilizados **diretamente no chat**, não armazenados aqui como substitutos das instruções.

- [ ] **Agente 1 — MTP + n-gramas:** investigar arquitetura de propostas, custo teórico de geração/verify, critérios de aceitação, impacto do estado recorrente e fallback. Separar melhoria de aceitação de economia de execução, sem prometer 50 tokens/s.
- [ ] **Agente 2 — MMVQ multilinha/multicoluna:** documentar geometria com quatro linhas por bloco, reuso de pesos/ativações no verify, limites de VGPR/LDS e compatibilidade com `gfx1101`. Considerar os achados [Experiments 2 R03](experiments_2/05-RESULTADOS-R03.md).
- [ ] **Agente 3 — fusões `q8_1`:** mapear fusões RMSNorm/SwiGLU/quantização já presentes nesta branch, identificar operações realmente redundantes e exigir prova de dependências/arredondamento. Não reeditar fusões já existentes.
- [ ] **Agente 4 — ReplaySSM e KV:** desenhar documentalmente estados necessários para rollback de GDN (incluindo conv1d), KV e sincronização com MTP, custos de memória de 16 GiB e fallbacks seguros.

**Critério comum de entrega:** citações por arquivo e commit; classificar **confirmado em fonte**, **derivado matematicamente**, **condicional** e **não demonstrado**. A investigação cabe aos quatro agentes; o assistente coordena, revisa e documenta suas entregas. Nenhum agente é iniciado automaticamente por este registro.

## Não priorizar nesta etapa

- [ ] **Reutilização global de `q8_1`:** a imagem fornecida pelo usuário registra um **teto otimista estimado de ~0,49%**, não uma medição da 7800 XT; a complexidade não se justifica como P0.
- [ ] **Reinterpretar acumuladores por bits:** depende de prova de domínio e semântica ISA; manter abaixo das frentes de impacto mais alto.
- [ ] **Port direto de kernels WMMA gfx12:** RDNA4 não equivale a RDNA3 `gfx1101`.

## Evidências e limites

A imagem de ideias apresentada pelo usuário classificou as frentes como **não testadas**, **não adaptadas** ou **não medidas neste fluxo**. A fila acima **não implica validação empírica**. Os percentuais do perfil de “U” citados em [Experiments 2](experiments_2/README.md) não foram atribuídos comprovadamente à RX 7800 XT nem ao GGUF selecionado. A maior parcela de tempo de um kernel não prova que seu subtrecho seja acelerável.

**Sem alteração de `master` ou kernels.** Somente `docs/TODO_RED.md` foi criado neste registro.
