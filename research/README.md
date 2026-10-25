# Pesquisa de otimizações para RX 7800 XT (gfx1101)

Este diretório reúne propostas independentes para avaliar a integração seletiva de recursos de `stew675/llama-cpp-rdna-boosts` no `carlaun12/llama.gfx1101`, com foco em Qwen3.8 baseado na arquitetura Qwen3.5.

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
| [mmvq-q4k-q6k-vdr.md](mmvq-q4k-q6k-vdr.md) | MMVQ, VDR e decode quantizado | 0007 |
| [gdn-chunked-gfx1101.md](gdn-chunked-gfx1101.md) | GDN chunked FP32 e BF16/WMMA | 0003 |
| [flash-attention-kv-nativo.md](flash-attention-kv-nativo.md) | Flash Attention e cache KV nativo | 0004/0005 |
| [mmb-gemm-quantizado.md](mmb-gemm-quantizado.md) | MMB BF16-WMMA de prefill | 0006 |
| [fusoes-gdn-conv-moe.md](fusoes-gdn-conv-moe.md) | Fusões de GDN, convolução, norm e MoE | 0008/0010 |
| [mtp-adaptativo.md](mtp-adaptativo.md) | Profundidade especulativa adaptativa | 0002 |
| [mtp-vocabulario-reduzido.md](mtp-vocabulario-reduzido.md) | Head MTP com vocabulário reduzido | 0013 |
| [cache-especialistas-moe.md](cache-especialistas-moe.md) | Cache de especialistas com offload | 0009 |

## Estado da pesquisa

- **Em pesquisa:** as oito propostas estão registradas, mas nenhum candidato foi executado em gfx1101.
- **Referência do destino examinada:** `31288c9c66e59377f7788d920678a565bb89dd37`.
- **Referência da origem:** `v15-3f03b1772-r137`.
- **Data de abertura:** 2026-10-25.
- O caminho Qwen4Exp/QSA foi mantido fora da fila inicial porque não corresponde ao escopo principal de Qwen3.8 com arquitetura Qwen3.5. Poderá receber um documento próprio se virar alvo concreto.

As prioridades indicam ordem de investigação, não ranking comprovado de ganhos.
