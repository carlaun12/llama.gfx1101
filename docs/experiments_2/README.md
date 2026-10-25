# Experiments 2 — pesquisa documental dos kernels MMVQ IQ

**Alvo:** `Swift-1.5-Qwen3.8-27B-Uncensored-Dynamic-MTP-RCO-IQ3_XXS.gguf` de `ajgazin`; AMD Radeon RX 7800 XT (`gfx1101`, 16 GiB). **Branch:** `deep-research`.

**Referências de comparação já registradas:** destino `carlaun12/llama.gfx1101@31288c9c66e59377f7788d920678a565bb89dd37`; origem `stew675/llama.cpp@e8bd52069ca049cd5213366363451abbb5383865`.

**Modo:** documentação e pesquisa pública exclusivamente. Não executar, pedir ou sugerir testes, builds, benchmarks, scripts, traces, logs, acesso local nem GPU remota. Não modificar kernels ou `master`.

**Proveniência dos percentuais:** imagem enviada pelo usuário na conversa em 25/10/2026, atribuída no próprio texto ao **“perfil de U”**. O arquivo bruto de profiling, sua URL/publicação, hardware, compilação, parâmetros, método de medição e identificação completa de “U” **não foram fornecidos**. Não tratar esse retrato como medida do GGUF/alvo nem prever speedup.

## Objetivo

Esta pasta organiza a investigação dos **kernels MMVQ de pesos quantizados** a partir da participação reportada na imagem enviada pelo usuário, **sem converter esse material em benchmark da RX 7800 XT**.

A principal hipótese de trabalho é examinar o custo e as otimizações seguras de **`IQ2_S`**, preservando a análise separada das três outras classes de peso com participação reportada.

## Arquivos

| Documento | O que contém | Estado |
| --- | --- | --- |
| [perfil-mmvq-recebido.md](perfil-mmvq-recebido.md) | Transcrição da imagem, denominadores, proveniência e limites | Registrado; procedência não verificada |
| [iq2_s.md](iq2_s.md) | Primeira hipótese técnica, sinais, dequantização e MMVQ | Aguardando pesquisa do Agente 1 |
| [iq3_s.md](iq3_s.md) | Custos e diferenças de código de IQ3_S | Aguardando pesquisa do Agente 2 |
| [iq3_xxs.md](iq3_xxs.md) | Custos e diferenças de código de IQ3_XXS | Aguardando pesquisa do Agente 3 |
| [iq4_xs.md](iq4_xs.md) | IQ4_XS e a matriz `output.weight` grande | Aguardando pesquisa do Agente 4 |

**As missões e seus prompts são apresentados ao usuário no chat, não gravados aqui.** O material atual registra hipóteses, fontes pré-existentes e lacunas.

## Disciplina de evidência

1. Toda porcentagem proveniente do perfil de “U” deve vir marcada **reportada na imagem, contexto não confirmado**.
2. Dados de quantização do manifesto `ajgazin` não são profiling nem definem automaticamente o tempo por formato.
3. Distinguir `MMVQ` (matvec quantizado; decode/verify condicionado) de `MMQ` (matmul quantizado; prefill condicionado) e de `MUL_MAT_ID` para roteamento MoE, não aplicável à estrutura densa do alvo.
4. Separar **fato de fonte**, **demonstração matemática**, **estimativa condicional** e **hipótese não verificada**.
5. Cada agente entrega relatório Markdown; o assistente somente revisa e consolida documentos.
6. Nenhuma inferência empírica sobre ganhos em `gfx1101` ou execução de testes no hardware.

## Referências existentes

- [MMVQ IQ misto RCO](../../research/mmvq-iq-mistos-rco.md)
- [MMVQ Q4_K/Q6_K e VDR](../../research/mmvq-q4k-q6k-vdr.md)
- [MMQ unpack IQ RCO](../../research/mmq-unpack-iq-rco.md)
- [Perfil do GGUF escolhido](../../research/MODELO-ALVO.md)
- [Acompanhamento geral](../../todo.md)

**Aberto em:** 2026-10-25. **Implementações ou benchmarks:** nenhum.
