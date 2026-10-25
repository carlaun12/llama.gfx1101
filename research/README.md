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
| 0 | Baseline de residência real na GPU; `none` contra `draft-mtp`; cobertura e pureza | Relatos do usuário, hashes e logs de execução |
| 1 | [MMVQ IQ misto RCO](mmvq-iq-mistos-rco.md) | Identificar por peso/shape quais IQ dominam decode e o dispatch que executa |
| 2 | [GDN chunked FP32](gdn-chunked-gfx1101.md) | Correção de prefill e rollback MTP; medir antes de BF16 |
| 3 | [MTP adaptativo](mtp-adaptativo.md) e [head reduzido](mtp-vocabulario-reduzido.md) | Aceitação real e orçamento de VRAM do head embutido |
| 4 | [Flash Attention e KV nativo](flash-attention-kv-nativo.md) | Relevância em contexto longo e preservação da pureza de verify |
| 5 | [Fusões GDN/norm/conv](fusoes-gdn-conv-moe.md) | Subgrafo presente e ainda não fundido |
| 6 | [MMVQ Q4_K VDR4](mmvq-q4k-q6k-vdr.md) e [MMB](mmb-gemm-quantizado.md) | Ganho comprovável sobre os poucos tensores compatíveis |
| Fora do escopo | [Cache de especialistas MoE](cache-especialistas-moe.md) | Exige escolher outro GGUF MoE |

**<a name="profile"></a>Perfil técnico e custos teóricos de KV:** [MODELO-ALVO.md](MODELO-ALVO.md). [Origem dos metadados e tipos](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF); [configuração oficial Qwen](https://huggingface.co/Qwen/Qwen3.8-27B/blob/main/config.json).

**Limites:** os agentes não têm acesso ao arquivo local, à máquina do usuário ou a uma GPU em nuvem. Estimativa arquitetural ou qualidade publicada não é benchmark de gfx1101. Os resultados de A/B devem comparar **o mesmo GGUF**; a ficha do publicador compara a quantização com BF16, uma pergunta diferente.


## Regras deste repositório de pesquisa

1. **Uma proposta por arquivo `.md`**, com nome que identifique a otimização.
2. Cada documento contém: **Sobre a proposta**, **Ganhos estimados**, **Resultados**, **Descobertas e observações**, **Riscos, correção e fallback**, **Plano de validação**, **Próximos passos**, **Referências** e **Histórico**.
3. **Estimativas não são resultados.** Sem benchmark na RX 7800 XT, não atribuir porcentagem de ganho ao gfx1101. Estimativas qualitativas devem declarar hipóteses, limitações e regime de carga.
4. Resultados somente após coleta efetiva de dados, com commits, GGUF/hash, quantização, flags, GPU, modelo, método e logs associados.
5. Resultados de gfx1100, gfx1151 ou gfx1201 são **evidências externas**, nunca medidas de gfx1101.
6. Os quatro agentes desta pesquisa podem consultar repositórios e documentação remota, mas **não têm acesso à máquina local nem ambiente de execução de GPU na nuvem**. Não atribuir a eles testes, benchmarks ou builds que não ocorreram.
7. As propostas nesta branch são documentação e análise; não significam implementação, aprovação, alteração da `master` ou adoção como default.

## Propostas

| Arquivo | Tema | Blocos da origem |
| --- | --- | --- |
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
| 4. Correção/benchmarks | Contrato de proveniência e critérios de A/A, W=1..8, P>=4096, fallback e benchmark A/B | Protocolo abaixo |

### Protocolo mínimo de resultados

Os agentes **não podem executar** comandos na máquina do usuário. O usuário pode executar depois os testes a partir da sua instalação ou fornecer logs, que devem ser anexados ao respectivo documento.

Antes de aceitar um resultado, registrar:

1. Commit completo da versão A e B, Git dirty state, build flags reais de gfx1101, ROCm/HIP e versão do driver.
2. Hash de cada GGUF, quantização, arquitetura, contexto real, KV K/V, camadas efetivamente offloaded, batch/ubatch e flags de especulação.
3. Sequência A/A (mesmo binário duas vezes) para medir ruído e determinismo do instrumento; depois A/B intercalado em múltiplos processos, com aquecimento.
4. Separar `llama-bench` pp512/pp2048/pp8192, decode tg128/tg512 e contexto previamente utilizado. Não assumir que `-ngl 99` significa residência total.
5. Confirmar que o kernel novo foi **de fato selecionado**, por logs/instrumentação de dispatcher, não só pelo código compilado.
6. `test-backend-ops` nas operações tocadas; KLD/perplexidade quando houver mudança em matemática; prova de `W=1..8` com `P>=4096` onde houver band/verify, além do caso P=256 como controle negativo.
7. Guardar amostras brutas, mediana, dispersão robusta, IC quando houver repetições suficientes, VRAM de pico observado e texto/hash de referência.
8. Não preencher a coluna de ganhos observados apenas por estimativa, cálculo de largura de banda ou resultados de gfx1100/gfx1151/gfx1201.

O teste de prefill da origem adotou limites de mean KLD <=0,005 e same-top-p >=98% **dentro da família de kernel e com controle A/A estável**. Esses números não devem ser importados cegamente quando a variância intrínseca de um GGUF já ultrapassa o limiar.

**Ferramentas existentes verificadas no destino:** `llama-bench` com `-o jsonl` e `-d` para profundidade; `test-backend-ops`. Um probe W=1..8 equivalente ao da origem não foi identificado como componente compilado do destino na primeira auditoria; será necessário portar/adaptar o instrumento antes de afirmar pureza.


## Estado da pesquisa

- **Em pesquisa:** nove propostas estão registradas, mas nenhum candidato foi executado em gfx1101.
- **Referência do destino examinada:** `31288c9c66e59377f7788d920678a565bb89dd37`.
- **Referência da origem:** `v15-3f03b1772-r137`.
- **Data de abertura:** 2026-10-25.
- O caminho Qwen4Exp/QSA foi mantido fora da fila inicial porque não corresponde ao escopo principal de Qwen3.8 com arquitetura Qwen3.5. Poderá receber um documento próprio se virar alvo concreto.

As prioridades antigas em cada documento são históricas; a ordem vigente para o GGUF selecionado está no topo deste índice. Nenhum ranking se baseia em ganho já comprovado.
