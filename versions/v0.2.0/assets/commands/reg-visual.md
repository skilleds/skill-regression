---
description: schematize-regression — monta baseline visual por componente/rota com threshold, estabilização e revisão do diff.
argument-hint: "<componente ou rota a proteger>"
---

# /reg-visual — a aparência também tem teste

Alvo: `${ARGUMENTS}`. Leia antes `references/visual.md`.

1. **Liste os estados** que valem baseline (vazio, preenchido, erro, carregando, claro e escuro, mobile
   e desktop); poucos e bem escolhidos.
2. **Estabilize:** fontes carregadas e fixas no runner, animações desligadas, dados mockados, sem rede,
   mesmo navegador e sistema da captura (imagem de contêiner).
3. **Capture o baseline no CI/contêiner**, nunca na máquina do dev, e versione (git ou LFS).
4. **Threshold** declarado (tolerância de pixels e de cor), com justificativa; nunca ajustado porque um
   teste piscou.
5. **Relatório de diff** com baseline, atual e diferença; a atualização do baseline é humana, no PR,
   com o motivo.
6. **Prove que morde:** mude uma cor ou margem de propósito e veja o teste reprovar; reverta.

Entregue: estados, threshold, onde roda (componente por commit local, rota pré-hml/sob demanda), prova do vermelho e o
que não foi verificado. Mídia nova nunca pelo Claude: regra de mídia da skill.
