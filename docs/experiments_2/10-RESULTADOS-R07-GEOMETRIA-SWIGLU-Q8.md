# Experiments 2 — Rodada 07: geometria SwiGLU para q8_1

Base lida pelos agentes: experiment_2-1, commit 9d1a8962a70c88143c566b45bc9843e143a88022. Fonte desta consolidação: quatro resumos do usuario; arquivos completos dos relatórios não foram disponibilizados neste turno.

## Achado estrutural

Para IQ3_S e IQ3_XXS em gfx1101, W=1 e fusão gate/up/SwiGLU elegível: nwarps=1, rows_per_cuda_block=1, wave32. Cada CTA reduz a dimensao K e produz um unico escalar z[r]. Um block_q8_1 requer 32 valores z[32b..32b+31], portanto a reducao interna atual nao resolve a quantizacao conjunta. Com FFN 17408: 17408 CTAs em R=1, ou 544 grupos de 32.

## Resultados por agente

Agente 1: R=2/4 estruturalmente contemplados no codigo generico, mas exigem guardas de leitura e avaliacao de recursos. R=32 requer epilogo e geometria substancialmente novos; nao basta mudar o parametro de linhas por CTA.

Agente 2: referencia conceitual B — uma CTA de quatro waves32, cada wave processando oito linhas de pesos, com reuniao dos 32 escalares em LDS e producao de um block_q8_1. Nao aprovada: menos CTAs, sincronizacao, registradores, possivel menor ocupacao e risco numerico. Outras opcoes: uma wave em varias fases, processamento parcelado de 2/4/8 linhas, produtor especializado.

Agente 3: caminhos que mantem F32 e quantizador separado nao eliminam o trafego intermediario. Um buffer alternativo do mesmo tamanho tambem nao prova economia. Somente uma CTA dona do bloco completo pode evitar sincronizacao global entre CTAs e eliminar inteiramente o F32 sob as hipoteses propostas, mas precisa reorganizar significativamente o calculo.

Agente 4 (revisao adversarial): nao recomendar 32 linhas de pesos por CTA como primeira integracao. Preservar geometria do MMVQ; priorizar apenas mudancas de interface de buffer compartilhado e fallback, caso exista oportunidade separada. Nao quantizar dentro de cada CTA FFN down; nao adotar cache global nem comunicacao entre CTAs nao demonstrada.

## Contabilidade por token e camada elegivel

D_ff=17408, W=1: F32 intermediario = 69632 B; q8_1 = 19584 B (544 blocos de 36 B); escrita mais releitura F32 = 139264 B = 136 KiB de acessos logicos potencialmente removiveis. Nao e trafego DRAM medido e nao implica ganho de tokens/s. Um consumo completo de q8_1 e sua escrita somam 39168 B logicos, permanecendo no modelo de produtor compartilhado.

## Revisao cruzada e decisao

1. **Arquitetura B (4 waves, oito linhas por wave) e uma hipotese de pesquisa, nao a preferencia de implementacao**. A recomendacao favoravel do Agente 2 contrasta com a advertencia adversarial do Agente 4; os dois concordam que nao existe desempenho comprovado.
2. O numero de CTAs cai de 17408 para 544 com R=32: reducao de contagem, nao prova de ocupacao menor. Custo por CTA, wave e recursos precisam permanecer como incognitas.
3. Solucoes de duas etapas que continuam materializando e relendo F32 nao capturam a economia pretendida; sao referencia conservadora ou ganho de interface, nao fusao de producao.
4. Identidade bit a bit exige preservar reducoes dos dots, SiLU, bias/clamp, valores F32, amax, soma pre-arredondamento, roundf, make_half2 e padding. Nao foi demonstrada apenas pela fonte.
5. Recomendacao: **nao promover a fusao SwiGLU para implementacao agora**. Preservar baseline; se continuar a investigacao, restringir-se a uma especificacao de produtor especializado por grupo de 32, comparando formalmente decomposicao, memoria, sincronizacao e possibilidade de manter a ordem numerica. Se exigir mudanca ampla do MMVQ ou ordem aritmetica, reduzir prioridade frente a otimizações locais de vec-dot.

Somente analise estatica e deducoes matematicas; nenhum patch, script, build, teste, profiling, benchmark ou execucao de GPU.