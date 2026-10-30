# Experiments 2 — Rodada 09: elegibilidade e mapeamento RMSNorm para q8_1

**Base dos agentes:** `experiment_2-1@19667c4f5f8c84a9719a4861265409e9a9c80f68`. Fonte da consolidação: **quatro resumos** enviados pelo usuário dos relatórios R09; os arquivos integrais não foram fornecidos neste turno. Exclusivamente leitura estática e deduções: sem patch, execução, teste ou medição.

## Decisão: ADIAR

A geometria do RMSNorm vetorizado é favorável, mas **não foi comprovado no GGUF um subgrafo com consumidor MMVQ elegível, sem conflito de consumidores F32 e com economia efetiva superior à integração adicional**. Não autorizar a saída q8_1-only ou dupla indiscriminadamente. Manter como fallback RMSNorm+MUL fundidos produzindo F32 e quantização q8_1 separada quando o MMVQ é selecionado.

## Agente 1 — Grafo e candidatos

- A fusão RMSNorm+MUL pelos pesos já existe quando elegível. Nova fronteira candidata: F32 **pós-MUL** → q8_1 antes de MUL_MAT MMVQ.
- **Menor risco estrutural:** `RMS_NORM → MUL(pesos) → MUL_MAT(wqkv)` quando há projeção unificada. Um consumidor direto no ramo analisado, mas inexistência de outros consumidores no grafo completo não foi provada.
- Q/K/V separados: três consumidores; atenção linear/GDN: ao menos quatro; gate/up FFN: dois com fusão gate/up/GLU já existente; MTP blk.64: wqkv único ou Q/K/V separados dependendo do modelo.
- RMSNorm Q/K interna antes de RoPE e hnorm/enorm antes de concatenação não são casos do padrão mínimo.
- Ainda faltam presença e tipo de `wqkv` real do GGUF, dispatch MMVQ em gfx1101 e consumidores adicionais.

## Agente 2 — Mapeamento e reduções

Para D_model=5120, geometria vetorizada descrita pelo agente: 1024 threads/CTA, 32 waves32, vpt=4. Cada grupo contíguo de 32 valores pertence a oito threads, quatro valores por thread. Blocos b=0..127 aparecem no primeiro carregamento; b=128..159 nas primeiras 256 threads em um segundo. Os 160 blocos q8_1 estão na mesma CTA; nenhum exige comunicação entre CTAs ou atravessa uma wave32.

**Contudo**, o quantizador MMVQ de referência atribui um valor por lane em wave32 e executa suas próprias reduções de máximo e soma. Reunir oito subtotais de quatro valores não garante os mesmos bytes. Um epílogo com redistribuição intrawave para 32 lanes e mesma árvore de redução é hipótese de compatibilidade; igualdade bit a bit continua sem demonstração.

## Agente 3 — Contrato e bytes lógicos

A RMSNorm calcula a soma de quadrados e aplica `rsqrtf(... + epsilon)` antes de multiplicar pelos pesos. q8_1 precisa da mesma saída ponderada F32 que a rota atual materializaria, com `amax`, soma **pré-arredondamento**, escala `d=amax/127`, quantizados `roundf(x/d)`, metadados FP16 e padding. Ordem de reduções, FMA e conversões podem alterar os bytes.

Há **uma redução global RMSNorm**, **160 reduções de máximo** e **160 reduções de soma**: 321 reduções conceitualmente independentes, não 321 barreiras nem lançamentos.

Para D=5120, W=1 e camada elegível:
- Intermediário F32: 20.480 B; buffer q8_1: 5.760 B.
- Produzir F32 + q8_1 na CTA: evitaria **no máximo 20.480 B lógicos** da releitura F32 pela quantização, se substituída por produção conjunta.
- Produzir somente q8_1: evitaria **no máximo 40.960 B lógicos** de escrita+releitura F32; exige comprovar ausência de outros leitores.
- Essas quantidades **não** medem DRAM, custo da redistribuição, sincronização, desempenho ou tokens/s.

## Agente 4 — Integração adversarial

- A) RMSNorm+MUL produz F32 e q8_1: **condicional, adiar**.
- B) Produz somente q8_1: **bloqueada sem exclusividade comprovada**.
- C) RMSNorm F32 com quantização separada: **preservar**.
- D) Compartilhamento entre projeções: **condicional**, apenas com consumidores MMVQ realmente compatíveis.
- A fusão existente RMSNorm→MUL concorre com padrões RMSNorm→MUL→RoPE e RMSNorm→MUL→SiLU→MUL; não interceptar outros padrões sem mapear o grafo.
- MMVQ atualmente aloca e quantiza `src1_q8_1` dentro da própria chamada. Sem interface interna de buffer pré-quantizado com layout, identidade, ownership e lifetime, emissão q8_1 adicional pode **duplicar**, e não eliminar, trabalho.

## Conciliação e bloqueadores

1. Geometria satisfaz a propriedade **mesma CTA**, mas a propriedade **mesmos bytes q8_1** continua pendente.
2. `wqkv` unificado é candidato mais simples apenas **se** existir no GGUF com tipo/dispatch relevantes, e mesmo então requer checar usos adicionais da ativação.
3. A alternativa conservadora F32+q8_1 reduz o teto contábil a 20 KiB/token/camada; a alternativa q8_1-only não pode ser generalizada.
4. **Não abrir implementação** antes de comprovar (i) ocorrência concreta no GGUF, (ii) MMVQ realmente elegível após fusões, (iii) contrato de bytes com mapeamento intrawave, (iv) consumo do buffer sem requantização, (v) fallback e vida útil.
5. Se isso exigir mudança profunda de scheduler ou recursos que tornem a economia pouco plausível, redirecionar pesquisa a otimizações locais do vec-dot MMVQ.

**Veredito final:** ADIAR RMSNorm→q8_1; sem ganho de desempenho comprovado.
