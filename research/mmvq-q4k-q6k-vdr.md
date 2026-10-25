# MMVQ Q4_K / Q6_K e ajuste VDR para gfx1101

> **Estado:** proposta registrada / análise estática. **Prioridade:** 1 - primeiro candidato de baixo escopo. **Bloco(s) de origem:** 0007.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Sobre a proposta

O destino já possui MMVQ, MMQ e tabelas de seleção RDNA3_0. O bloco 0007 da origem modifica produtos vetoriais quantizados, especialmente Q4_K e Q6_K, e políticas de VDR e waves.

Foco inicial: decode denso de Qwen3.8 com GGUF Q4_K. Tratar Q6_K e MMQ como experimentos separados, não como mudança simultânea.

**Implementação mínima investigada**

1. Comparar semanticamente `vecdotq.cuh`, `mmvq.cu` e `mmq.cu` nos SHAs congelados.
2. Avaliar a especialização Q4_K com VDR=4 para o predicado apropriado de gfx1101.
3. Preservar VDR, warps e seleção originais para outros formatos como fallback.
4. Só depois investigar Q6_K VDR=2 e fronteiras de MMQ, inclusive batch em torno de 128.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Médio para decode quantizado se o modelo e suas matrizes dominantes atingirem o caminho modificado; baixo em cargas dominadas por PCIe ou por outros operadores.

**Hipótese de ganho:** Alterar a granularidade do produto vetorial pode reduzir overhead e melhorar a eficiência do matvec. Não se deve prever aumento de tokens/s sem conhecer tráfego, ocupação, spills e contribuição end-to-end.

**Condições que podem anular o benefício:** Pressão de VGPR, ocupação inferior, mudança na ordem da redução FP32 e tempo dominado por offload ou GDN.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Descobertas e observações

- A tabela RDNA3_0 já existe no destino; trata-se de adaptação incremental.
- Segundo a auditoria de kernels, Q4_K VDR4 e Q6_K VDR2 são candidatos concretos na origem.
- O número de waves e o VDR devem ser variados um por vez, evitando confundir as causas.
- A observação de grid-stall padding em gfx1201 não prova benefício na RX 7800 XT.
- A política de MMQ para Q6_K possui uma fronteira de batch que merece medição própria.


### Segunda rodada - delta semântico confirmado (quatro frentes, 25/10/2026)

**Auditoria de arquivos:** o destino `mmvq.cu` já expõe `get_vec_dot_q_cuda()`, `get_vdr_mmvq()`, a tabela `MMVQ_PARAMETERS_RDNA3_0` e `calc_nwarps()`. A origem passou a separar as políticas em `mmvq-vecdot.cuh` e `mmvq-rdna.cuh`, e possui `mul_mat_vec_q_ksplit()` especializado. O número de linhas dos arquivos não indica sozinho dependência mínima; o port deve seguir os símbolos realmente chamados.

**Dot product Q4_K:** a origem define `VDR_Q4_K_Q8_1_MMVQ_RDNA3_0 = 4` e o kernel `vec_dot_q4_K_q8_1_vdr4_dense()`, que computa dois trechos de 16 elementos em cadeia de inteiros antes de aplicar escalas. A configuração genérica de Q4_K da própria origem ainda usa `VDR_Q4_K_Q8_1_MMVQ = 2`. Portanto, mudar somente a constante para 4 sem trazer a função correspondente e o dispatch seria incorreto.

**Coerência host/device:** `get_vdr_mmvq_dense(type, table_id)` é usado no lado host para particionar K e no device para calcular grupos e índices. É obrigatório usar o mesmo VDR na especialização e na aritmética de K-split. A seleção da origem emprega a macro de arquitetura `RDNA3_0`; o primeiro port para RX 7800 XT deve usar guard estrito para o dispositivo efetivo e ter controle de desligamento que também mantenha correspondentes os seletores de host/device.

**Warps e verify:** a política `mmvq_rdna_nwarps()` na origem seleciona 8 warps para alguns tipos RDNA3_0, incluindo Q6_K, quando `small_m` é falso e a largura cai na faixa MMVQ. Ela preserva a mesma configuração para `W=1..8`, pois mudar o número de warps pode mudar a ordem da acumulação de K-split. Esta é **outra proposta experimental**, não deve entrar no primeiro patch Q4_K VDR4.

**Decisão inicial de implementação:** primeiro isolar `Q4_K` denso, sem MoE, sem mudar `nwarps` e sem aplicar `ggml_cuda_mul_small()` genericamente a outros tipos. Comparar a saída com a referência de operador e também com o próprio decode/verify; a origem avisa que a nova partição pode mudar o texto greedy em relação ao algoritmo anterior mesmo mantendo uniformidade entre larguras. Não afirmar preservação bit a bit sem teste.

**Evidência de código:**
- [Destino: get_vdr_mmvq e RDNA3_0](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu)
- [Origem: mmvq-vecdot.cuh](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/mmvq-vecdot.cuh)
- [Origem: mmvq-rdna.cuh](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/mmvq-rdna.cuh)
- [Origem: vec_dot_q4_K_q8_1_vdr4_dense](https://github.com/stew675/llama.cpp/blob/e8bd52069ca0/ggml/src/ggml-cuda/vecdotq.cuh)

## Riscos, correção e fallback

- Reorganizar reduções FP32 pode alterar logits e decisões greedy/MTP, mesmo quando `MUL_MAT` passa.
- Guardar a otimização por formato, shape e arquitetura, com fallback ao MMVQ atual.
- Não afetar Q5_K e outros tipos no primeiro patch.

## Plano de validação

- `test-backend-ops -o MUL_MAT` para matrizes Q4_K e Q6_K, incluindo shapes adjacentes às fronteiras do dispatcher.
- Decode `W=1`; verificar `W=2..8` quando a seleção do kernel for atingida.
- A/B em GGUF idêntico, `llama-bench` `tg128`/`tg512`, perfilamento de VGPR e spills quando disponível.
- Confirmar por instrumentação de dispatch que o caminho novo foi efetivamente selecionado.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Produzir diff mínimo Q4_K VDR4.
2. Identificar todos os guards da versão inicial e do destino.
3. Documentar expectativa de alteração numérica e fallback.
4. Somente depois considerar implementação.

## Referências

- [Origem: especialização em vecdotq.cuh](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/vecdotq.cuh)
- [Destino: MMVQ](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/mmvq.cu)
- [Destino: vecdotq](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/vecdotq.cuh)
- [Origem: índice dos blocos](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
