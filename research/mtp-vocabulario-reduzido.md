# Subconjunto de vocabulário para o head do MTP draft

> **Estado:** proposta registrada / análise estática. **Prioridade:** 6B - dependente de MTP estável. **Bloco(s) de origem:** 0013.

**Escopo:** RX 7800 XT (Navi 32, gfx1101, 16 GiB), llama.gfx1101 e modelos Qwen3.8 com arquitetura Qwen3.5, quando aplicável.

**Baseline de código investigado:** `carlaun12/llama.gfx1101@31288c9c66e5`. **Origem das ideias:** `stew675/llama-cpp-rdna-boosts`, release `v15-3f03b1772-r137`.

**Limite de evidência:** revisão remota de código e documentação em 25/10/2026. Os agentes não possuem acesso à máquina do usuário nem a GPU ou ambiente de execução na nuvem. Nenhuma medição na RX 7800 XT é presumida.

## Ajuste ao modelo-alvo RCO-IQ3_XXS

**Prioridade: dependente de medição do draft MTP e VRAM livre.** O GGUF tem 9,7 GiB e já integra a camada de MTP. O vocabulário do backbone é 248.320; a alocação RCO registra pesos Q6_K no head MTP. O custo real de criar um subset/head adicional precisa ser estimado a partir dos shapes e formatos, não de uma cópia F16 genérica. Repetir medição de aceitação e tokens confirmados/s, já que eliminar logits de candidatos pode reduzir a aceitação.


## Sobre a proposta

A origem permite limitar os IDs considerados pelo LM head do draft MTP, mantendo tokens de controle e preservando o vocabulário completo do modelo principal na verificação.

A proposta é evitar calcular logits de draft para todos os tokens quando o custo do LM head compensa uma representação reduzida.

**Implementação mínima investigada**

1. Identificar head e layout efetivos do draft no GGUF escolhido.
2. Adaptar `--spec-draft-mtp-vocab` e controles apenas para MTP.
3. Preservar mapeamento estável de IDs, tokens de controle e logits de verificação completos.
4. Medir custo de buffers/copias de linhas na única GPU.

## Ganhos estimados

**Estimativa percentual para RX 7800 XT:** **indeterminada**. Não existe benchmark local que sustente uma faixa numérica.

**Potencial qualitativo:** Condicional: potencial de reduzir tempo do draft, mas pode elevar consumo de VRAM e piorar aceitação.

**Hipótese de ganho:** No checkpoint Qwen3.8-27B analisado, vocabulário de 248.320 e embedding de 5.120 implicam head de 1.271.398.400 coeficientes. Avaliar apenas uma parte pode reduzir multiplicação de matriz do draft; não equivale a redução proporcional no throughput end-to-end.

**Condições que podem anular o benefício:** Projeção do draft não dominante, cópia adicional do head, cache fragmentado ou distribuição dos tokens propostos incompatível com subconjunto.

## Resultados

**Situação:** nenhuma implementação desta proposta foi executada ou medida na RX 7800 XT no âmbito desta pesquisa.

| Data | Commit baseline | Commit candidato | GGUF/quantização | Cenário | Resultado A | Resultado B | Ganho observado | Correção numérica | Evidência |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pendente | - | - | - | - | - | - | Não medido | Não verificada | - |

Preencher somente com logs, hashes, parâmetros e medições efetivos fornecidos posteriormente pelo usuário. Não inserir números hipotéticos nessa tabela.


## Resultados da pesquisa — viabilidade do subset no GGUF selecionado (25/10/2026)

O relatório MTP discute economias teóricas ao aplicar o patch `0013` a um LM head **Q6_K** de `248.320 x 5.120` (aproximadamente 994,6 MiB). **Isso é um exemplo condicional e não corresponde automaticamente a `output.weight` deste GGUF**, que está documentado como **IQ4_XS**.

O [caminho de head do fork](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp) prefere `nextn.shared_head_head` se existir e, caso contrário, usa `model.output`. O patch de vocabulário reduzido discutido pelo agente depende do caminho de **head compartilhado** e de `n_outputs==1`. Não supor que será ativado para todo checkpoint com MTP.

Se usar `model.output` IQ4_XS, cada bloco tem 136 bytes por 256 pesos, levando, para `248.320 x 5.120`, a **675.430.400 bytes = 644,1 MiB** aproximados de dados do head. Um subconjunto de 98.304 IDs exigiria cerca de **267.386.880 bytes = 255 MiB** de pesos IQ4_XS em cópia própria, além do original, se o código realizar materialização completa. Isto é geometria de armazenamento, sem afirmar custos reais de tráfego, aceitação, amortização ou elegibilidade do patch.

As tabelas Q6_K do relatório são válidas **somente para um head Q6_K**. A existência de oito tensores Q6_K em `blk.64` não converte `model.output` para esse tipo e nem confirma o tipo de um eventual `nextn.shared_head_head`.

**Recomendação:** primeiro demonstrar por manifesto e loader qual head é selecionado; só depois dimensionar o subset no formato correspondente. Economias de leitura de pesos são estimativas condicionais; o custo adicional de VRAM e possível exclusão de tokens também entram no desenho.

**Revisão cruzada:** [REVISAO-AGENTES-2026-10-25.md](REVISAO-AGENTES-2026-10-25.md).

## Descobertas e observações

- O destino já suporta MTP; a otimização de vocabulário é adicional.
- A origem acrescenta flag de controle e lógica de cópia/reconstrução dos logits do draft.
- Como exemplo de orçamento, 98.304 linhas por 5.120 colunas em F16 ocupam ~0,938 GiB, sem metadados. Não assumir que essa memória extra cabe na RX 7800 XT.
- A origem também inclui tratamento de leitura de linhas no backend Meta para cenários de divisão de tensor; GPU única não justifica importar indiscriminadamente todos esses caminhos.

## Riscos, correção e fallback

- Perda de tokens admissíveis pelo draft, mapeamento incorreto de IDs, alteração na aceitação e OOM devido a pesos copiados.
- Manter `mtp_vocab=0` como fallback para vocabulário completo.
- Não modificar o head do modelo verificador.

## Plano de validação

- Comparar MTP sem redução versus vários limites de vocabulário.
- Medir VRAM adicional, custo de inicialização/cópia, latência do head, aceitação e tokens confirmados/s.
- Confirmar tokens especiais/controle e comportamento em texto e código.
- Exigir mesma saída validada pelo target e nenhum erro de índice.

- Registrar SHA do código, versão ROCm/HIP, compilação real para `gfx1101`, SHA256 do GGUF, flags de execução, camadas na GPU, KV e VRAM.
- Comparar baseline e candidato com as mesmas condições. Separar modelo inteiramente residente de modelo com offload.
- Registrar `llama-bench` em prefill, decode e, quando aplicável, prefill+decode; medir por repetições independentes intercaladas A/B.
- Exigir testes de operadores e comparação de logits/perplexidade quando a mudança altera aritmética.
- Incluir prefixo real de pelo menos 4096 tokens nos testes de largura `W=1..8` quando houver impacto em decode/verify.
- Sem acesso dos agentes ao hardware, este plano é apenas um protocolo para execução futura pelo usuário.

## Próximos passos

1. Medir teoricamente buffers para as quantizações reais.
2. Desenhar mapeamento de IDs e preservação de controle.
3. Adaptar somente caminho single-GPU.
4. Prosseguir apenas se houver margem real de VRAM.

## Referências

- [Origem: bloco de vocabulário MTP](https://github.com/stew675/llama-cpp-rdna-boosts/blob/main/patches/README.md)
- [Destino: Qwen3.5](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp)
- [Destino: speculative.cpp](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/common/speculative.cpp)

## Rodada 04 — elegibilidade do patch 0013 sobre IQ4_XS (25/10/2026)

O [manifesto do GGUF selecionado](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF/blob/main/rco_types.tsv) indica `output.weight=IQ4_XS` e ausência de `nextn.shared_head_head.weight`; o [loader Qwen3.5](https://github.com/carlaun12/llama.gfx1101/blob/31288c9c66e59377f7788d920678a565bb89dd37/src/models/qwen35.cpp#L659-L664) reutiliza `model.output` na ausência do head dedicado. Esta é uma **inferência condicionada à fidelidade do manifesto ao binário**.

O subset de 98.304 IDs corresponderia a `98.304×5.120×136/256 = 267.386.880 bytes = 255 MiB` de pesos `IQ4_XS` numa cópia materializada, **além dos 644,14 MiB do head completo** que o target continua utilizando. Índices, alinhamento, metadados e tokens especiais acrescentam custo; o subset não representa redução automática de VRAM. A economia potencial de leitura de pesos do draft é condicional à seleção desse caminho.

Segundo o resumo do Agente 1, o patch `0013` ainda exige cabeça compartilhada, `n_outputs==1`, requisitos de tokenizer BPE e tratamento de IDs de controle. **Elegibilidade: condicional**, não implementação garantida neste fork ou nesse GGUF. Ausência de avaliação documental específica de aceitação para o subset escolhido. Não prometer ganhos de velocidade.

Ver [revisão de resultados R04](RODADA-04-RESULTADOS.md).

## Aprofundamento do patch 0013 (25/10/2026)

A pesquisa detalhada dos guards, políticas de tokenizer, seleção de IDs de controle, `n_keep` versus `n_sel`, cache de head e scatter de logits foi consolidada em **[mtp-subset-iq4xs-contrato.md](mtp-subset-iq4xs-contrato.md)**. O subset IQ4_XS de 98.304 linhas requer no mínimo 255 MiB de pesos **extras**, não reduz os 644,14 MiB do head completo, e pode acrescentar linhas com IDs de controle/user-defined. A condição de ordenação de merges BPE na origem ainda **não está verificada** para o índice GGUF deste modelo; não basta constatar `Qwen2Tokenizer` no JSON upstream.

## Histórico

- **2026-10-25:** proposta inicial registrada a partir de auditorias remotas dos quatro agentes. Nenhum código alterado e nenhum teste de GPU realizado.
