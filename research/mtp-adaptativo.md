# Speculative MTP de profundidade adaptativa

> **Estado:** proposta registrada / análise estática. **Prioridade:** 6 - depende de baseline correto de decode/verify. **Bloco(s) de origem:** 0002.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Sobre a proposta

O destino já possui `draft-mtp` para a família Qwen3.5. A origem acrescenta controle dinâmico de profundidade e políticas relacionadas ao estado recorrente.

Objetivo: otimizar tokens de saída efetivamente confirmados, não apenas a velocidade do draft ou a taxa de propostas geradas.

**Implementação mínima investigada**

1. Documentar a lógica atual de `draft-mtp` e limites `n_max`.
2. Desenhar um controlador que adapte a profundidade usando aceitação e custo de verificação, com limites conservadores.
3. Preservar rollback e a escolha do kernel de GDN/FA em W=1..8.
4. Deixar profundidade fixa disponível como comparação e fallback.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Condicional: pode ser expressivo se draft barato e aceitação alta; pode ser negativo se verify caro ou memória escassa.

**Hipótese de ganho:** Ajustar quantidade de tokens propostos ao regime efetivo de aceitação pode evitar verificações inúteis e aumentar tokens confirmados por segundo.

**Condições que podem anular o benefício:** Baixa aceitação, largura de verify que aciona outro kernel, custos de contexto MTP e snapshots em 16 GiB e divergência numérica entre W=1 e W=2..8.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Descobertas e observações

- O destino implementa MTP básico; não é necessário recriar `qwen35` ou o grafo de draft.
- A origem define preocupação explícita com pureza de largura e rollback recorrente.
- A otimização deve medir taxa de aceitação e throughput confirmado; throughput bruto de draft não basta.
- O limite de profundidade exato requer inspeção do checkpoint e das flags disponíveis.

## Riscos, correção e fallback

- Alterar texto final por divergência entre decode e verify, alocação excessiva de snapshots ou controller instável.
- O caminho sem especulação deve permanecer disponível e reproduzível.
- Evitar misturar mudança de controlador com novas variantes BF16/WMMA.

## Plano de validação

- Comparar `--spec-type none` com MTP fixo e MTP adaptativo no mesmo GGUF.
- Validar `W=1..8` com contexto >=4096, KLD e rollback por sequência.
- Registrar propostas, aceitação, verificações, tokens confirmados/s, VRAM e latência.
- Separar ensaios com prompting curto de contexto já preenchido.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Inventariar métricas de custo e aceitação da origem.
2. Determinar invariantes da profundidade e do estado recorrente.
3. Definir algoritmo adaptativo reversível e telemetria.
4. Implementar somente após o baseline de pureza.

## Referências

- [Destino: speculative.cpp](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/common/speculative.cpp)
- [Origem: metodologia de pureza](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/GREEDY-PURITY.md)
- [Origem: blocos](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
