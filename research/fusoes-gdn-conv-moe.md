# Fusões incrementais GDN, conv1d, norm e MoE

> **Estado:** proposta registrada / análise estática. **Prioridade:** 5 - otimizar apenas subgrafos ausentes. **Bloco(s) de origem:** 0008; seleções do 0010.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Ajuste ao modelo-alvo RCO-IQ3_XXS

**Prioridade: intermediária apenas para GDN, conv1d e normalização comprovadamente presentes.** O backbone é denso, com 48 camadas GDN; não possui camada roteada de especialistas MoE. Excluir propostas e matchers específicos de MoE da campanha principal. Focar custo de launch e cópias de estado nas 48 camadas recorrentes e comparar com as fusões que o fork já implementa.


## Sobre a proposta

O destino já possui dispatcher e fusões para algumas cadeias de MoE, normalização e cópia de estado recorrente. A proposta é localizar subgrafos ainda não fundidos em Qwen3.8 e portar apenas uma fusão comprovadamente ausente, sem transportar o framework de slab e dispatcher completo.

**Implementação mínima investigada**

1. Comparar `ggml_cuda_try_fuse()` do destino com as cadeias realmente presentes na origem.
2. Priorizar um matcher isolável, como GDN conv1d ou RMSNorm -> Q8_1, se não houver equivalente.
3. Habilitar fallback para grafo não fundido e kill-switch individual.
4. Confirmar liveness, views, aliasing e identidade dos buffers antes da fusão.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Baixo/médio por fusão isolada, podendo ser importante em decode dominado por lançamentos pequenos; indeterminado no modelo completo.

**Hipótese de ganho:** Remover launches e tráfego de tensores intermediários pode reduzir latência, particularmente para operações curtas de decode.

**Condições que podem anular o benefício:** Subgrafo raramente usado, overhead já reduzido por mecanismos existentes, aumento de registradores, mais trabalho no matcher ou CPU/PCIe dominante.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Descobertas e observações

- O destino já funde várias operações que o bloco 0008 descreve; importação integral causaria duplicação.
- Candidatos a verificar incluem GDN conv, gate/beta, RMSNorm -> Q8_1 e lotes pequenos de cópias.
- Fusão MoE depende de IDs dos especialistas e da reutilização correta do tensor de ativação.
- Hip graphs e buffers capturados exigem atenção à invalidação de endereços.

## Riscos, correção e fallback

- Reordenação de operações, alterações em arredondamento, acesso a views inválidas, reaproveitamento incorreto do cache quantizado e problemas de aliasing.
- Para MoE, testar IDs repetidos e distribuição irregular de tokens.
- Toda fusão precisa de desativação individual e saída comparável ao grafo original.

## Plano de validação

- Instrumentar qual matcher disparou e quantos launches deixou de executar.
- Testar operador e subgrafo antes de testar aplicação inteira.
- Comparar logits/estado, W=1..8 quando aplicável, prefill KLD e workload com múltiplas sequências.
- Medir impacto end-to-end, não apenas latência do kernel fundido.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Fazer inventário de cadeias já fundidas no destino.
2. Escolher uma cadeia realmente emitida pelo Qwen-alvo.
3. Desenhar matcher mínimo e o controle on/off.
4. Adiar slab, async input ring e reestruturação integral do dispatcher.

## Referências

- [Destino: ggml-cuda.cu](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/ggml/src/ggml-cuda/ggml-cuda.cu)
- [Origem: try-fuse](https://github.com/stew675/llama.cpp/blob/e8bd52069ca049cd5213366363451abbb5383865/ggml/src/ggml-cuda/ggml-cuda-try-fuse.cu)
- [Origem: índice do bloco 0008](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
