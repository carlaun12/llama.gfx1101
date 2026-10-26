# Experiments 2 — MMVQ em pesos IQ mistos

**Base exclusiva:** `experiment_2-1` (`7a51c6c46f115a2309a33d611e19cab03745e2f3` na abertura, 2026-10-25).
**Alvo de estudo:** Radeon RX 7800 XT 16 GiB, RDNA3 `gfx1101`; GGUF `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` (`ajgazin`).
**Modo de trabalho:** quatro agentes investigam, o assistente coordena, revisa os relatórios e consolida a documentação. **Não portar kernels, executar testes, benchmarks, builds, scripts, GPU ou pedir logs/dumps locais.**

## Pergunta central

Uma imagem fornecida pelo usuário informa que, **no perfil de “U” e na janela analisada**, kernels MMVQ quantizados somaram **82–84% do tempo total dos kernels**, com participação dentro de MMVQ aproximadamente:

| Tipo | Parcela do tempo de MMVQ no perfil de “U” |
| --- | ---: |
| `IQ3_S` | ~22,5% |
| `IQ3_XXS` | ~20,8% |
| `IQ2_S` | ~18,0% |
| `IQ4_XS` | ~12,9% |
| Demais grupos | ~25,8% |

`IQ3_S+IQ3_XXS+IQ2_S=61,3%` de MMVQ; quando ponderados pelos **82–84%** de tempo total de kernels atribuídos a MMVQ, equivalem, em uma multiplicação indicativa de participações, a **~50,3–51,5%** do tempo agregado de kernels **daquela janela**. Essas porcentagens **não caracterizam o throughput completo do modelo**, tempo de host, transferências, tempo de usuário, saturação de GPU, perfil da RX 7800 XT nem limite físico de memória.

**Proveniência:** transcrição da imagem enviada pelo usuário em 2026-10-25. O perfil é atribuído somente a “U”; captura, configuração, GPU, backend, modelo exato, número de tokens, profundidade de contexto e método de soma de tempos **não foram fornecidos**. Números devem ser tratados como **evidência do material recebido**, não medição validada ou perfil do GGUF-alvo. Não inventar metadados ausentes. Não solicitar execução de benchmark para preencher lacunas.

A investigação deve separar: **(a) concentração de tempo**, **(b) custo real do desquant/unpack**, **(c) bandwidth e tráfego dos pesos**, **(d) latência/dependência das instruções**, **(e) escolha de `MUL_MAT` e `MMVQ` por tipo/shape**, e **(f) riscos de registos/occupancy/ISA**. A parcela grande de um tipo **não prova** que seu decode é compute-bound nem que uma otimização sintática gerará ganho proporcional.

## Organização

- [00-FONTE-E-HIPOTESES.md](00-FONTE-E-HIPOTESES.md) — transcrição, limites e hipóteses.
- [01-RODADA-AGENTES.md](01-RODADA-AGENTES.md) — quatro frentes de investigação, cada uma com entrega própria.
- [02-REVISAO-CRUZADA.md](02-REVISAO-CRUZADA.md) — quadro inicial de evidências e espaço para consolidar os resultados recebidos.

## Fronteiras

1. Pesquisar **o código desta branch**; não assumir que corresponde ao commit anterior de `deep-research` ou ao fork de origem `stew675`. Registrar diferenças **somente quando os agentes as documentarem**.
2. A arquitetura GGUF usa tipos mistos. Não assumir que o sufixo `IQ3_XXS` descreve todos os pesos; `output.weight` IQ4_XS continua uma hipótese relevante de custo.
3. Separar MMVQ de MMQ e operações `MUL_MAT_ID` MoE; o alvo é **denso**, sem MoE.
4. Não pedir dados locais nem gerar código executável. Toda proposta deve oferecer fallback e verificação **documental**, sem declarar ganho empírico.
5. Os prompts dos agentes devem ser enviados **diretamente no chat**; este arquivo documenta apenas escopo e resultados, não substitui os prompts.

## Estado

**Quatro resumos de agentes recebidos e revisados**; os arquivos Markdown integrais mencionados não foram anexados. [Ver revisão consolidada](03-RESULTADOS-R01.md). Nenhuma medição adicional ou modificação de kernel.


## Primeira rodada — resultados dos quatro agentes

[03-RESULTADOS-R01.md](03-RESULTADOS-R01.md) consolida IQ3_S/IQ3_XXS, IQ2_S/XS/XXS, IQ4_XS e dispatch MMVQ/MMQ. A evidência mais específica de diferença de código na branch é o tratamento de sinais de **IQ3_XXS**; em **IQ3_S** e **IQ2_S**, expressões equivalentes já existem em linha. A porcentagem de tempo de U não transforma refatoração em ganho demonstrado.


## Segunda rodada — resultados

Os quatro resumos R02 foram recebidos e consolidados em [04-RESULTADOS-R02.md](04-RESULTADOS-R02.md). **IQ3_XXS** é o candidato pontual de transformação de sinais, sem speedup comprovado; **IQ2_S** é refatoração de manutenção; **IQ4_XS** apresenta hipótese de reuso no verify W2–8; o dispatch denso mantém MMVQ elegível para W1–8 nas condições dos agentes. Nenhum kernel foi modificado.


## Terceira rodada — resultados dos quatro agentes

[05-RESULTADOS-R03.md](05-RESULTADOS-R03.md) registra três candidatos técnicos distintos e a ressalva sobre dispatch anterior a MMVQ: **IQ3_XXS `apply_ksigns`**, **IQ2_XS/XXS `ggml_cuda_mul_small`**, **IQ4_XS reuso entre colunas W2–8**. As evidências são resumos dos agentes; equivalência matemática não é prova de speedup. Nenhum patch foi aplicado.


## Quarta rodada — MMVQ multilinha/multicoluna

[06-RESULTADOS-R04.md](06-RESULTADOS-R04.md) consolida quatro resumos de agentes. **RDNA3_0 mantém R=1 linha por CTA** nos tipos IQ prioritários. R=2 e R=4 são estruturalmente representáveis, mas **leituras de linhas inválidas no CTA de cauda** e custos de acumuladores/ocupação impedem recomendação de habilitação direta. Distinguir **R (linhas/CTA)** de **W (colunas/tokens)**. Mantido R=1; resultados de desempenho desconhecidos.


## Reuso q8_1 entre operacoes — fechamento do tópico 1

[08-REUSO-Q8-ENTRE-OPERACOES.md](08-REUSO-Q8-ENTRE-OPERACOES.md): quatro agentes identificaram compartilhamento possível entre multiplicações MMVQ distintas, mas **nenhuma duplicação efetiva confirmada no GGUF**. Priorizar Q/K/V separados e projeções da atenção linear; descontar fusão gate/up já existente. MMVQ/MMQ usam layouts incompatíveis; preferir fusão local e propriedade explícita, não cache global.
