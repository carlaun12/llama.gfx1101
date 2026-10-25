# Pesquisa de otimizações para RX 7800 XT (gfx1101)

Este diretório reúne propostas independentes para avaliar a integração seletiva de recursos de `stew675/llama-cpp-rdna-boosts` no `carlaun12/llama.gfx1101`, com foco em Qwen3.8 baseado na arquitetura Qwen3.5.

## Modelo-alvo selecionado (25/10/2026)

**`Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`**, publicado por `ajgazin` no Hugging Face, foi definido pelo usuário como GGUF principal para a RX 7800 XT gfx1101.

- **9,7 GiB de pesos GGUF**; head MTP embutido em `blk.64`. A VRAM de pico na GPU não foi medida.
- **Quantização RCO mista:** 97 IQ3_S, 83 IQ3_XXS, 72 IQ2_S, 33 IQ4_XS, 32 IQ2_XS, 30 IQ2_XXS, apenas 19 Q4_K; quantidade de tensores não é peso por byte nem tempo de kernel.
- **Arquitetura:** 48 camadas GDN + 16 full attention, head-256 e GQA com quatro heads KV; não é MoE.
- A ordem abaixo se refere **a esse GGUF**, não ao ranking genérico inicial.

### Sequência recomendada para este GGUF

| Prioridade | Linha de trabalho | Critério de avanço |
| --- | --- | --- |
| 0 | Leitura documental de arquitetura, quantização, MTP e políticas de dispatch | Metadados públicos e código-fonte congelado |
| 1 | [MMVQ IQ misto RCO](mmvq-iq-mistos-rco.md) e [MMQ IQ para prefill](mmq-unpack-iq-rco.md) | Separar decode/verify e prefill; mapear elegibilidade por tensor/shape |
| 2 | [GDN chunked FP32](gdn-chunked-gfx1101.md) | Estudar recorrência, snapshots e dependências do grafo |
| 3 | [MTP adaptativo](mtp-adaptativo.md) e [head reduzido](mtp-vocabulario-reduzido.md) | Verificar contratos, custos teóricos e dependências do head embutido |
| 4 | [Flash Attention e KV nativo](flash-attention-kv-nativo.md) | Relevância em contexto longo e preservação da pureza de verify |
| 5 | [Fusões GDN/norm/conv](fusoes-gdn-conv-moe.md) | Subgrafo presente e ainda não fundido |
| 6 | [MMVQ Q4_K VDR4](mmvq-q4k-q6k-vdr.md) e [MMB](mmb-gemm-quantizado.md) | Aplicabilidade por tipo/shape e análise de custo sem execução |
| Fora do escopo | [Cache de especialistas MoE](cache-especialistas-moe.md) | Exige escolher outro GGUF MoE |

**<a name="profile"></a>Perfil técnico e custos teóricos de KV:** [MODELO-ALVO.md](MODELO-ALVO.md). [Origem dos metadados e tipos](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF); [configuração oficial Qwen](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/config.json).

**Escopo exclusivo:** pesquisa remota por documentos, repositórios públicos, leitura de código e demonstrações matemáticas. Não requisitar execução na máquina do usuário, logs, benchmarks, scripts de teste, builds ou instrumentação. A seção **Resultados** é dedicada aos resultados documentais, conclusões e descobertas, não a medições locais. Benchmarks públicos podem ser citados como evidência externa com hardware, fonte e condições, nunca como medições em gfx1101.


## Regras deste repositório de pesquisa

1. **Uma proposta por arquivo `.md`**, com nome que identifique a otimização.
2. Cada documento contém: **Sobre a proposta**, **Ganhos estimados**, **Resultados da pesquisa**, **Descobertas e observações**, **Riscos e fallback**, **Verificação documental**, **Próximos passos**, **Referências** e **Histórico**. Títulos históricos podem permanecer; o conteúdo novo deve seguir esta metodologia.
3. **Estimativas não são resultados.** Sem benchmark na RX 7800 XT, não atribuir porcentagem de ganho ao gfx1101. Estimativas qualitativas devem declarar hipóteses, limitações e regime de carga.
4. Resultados incluem provas de equivalência, limites matemáticos, diferenças de código comprovadas, mapas de dependência, estimativas condicionais e riscos. Especificar fontes, SHAs e hipóteses. Não preencher campos de ganho observado sem evidência externa verificável, nunca inventar speedup.
5. Resultados de gfx1100, gfx1151 ou gfx1201 são **evidências externas**, nunca medidas de gfx1101.
6. Os quatro agentes desta pesquisa podem consultar repositórios e documentação remota, mas **não têm acesso à máquina local nem ambiente de execução de GPU na nuvem**. Não atribuir a eles testes, benchmarks ou builds que não ocorreram.
7. As propostas nesta branch são documentação e análise; não significam implementação, aprovação, alteração da `master` ou adoção como default.

## Propostas

| Arquivo | Tema | Blocos da origem |
| --- | --- | --- |
| [mtp-subset-iq4xs-contrato.md](mtp-subset-iq4xs-contrato.md) | Contrato de patch 0013 e subset IQ4_XS do head compartilhado | origem 0013 / auditoria profunda |
| [fa-verify-tile-kv-gfx1101.md](fa-verify-tile-kv-gfx1101.md) | Leitura TILE nativa Q8_0/BF16 na banda de verify W1..8 | origem 0004/0005 / auditoria profunda |
| [mmq-unpack-iq-rco.md](mmq-unpack-iq-rco.md) | Unpack de sinais de IQ2/IQ3 nos tiles de MMQ/pre-fill | quarta auditoria, caminhos próprios do MMQ |
| [mmvq-iq-mistos-rco.md](mmvq-iq-mistos-rco.md) | MMVQ, MMQ e vetores IQ do RCO | investigação do alvo |
| [mmvq-q4k-q6k-vdr.md](mmvq-q4k-q6k-vdr.md) | MMVQ, VDR e decode quantizado | 0007 |
| [gdn-chunked-gfx1101.md](gdn-chunked-gfx1101.md) | GDN chunked FP32 e BF16/WMMA | 0003 |
| [flash-attention-kv-nativo.md](flash-attention-kv-nativo.md) | Flash Attention e cache KV nativo | 0004/0005 |
| [mmb-gemm-quantizado.md](mmb-gemm-quantizado.md) | MMB BF16-WMMA de prefill | 0006 |
| [fusoes-gdn-conv-moe.md](fusoes-gdn-conv-moe.md) | Fusões de GDN, convolução, norm e MoE | 0008/0010 |
| [mtp-adaptativo.md](mtp-adaptativo.md) | Profundidade especulativa adaptativa | 0002 |
| [mtp-vocabulario-reduzido.md](mtp-vocabulario-reduzido.md) | Head MTP com vocabulário reduzido | 0013 |
| [cache-especialistas-moe.md](cache-especialistas-moe.md) | Cache de especialistas com offload | 0009 |


## Segunda rodada de trabalho (análise remota)

As quatro frentes de investigação foram executadas como análises de código e documentação nesta conversa. Não há processos autônomos em execução persistente, nem acesso a ROCm local ou a GPU em nuvem. Os resultados foram inseridos nos arquivos das propostas, com distinção explícita entre observações de código, hipóteses e resultados medidos.

| Frente de análise | Entrega inicial | Registro |
| --- | --- | --- |
| 1. Diferenças e dependências | Identificação dos seletores MMVQ separados, do parâmetro `n_rs_batch` e do contrato de staging FA | MMVQ, GDN e Flash Attention |
| 2. Kernels gfx1101 | Pareamento obrigatório entre dot Q4_K VDR4, VDR host/device e K-split; política de warps como experiência distinta | MMVQ |
| 3. Qwen3.5 e recorrência | Condições de GDN chunked FP32, tail sequencial, snapshots e riscos de BF16/WMMA | GDN e MTP |
| 4. Correção por análise | Invariantes matemáticos, ordem de redução, contratos de rollback e alcance real dos guards/dispatchers | Metodologia abaixo |

### Metodologia de pesquisa documental (a partir de 25/10/2026)

**Não realizar nem solicitar testes reais, comandos locais, GPU na nuvem, builds, benchmarks, logs ou scripts de execução.** Comparações de performance disponíveis publicamente permanecem dados de terceiros; não são resultados reproduzidos nesta pesquisa.

1. Fixar os commits exatos de `carlaun12/llama.gfx1101` e `stew675/llama.cpp` para cada comparação, com URL do arquivo e símbolo relevante.
2. Extrair formatos e shapes do manifesto público; separar contagem de tensores, bytes teóricos e custo em operações. Não inferir dominância temporal apenas por contagem.
3. Classificar cada proposta como **correção/equivalência verificável em código**, **viabilidade arquitetural**, **otimização plausível** ou **benefício numérico desconhecido**.
4. Demonstrar, quando possível, bounds de inteiros, layouts, dependências de estado, contratos de cache e alcance de `#if`/dispatch com base no código. Se uma propriedade depende do compilador HIP, declarar essa dependência.
5. Comparar caminhos densos `MUL_MAT`, roteados `MUL_MAT_ID` e `FLASH_ATTN_EXT` separadamente. Não transferir limites ou resultados de um dispatcher para outro.
6. Para logits, MTP e recorrência, identificar por inspeção possíveis diferenças de arredondamento/redução entre `W=1` e `W=2..8` ou entre sequências. Não alegar pureza observada.
7. Apresentar ganhos somente como **estimativas teóricas condicionais** e, se houver publicação externa relevante, reportar fonte, hardware e carga exatamente, sem extrapolar percentuais para gfx1101.
8. Ao atualizar um `.md`, utilizar **Resultados** para descobertas confirmadas da pesquisa, separar conjecturas e registrar o histórico. Toda proposta precisa permitir implementação seletiva e fallback, caso seja adotada futuramente.

**Rodada documental de 25/10/2026:** a análise de [MMVQ para RCO IQ misto](mmvq-iq-mistos-rco.md) compara `apply_ksigns`, `ggml_cuda_mul_small`, domínios das tabelas `IQ2/IQ3` e o desvio de escopo entre `MUL_MAT` e `MUL_MAT_ID`.

## Terceira rodada — quatro relatórios recebidos e revisados

Em 25/10/2026 foram recebidos **quatro** relatórios externos: GDN chunked FP32, MTP integrado, Flash Attention/análise arquitetural e auditoria aprofundada de IQ3/IQ2. A quarta auditoria confirmou um caminho separado de **unpack no MMQ** em cinco helpers de IQ2/IQ3, além da proposta já documentada de MMVQ.

A revisão cruzada e as divergências de quantização, memória e aplicabilidade foram registradas em [REVISAO-AGENTES-2026-10-25.md](REVISAO-AGENTES-2026-10-25.md). Os achados aceitos foram sintetizados nos documentos [GDN](gdn-chunked-gfx1101.md), [MTP adaptativo](mtp-adaptativo.md), [MTP subset](mtp-vocabulario-reduzido.md), [Flash Attention](flash-attention-kv-nativo.md), [MMB](mmb-gemm-quantizado.md), [MMVQ IQ misto](mmvq-iq-mistos-rco.md) e **[MMQ unpack IQ](mmq-unpack-iq-rco.md)**.

**Escopo mantido:** pesquisa remota somente. Não pedir ao usuário testes, medições, hashes, logs, builds, instrumentação nem GPU. Os capítulos de benchmark nos relatórios dos agentes foram tratados como notas históricas, **não tarefas do projeto**.



## Quarta rodada — plano de investigação focalizado

Foram definidas quatro missões documentais a partir da revisão dos quatro agentes. O trabalho **ainda depende da entrega dos relatórios**, sem processos autônomos iniciados nesta conversa.

**[Abrir plano completo da quarta rodada](RODADA-04-PLANO.md)** — tarefas, repositórios/commits, perguntas decisórias, evidências requeridas e formato de entrega.

Frentes: **MTP head real do RCO**; **dispatch MMQ para IQ misto**; **GDN chunked e rollback**; **Flash Attention/KV em verify MTP**. Nenhuma envolve execução, benchmark ou alteração de kernels.

## Rodada 04 — quatro relatórios resumidos consolidados (25/10/2026)

Os quatro agentes devolveram **resumos** das missões [MTP](mtp-adaptativo.md), [MMQ](mmq-unpack-iq-rco.md), [GDN](gdn-chunked-gfx1101.md) e [Flash Attention](flash-attention-kv-nativo.md). A análise cruzada encontrou um resultado decisivo: o MTP do GGUF RCO provavelmente compartilha `model.output` **IQ4_XS**, em vez de usar um LM head Q6_K separado. Também delimitou a elegibilidade de MMQ acima de 128 colunas e a transição Q8_0 `VEC` -> `TILE` entre W2/W3.

**[Resultados, graus de evidência e pendências da Rodada 04](RODADA-04-RESULTADOS.md)**.

**Nota de proveniência:** foram coladas conclusões e descrições dos documentos, mas não os quatro arquivos `RELATORIO-R04-*.md` integrais. Não afirmar leitura de trechos ausentes. A auditoria independente da rodada consultou o manifesto RCO público e fontes dos dois repositórios; não envolveu execução nem benchmark.

## Aprofundamento — subset IQ4_XS e FA nativo para verify (25/10/2026)

A pesquisa avançou de hipóteses gerais para **contratos de implementação específicos**, ainda apenas documentais:

- **[Patch 0013 no IQ4_XS](mtp-subset-iq4xs-contrato.md):** guard de ordenação de merges BPE (tolerância de 1% de inversões), adição de IDs de controle, cache por `n_keep/buffer_type`, ativação em contexto MTP com `n_outputs==1`, scatter de logits e custo adicional na VRAM.
- **[FA TILE nativo no gfx1101](fa-verify-tile-kv-gfx1101.md):** guard Q8_0 de chunks/stride, condição BF16 de hardware RDNA3, cálculo de scratch igual ao tipo realmente consumido e recorte hipotético W1..8 que não precisa importar a arena de prefill longo.

**Nenhuma das duas linhas já foi portada.** Não há benchmark nem confirmação dos atributos do tokenizer final do GGUF. Não confundir ausência de staging ou subset menor com ganho líquido garantido.

## Rodada 05 — duas prioridades, quatro missões

O projeto agora registra tarefas na raiz em **[todo.md](../todo.md)**. A Rodada 05 está dividida em duas linhas P0, com dois agentes em cada uma: **compatibilidade BPE para o subset IQ4_XS do patch 0013** e **equivalência de arredondamento Q8_0 / contrato de FA verify W1..8**.

**[Abrir prompts dos quatro agentes](RODADA-05-PLANO-AGENTES.md).** Estado histórico: quatro instruções encaminhadas; os quatro agentes devolveram resumos. O acompanhamento atualizado está em [RODADA-05-RESULTADOS.md](RODADA-05-RESULTADOS.md). O assistente atua somente na coordenação, revisão e documentação das entregas.

## Rodada 05 — quatro resumos recebidos e revisão cruzada

Os Agentes 1–4 apresentaram seus resultados de **compatibilidade BPE**, **integração IQ4_XS/patch 0013**, **equivalência por elemento Q8_0** e **contrato de FA verify W1..8**. As conclusões foram consolidadas em **[RODADA-05-RESULTADOS.md](RODADA-05-RESULTADOS.md)**, incluindo graus de evidência e pendências: ordenação de merges do GGUF, **risco LoRA na troca do tensor do head**, efeitos de FTZ/subnormais e diferenças numéricas de BF16 nativo.

**[todo.md](../todo.md)** atualizado com quatro relatórios recebidos **em resumo** e as responsabilidades seguintes dos agentes. Os `RELATORIO-R05-*.md` completos anunciados não foram disponibilizados nesta conversa. O assistente mantém papel de coordenação e revisão; novos prompts de agentes são entregues diretamente no chat.

## Nova frente documental — MMVQ do perfil recebido

A partir de imagem fornecida pelo usuário, a pesquisa de MMVQ IQ foi organizada em [`docs/experiments_2/`](../docs/experiments_2/README.md), com fichas por quantização (`IQ2_S`, `IQ3_S`, `IQ3_XXS`, `IQ4_XS`). O perfil externo é transcrito com ressalva de proveniência: **não é medição confirmada da RX 7800 XT ou do GGUF selecionado**.

Os quatro agentes receberão suas tarefas **diretamente no chat**; esta atualização registra apenas a documentação inicial e as responsabilidades, sem novos resultados de pesquisa técnica.

## Estado da pesquisa

- **Em pesquisa:** doze propostas estão registradas, mas nenhum candidato foi executado em gfx1101.
- **Referência do destino examinada:** `31288c9c66e59377f7788d920678a565bb89dd37`.
- **Referência da origem:** `v15-3f03b1772-r137`.
- **Data de abertura:** 2026-10-25.
- O caminho Qwen4Exp/QSA foi mantido fora da fila inicial porque não corresponde ao escopo principal de Qwen3.8 com arquitetura Qwen3.5. Poderá receber um documento próprio se virar alvo concreto.

As prioridades antigas em cada documento são históricas; a ordem vigente para o GGUF selecionado está no topo deste índice. Nenhum ranking se baseia em ganho já comprovado.
