# Cache seletivo de especialistas MoE na VRAM

> **Estado:** proposta registrada / análise estática. **Prioridade:** 7 - condicionado a um GGUF MoE operacional. **Bloco(s) de origem:** 0009; dependências selecionadas 0010.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Sobre a proposta

A origem inclui gerenciamento de especialistas residentes no host, cache em GPU, staging e sincronização. A oportunidade existe quando um modelo MoE pode rodar com parte dos pesos em RAM e acesso recorrente a um subconjunto de especialistas.

Esta proposta não se aplica ao Qwen3.8-27B denso, que não possui especialistas roteados. A variante Qwen3.8-2.4T-A95B citada na auditoria excede amplamente a capacidade prática de uma única placa; é necessário selecionar um GGUF MoE de escala operacional antes de priorizar.

**Implementação mínima investigada**

1. Determinar modelo, GGUF, parâmetros ativos, VRAM livre e padrão de offload de especialistas.
2. Investigar os hooks mínimos de cache/staging do bloco 0009 sem importar toda a infraestrutura de slab.
3. Definir política de cache limitada pela memória e fallback ao caminho normal de offload.
4. Verificar que o scheduler conserva consistência entre pesos, IDs e grafos capturados.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Alto somente se tráfego PCIe de especialistas for gargalo dominante e a distribuição de acesso tiver localidade; irrelevante em modelo denso ou integralmente residente.

**Hipótese de ganho:** Aumentar taxa de acerto do cache de especialistas pode reduzir leituras recorrentes de pesos a partir da RAM do host. Não há estimativa de tokens/s para uma distribuição de especialistas desconhecida.

**Condições que podem anular o benefício:** Baixa localidade, cache insuficiente, overhead de staging/sincronização, pressão sobre KV/snapshots e saturação de RAM/PCIe.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Descobertas e observações

- A RX 7800 XT possui 16 GiB; peso, KV, estados recorrentes, MTP e buffers competem por essa capacidade.
- O bloco 0009 é amplo e conflita com allocator/scheduler do destino; não cabe como patch pequeno.
- O próprio projeto de origem aponta degradação perto do limite de VRAM.
- O problema só deve ser ativado depois de observar logs reais de offload e demanda de especialistas.

## Riscos, correção e fallback

- Evicção de pesos ainda em uso, sincronização errada entre streams, corrupção silenciosa de grafo e OOM.
- Comparar cache ligado/desligado com mesmo padrão de roteamento e mesmos tokens.
- Validar offload básico antes de introduzir cache dinâmico.

## Plano de validação

- Um GGUF MoE que rode efetivamente na máquina, com registro de ram/vram/PCIe e configuração de offload.
- Métricas: cache hit/miss, bytes transferidos, tempo bloqueado no staging, tokens/s, VRAM de pico.
- Testes de prefill, decode, múltiplos especialistas e sequências, com desligamento do cache como controle.
- Rejeitar speedups aparentes acompanhados de logits NaN ou alteração indevida do roteamento.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Confirmar modelo MoE realmente usado pelo usuário.
2. Estimar working set de especialistas a partir dos metadados, sem supor acesso aos arquivos locais.
3. Identificar interface mínima de cache compatível com o destino.
4. Adiar qualquer implementação enquanto não houver evidência de gargalo de offload.

## Referências

- [Origem: blocos 0009/0010](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)
- [Destino: qwen35moe.cpp](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35moe.cpp)
- [Origem: advertências de qualidade de benchmark](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/COMMUNITY-CONFIG.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
