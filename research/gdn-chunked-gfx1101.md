# Gated DeltaNet chunked FP32 e BF16/WMMA para gfx1101

> **Estado:** proposta registrada / análise estática. **Prioridade:** 2 - maior lacuna específica de prefill. **Bloco(s) de origem:** 0003; dependências selecionadas 0000/0010.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Sobre a proposta

O `GGML_OP_GATED_DELTA_NET` e os kernels sequencial/MMA já existem no destino. Mas `select_gdn_mma_path()` restringe o caminho MMA HIP à classe RDNA3.5, deixando gfx1101 fora dele.

A origem introduz kernel chunked FP32 e uma implementação BF16/WMMA específica de gfx11. O objetivo é acelerar prefill recorrente, não presumir ganho idêntico em decode.

**Implementação mínima investigada**

1. Fase A: integrar apenas chunked FP32 para shapes elegíveis e manter recorrência sequencial como fallback.
2. Preservar os contratos do estado, o processamento de tail e os snapshots de rollback.
3. Impedir o caminho chunked de capturar a largura especulativa `n_rs_batch`.
4. Fase B: investigar `gated_delta_net_chunked_bf16_gfx11.cu` como opt-in após gates numéricos de prefill.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Alto para prefill GDN em modelos híbridos, condicionado à participação efetiva da recorrência na latência total; indeterminado para decode.

**Hipótese de ganho:** Processar blocos temporais em paralelo pode reduzir a sequência serial de atualizações GDN. Na rota BF16, WMMA pode aumentar throughput matricial, mas também reduzir ocupação.

**Condições que podem anular o benefício:** Baixa quantidade de CTAs para um único prompt, aproximadamente 61 KiB de LDS no caminho BF16 descrito na origem, 512 threads, spills, estado/rollback incompatível ou FFN quantizada dominante.

**Evidência externa (não é resultado de gfx1101):** A documentação da origem registra +3,2% em pp2048 do seu chunked frente ao MMA upstream em gfx1151 com Qwen3.5 4B Q8_0. Essa comparação não é uma estimativa para o destino gfx1101.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Descobertas e observações

- A exclusão do caminho MMA HIP em gfx1101 é constatável no seletor atual.
- O 27B híbrido analisado possui 48 camadas GDN e 16 camadas de atenção convencional.
- A origem alerta que o snapshot anterior ao batch pode ser necessário em rollback e que `prepare()` precisa considerar todos os ubatches, não apenas o último.
- A origem documenta regressão histórica de logits no BF16: KLD 0,032 em gfx1201 e 0,62 em gfx1100; o problema passou pelos testes de operadores da época.
- Por isso, BF16 deve ser uma proposta experimental posterior ao FP32, nunca habilitada por pressuposição.

## Riscos, correção e fallback

- Violação de causalidade, estado recorrente desatualizado, aliasing de planos e rollback incorreto sob MTP.
- Mudança de numerics na conversão BF16, mesmo com acumulação FP32.
- Fallback explícito à recorrência sequencial, com opção de desativação do chunked e do BF16 separadamente.

## Plano de validação

- `test-backend-ops -o GATED_DELTA_NET`, testes de profundidade e restauração de estado recorrente.
- Prefill de 64 a 4096 tokens, diferentes batch/ubatch e sequências quando suportado.
- Gate de logits de prefill, KLD e perplexidade contra baseline estável; incluir autocontrole A/A do instrumento.
- Geração `none` versus `draft-mtp`, rejeição especulativa, rewind e `W=1..8`.
- Medição de LDS, VGPR, spills e CTAs com ferramenta ROCm na máquina do usuário, caso ele disponibilize logs.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Desenhar layout e invariantes dos snapshots.
2. Produzir diff de integração apenas FP32.
3. Listar condições de elegibilidade e fallback.
4. Avaliar BF16 somente depois da campanha de correção FP32.

## Referências

- [Destino: seletor GDN MMA](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/gated-delta-net-mma.cu)
- [Origem: kernel chunked FP32](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/gated_delta_net_chunked.cu)
- [Origem: kernel chunked BF16 gfx11](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/gated_delta_net_chunked_bf16_gfx11.cu)
- [Origem: gate de logits de prefill](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/benchmarks/prefill-logit-methodology.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
