# Rodada 05 — instruções de encaminhamento aos quatro agentes

**Data:** 2026-10-25
**Estado:** prompts preparados para repasse. Não houve acionamento automático de agentes.
**Responsável pela coordenação:** assistente, **sem investigação substitutiva**.
**Fonte das prioridades:** [todo.md na raiz](../todo.md).

## Contexto obrigatório para todos

Projeto `carlaun12/llama.gfx1101`, branch de documentação `deep-research`. Modelo `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf`, publicado por `ajgazin`. GPU RX 7800 XT 16 GiB RDNA3 `gfx1101`. Os commits de código de comparação já fixados na pesquisa são:

- Destino: `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`
- Origem: `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`
- Manifesto: [rco_types.tsv, coluna RCO-IQ3_XXS](https://huggingface.co/ajgazin/Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-GGUF/blob/main/rco_types.tsv)
- Documentos base: [MTP subset](mtp-subset-iq4xs-contrato.md), [FA TILE](fa-verify-tile-kv-gfx1101.md), [resultados R04](RODADA-04-RESULTADOS.md).

**Proibido** executar ou solicitar qualquer comando local, script de prova, build, benchmark, teste em GPU, coleta de logs, dump de tokenizer, profiling, acesso a máquina, GPU remota ou alteração de código de inferência. A entrega é **somente um relatório Markdown**. Referenciar linhas, símbolos e commits; distinguir fatos, inferências, hipóteses e lacunas. Não alegar ganho medido em gfx1101 nem certeza sobre metadados GGUF não publicados.

## Agente 1 — compatibilidade BPE do GGUF com o patch 0013

**Mensagem para encaminhar:**

> Investigue, exclusivamente pela documentação pública, se o tokenizer do GGUF `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` atende ao guard `mtp_draft_vocab_ids_follow_merge_order` presente na origem `stew675/llama.cpp@e8bd52069ca0`. Consulte `src/llama-model.cpp`, o tokenizer publicado, seus arquivos `tokenizer.json`/`merges.txt`/`tokenizer_config.json` quando disponíveis, e os metadados associados ao checkpoint GGUF. Analise as regras para tipo BPE, número de merges, IDs recuperados, limite de 1% de inversões e atributos `CONTROL|USER_DEFINED`. Diferencie evidência sobre tokenizer upstream de prova relativa ao GGUF exato; não execute parser, script ou modelo. Entregue `RELATORIO-R05-BPE-GGUF.md`, com tabela de guardas e estado confirmado/condicional/não comprovado, fontes por símbolo/URL e implicações para `n_sel`. Não audite o grafo MTP, tarefa do Agente 2.

**Critério de aceitação:** resposta separada para cada guarda, sem conclusão positiva baseada apenas no nome BPE. Se os merges públicos não permitirem verificar a condição, marque **não comprovado**.

## Agente 2 — contrato do patch 0013 no head IQ4_XS

**Mensagem para encaminhar:**

> Faça a auditoria documental do port **mínimo** do patch 0013 sobre o LM head IQ4_XS compartilhado do GGUF selecionado. Use o loader/grafo `src/models/qwen35.cpp`, `src/llama-model.cpp`, `src/llama-context.cpp`, componentes de `ggml_fill` e `ggml_set_rows`, sempre comparando destino e origem pelos commits fixos. Mapeie a cadeia de ativação `model.output` -> `mtp_draft_vocab_get` -> buffer/cópia -> `ctx_type==MTP` -> `n_outputs==1` -> logits `-inf` + scatter. Distinga `n_keep` de `n_sel`, formatos/bytes, cache por backend, fallbacks e efeitos sobre aceitação e VRAM. Use 255 MiB como mínimo condicional para 98.304 linhas de IQ4_XS, não como valor efetivo nem economia de VRAM. Entregue `RELATORIO-R05-MTP-SUBSET.md`, com mapa de chamadas, mudanças documentais necessárias no fork e decisões condicionadas ao relatório BPE do Agente 1. Não execute nada nem escreva patch.

**Critério de aceitação:** cada dependência classificada como presente / ausente / precisa adaptar / não confirmado, e explícito que subset do draft não muda head do target.

## Agente 3 — arredondamento Q8_0 e identidade local do chunk

**Mensagem para encaminhar:**

> Compare estática e matematicamente o carregamento nativo de oito elementos Q8_0 `ggml_cuda_fattn_dequantize_q8_0_chunk` em `ggml/src/ggml-cuda/fattn-common.cuh` (origem) com o conversor usado no staging F16 `dequantize_block_q8_0_f16` em `ggml/src/ggml-cuda/convert.cu`. Examinar a sequência de extração de escala F16, conversão int8->half, multiplicação half2 (incluindo `__hmul2`), arredondamento, sinal de zero, subnormais/FTZ, possíveis NaNs/inf na escala e a compatibilidade do layout em blocos de 32 valores (34 bytes). Separar equivalência **de cada valor desquantizado** de equivalência de todo o kernel FA ou de logits MTP. Documente quais garantias seguem literalmente das operações e quais dependeriam de semântica/compilador HIP. Não gere nem rode scripts. Entregue `RELATORIO-R05-Q8-ROUNDING.md` com prova condicionada, casos-limite e lacunas.

**Critério de aceitação:** tabela clara das duas expressões, premissas e limites; nenhuma promessa de identidade ISA/logits sem fonte.

## Agente 4 — contrato FA verify de seletor, kernel e scratch

**Mensagem para encaminhar:**

> Pesquise o desenho **estritamente documental** do port mínimo de Flash Attention native Q8_0/BF16 para `gfx1101`, concentrado em `W=1..8`, sem modificar prefill >8. Compare `ggml_cuda_get_best_fattn_kernel`, `ggml_cuda_fattn_tile_type`, `fattn-tile.cu/.cuh`, `launch_fattn` e `ggml_cuda_flash_attn_ext_get_alloc_size` entre o destino e a origem fixados na Rodada 05. Produza matriz de `W, K/V type, layouts/strides, GQA, máscara, head-256, seletor, instância, staging/scratch e fallback`. Inclua BF16 direto no TILE quando a condição de hardware RDNA3 e formato homogêneo permite, e pares mistos que requerem F16. Documente dependências de headers e qual código da origem está fora de escopo por pertencer a prefill longo ou RDNA4. Deixe a prova de arredondamento Q8_0 para o Agente 3. Entregue `RELATORIO-R05-FA-CONTRATO.md` com tabela de integração e riscos numéricos.

**Critério de aceitação:** contrato consistente entre selector, launcher e alocador em cada caso; sem classificar suposta pureza bit a bit como observada.

## Coordenação e fechamento

O assistente **não** deve iniciar pesquisa própria para substituir os agentes. Quando os quatro relatórios forem entregues, ele verificará suas fontes, reconciliará eventuais divergências, registrará decisões no [todo.md](../todo.md) e consolidará em documentos de `research/` somente os resultados sustentados. A revisão de resultados é atividade de coordenação, não quinta investigação.

Os relatórios completos poderão ser colados no chat ou vinculados como documentos acessíveis. **Nenhum agente externo está rodando em segundo plano por força deste arquivo**.
