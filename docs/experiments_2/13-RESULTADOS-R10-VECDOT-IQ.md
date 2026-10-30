# Experiments 2 — Rodada 10: vec-dot MMVQ IQ3/IQ2/IQ4

Base analisada pelos agentes: experiment_2-1@859350618f092be062e649ddc09c223485bd3e5a. Consolidação dos quatro resumos fornecidos no chat; arquivos completos não anexados neste turno. Sem compilação, teste, script, perfil, benchmark ou execução de GPU.

## Decisão
**Nenhuma redução efetiva de instruções, registradores ou latência foi demonstrada por análise estática. Não aprovar alteração ampla do MMVQ.** Há três hipóteses de alteração localizada, com graus diferentes de justificativa; não atribuir ganhos de desempenho em gfx1101.

## Agente 1 — IQ3_S / IQ3_XXS
IQ3_S já dispõe de lógica equivalente a apply_ksigns; substituir por helper é refatoração, não avanço. IQ3_XXS usa __vcmpne4; alternativa apply_ksigns foi investigada antes e equivalência matemática não implica instruções melhores. Ambos já alimentam dp4a com operandos empacotados. Melhor hipótese documental IQ3_S: extração explícita de bits qh em lugar de indexação, matematicamente exata, mas compilador pode emitir o mesmo código. Separar acumuladores altera sequência de acumulação e fica fora do escopo.

## Agente 2 — IQ2_S
vec_dot_iq2_s_q8_1 usa oito dp4a, distribuídos entre sumi0 e sumi1, com duas multiplicações finais pelas escalas. A origem emprega ggml_cuda_mul_small (em HIP pode selecionar __mul24); a branch usa multiplicação inteira comum. Limite reportado para cada acumulador: 260.096, cabendo no intervalo inteiro assinado de 24 bits. Uma troca localizada tem equivalência matemática justificável **quando todos os operandos relevantes respeitarem os limites**, mas não comprova diferença no ISA AMD nem ganho. apply_ksigns é só refatoração.

## Agente 3 — IQ4_XS
No MMVQ denso, o loop de colunas W=2/4/8 invoca vec_dot_iq4_xs_q8_1 com mesmos pesos e ativações diferentes. Reuso da decodificação na mesma thread é estruturalmente possível, sem mudar R=1 ou wave32, mas pode já ser feito pelo compilador e aumenta tempo de vida de temporários e VGPR. W=1 não possui reuso entre colunas. Acumuladores mínimos por thread segundo agente: 1/2/4/8 para W=1/2/4/8. Proposta não se estende automaticamente ao MMQ.

## Agente 4 — seleção e conflitos
Para MUL_MAT denso e elegível, F32 nas ativações e saída, os quatro tipos podem selecionar MMVQ em W=1..8, antes de fusões ou dispatch alternativo. Gate/up/SwiGLU fundido é um caminho específico, não assumir que cobre W2..8. Preservar R=1, wave32, VDR, ordem de dp4a, limites de memória e fallback. Revisão adversarial recomenda especificação mínima de **um** formato, não alteração abrangente.

## Cruzamento e prioridade
1. **IQ3_S qh:** prioridade documental para decode W1 conforme agentes 1/4, mas a simplificação pode ser totalmente absorvida pelo compilador. Sem redução provada.
2. **IQ2_S ggml_cuda_mul_small:** hipótese localizada, com prova de faixa numérica para os acumuladores; não presumir melhora do gerador de código AMD. Separar de outras alterações.
3. **IQ4_XS reuso W2..8:** interessante apenas quando MMVQ for selecionado; risco de VGPR/spill cresce com W, especialmente W8; compilador pode antecipar invariantes.
4. **IQ3_XXS apply_ksigns:** hipótese já conhecida; não contabilizar como descoberta R10 nem prometer benefício.
5. Critério para próxima rodada documental: escolher uma única transformação, demonstrar equivalência para todos os valores legais, conferir o caminho de dispatch e justificar por fonte trabalho repetido não antecipado. Se só mudar a aparência do código, rejeitar.

**Veredito final:** oportunidades restritas e não comprovadas como ganhos; nenhum kernel alterado.
