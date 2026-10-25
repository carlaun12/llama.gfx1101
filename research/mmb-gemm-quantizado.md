# MMB BF16-WMMA para GEMM de prefill quantizado

> **Estado:** proposta registrada / análise estática. **Prioridade:** 4 - prefill GEMM. **Bloco(s) de origem:** 0006.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Sobre a proposta

A origem implementa MMB para dequantizar pesos diretamente em BF16, organizar tiles na LDS e usar WMMA com acumulação FP32. O destino mantém MMQ/rocBLAS e não expõe a mesma família MMB segundo a auditoria estática.

Objetivo inicial: um caminho de prefill denso Q4_K, sem introduzir `mmf32`, cache sombra ou mudanças generalizadas de MoE.

**Implementação mínima investigada**

1. Portar `mmb.cu/.cuh` e o mínimo de seleção necessário.
2. Guardar por `cc == gfx1101`, formato, alinhamento, contiguidade, shape e largura de batch.
3. Conservar `ggml_cuda_mul_mat_q`/rocBLAS como fallback.
4. Evitar ativar tiles maiores por padrão sem análise de ocupação e spills.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Alto apenas se matmul de prefill quantizado dominar o tempo e a reutilização de pesos/ativações compensar dequantização e sincronização.

**Hipótese de ganho:** Maior intensidade computacional de prefill pode favorecer tiles BF16-WMMA versus caminhos atuais. O ganho não é automaticamente transferível para decode com batch pequeno.

**Condições que podem anular o benefício:** Pressão de VGPR/LDS, conversão F32->BF16, prefill curto e FFN/GDN/transferências dominantes.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Descobertas e observações

- A auditoria identifica tiles 128x128 e 128x256 no caminho gfx11 e variações de LDS da ordem de dezenas de KiB por CTA.
- O dispatch de origem para RDNA3_0 exige condições adicionais além do dtype de pesos.
- A versão `mmf32` tem comportamento distinto e permanece separada; a documentação relata regressões em gfx1100 para certas cargas.
- Alterar precisão das ativações pode modificar logits e seleção de especialistas.

## Riscos, correção e fallback

- Mudança na aritmética via BF16, overflow/precisão de reduções e incompatibilidade de layout.
- Ocupação menor por LDS/VGPR; spills podem transformar ganho aparente de WMMA em regressão.
- Fallback ao MMQ/rocBLAS original em qualquer shape não explicitamente elegível.

## Plano de validação

- `test-backend-ops -o MUL_MAT` com Q4_K e matrizes com shapes reais do Qwen.
- pp512/pp2048/pp8192 conforme memória disponível e o mesmo GGUF.
- KLD de prefill e autocontrole A/A; comparar saída de múltiplos runs.
- Perf counters de utilização WMMA, LDS, VGPR e scratch quando houver perfil da máquina.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Extrair subset Q4_K do bloco 0006.
2. Determinar guard estrito e identificar fallback.
3. Avaliar custos de binário e tempo de compilação.
4. Só ampliar tipos se houver ganho end-to-end medido.

## Referências

- [Origem: mmb.cu](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/mmb.cu)
- [Destino: seleção de multiplicação](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/ggml-cuda.cu)
- [Origem: blocos](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
