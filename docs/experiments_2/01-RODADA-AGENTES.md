# Rodada 1 de Experiments 2 — quatro agentes

**Base:** `carlaun12/llama.gfx1101`, branch `experiment_2-1`. **Não escrever em `master`.**

**Contexto fixo:** RX 7800 XT 16 GiB (`gfx1101`), GGUF alvo `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`. A imagem do usuário relata um perfil de “U” com **82–84%** da soma de tempos de kernels em MMVQ e participações `IQ3_S 22,5%`, `IQ3_XXS 20,8%`, `IQ2_S 18,0%`, `IQ4_XS 12,9%` dentro de MMVQ. **Essas medidas não foram atribuídas comprovadamente à GPU ou modelo alvo; nunca afirmar o contrário.**

**Regras:** pesquisa estática via arquivos públicos e metadados; sem executar nem solicitar GPU, testes, scripts, benchmarks, compilações, perfis, logs ou instruções locais. Relatórios devem distinguir prova, inferência e hipóteses, fornecer links e refs exatos, apontar riscos de corretude, e evitar estimar ganho em tokens/s. **Os prompts prontos são enviados no chat**; este documento é o registro de divisão, não um local obrigatório para copiá-los.

## Agente 1 — IQ3_S / IQ3_XXS em MMVQ

- Localizar os vec-dot respectivos em `ggml/src/ggml-cuda/vecdotq.cuh` **na branch exata** e conferir chamada a partir de `mmvq.cu`/`mmvq.cuh`.
- Identificar decompressão/unpack, sinais, grades, conversões, operações de dot, escalas e possíveis otimizações não presentes no branch.
- Comparar seletivamente implementação da origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`, **sem tratar como patch aplicável automaticamente**.
- Avaliar `apply_ksigns` e `ggml_cuda_mul_small` por equivalência e limites, mudanças pontuais e riscos de pressão de registros.
- **Entregável:** `RELATORIO-E2-IQ3-MMVQ.md`. Não editar kernels.

## Agente 2 — IQ2_S versus IQ2_XS / IQ2_XXS

- Mapear diferença entre rotinas IQ2 no branch e quantidades/tipos do GGUF alvo.
- Localizar a participação específica de `IQ2_S` na hipótese de 18% e explicitar que ela veio **da imagem**, não de medições próprias.
- Analisar criticamente `apply_ksigns`, extração de sinal, custo de lookup, escalas, indexação e como os valores quantizados são processados na GPU.
- Produzir **uma proposta mínima de mudança de código, documental**, preservando índices/layout/numérica e sem misturar mudanças de warp, VDR ou tile.
- **Entregável:** `RELATORIO-E2-IQ2S-MMVQ.md`. Não editar kernels.

## Agente 3 — IQ4_XS, output head e tráfego teórico

- Conferir tipo/shape de `output.weight` **no manifesto público do GGUF exato** e no loader/dispatch de `experiment_2-1`.
- Distinguir custo por evento `MUL_MAT` denso e custo agregado; explicar o que a participação **12,9% da imagem** sustenta ou não.
- Examinar vec-dot IQ4_XS, permute AMD já existente, custos de escala, limites teóricos de bytes por token e compatibilidade com a seleção de MMVQ em largura 1.
- Evitar reescrever `sudot4` ou permute existentes e não atribuir o perfil de U a `gfx1101`.
- **Entregável:** `RELATORIO-E2-IQ4XS-HEAD.md`. Não editar kernels.

## Agente 4 — política de dispatch e orçamento global

- Reconstruir `MUL_MAT` denso -> `MMVQ/MMQ/BLAS` no commit base `experiment_2-1`, incluindo regras por largura de saída, tipo quantizado, arquitetura RDNA3_0 e fallbacks.
- Mapear se o alvo com `draft-mtp` altera largura e escolha de kernel; distinguir decode single-token, verify e prefill, **sem traços de execução**.
- Usar os percentuais do perfil de U apenas como **cenário ilustrativo de Amdahl**, mostrando que a melhoria global depende da fração do código efetivamente acelerada.
- Sintetizar relações entre os três relatórios e propor ordem de pesquisa sem inferir benchmark nem alterar código.
- **Entregável:** `RELATORIO-E2-DISPATCH-AMDAHL.md`. Não editar kernels.

## Aceitação dos relatórios

Cada agente deve fornecer: objetivo, arquivos e commits consultados, achados confirmados, limites matemáticos, hipóteses, riscos, proposta mínima e lacunas. O assistente consolidará **somente após receber os quatro relatórios**. Não acionar agentes em segundo plano com este commit.
