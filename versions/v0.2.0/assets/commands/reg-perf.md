---
description: schematize-regression — define baseline versionado e limiar de benchmark que trava o CI, com comparação estatística.
argument-hint: "<caminho crítico ou métrica a proteger>"
---

# /reg-perf — desempenho com baseline e limiar

Alvo: `${ARGUMENTS}`. Leia antes `references/desempenho.md`.

1. **Escolha poucas métricas** que o usuário ou a conta sentem (p95, alocação por operação, bundle,
   queries por requisição). Justifique cada uma.
2. **Estabilize o ambiente:** runner dedicado, warm-up descartado, dados fixos, sem rede real, toolchain
   fixada. Rode o benchmark duas vezes no mesmo commit; se não repete dentro do ruído, conserte o
   ambiente antes de seguir.
3. **Capture o baseline** (N amostras, mediana e intervalo) num arquivo versionado com ambiente e commit.
4. **Defina o limiar** por métrica e a regra estatística (diferença significativa e acima do limiar
   reprova).
5. **Integre ao CI:** PR com os microbenchmarks dos caminhos tocados e bundle; nightly com o conjunto
   completo e série temporal. Falha trava; novo baseline exige commit revisado com motivo.
6. **Prove que morde:** introduza uma lentidão proposital e veja o CI reprovar; remova e veja passar.

Entregue: métricas, limiares, arquivo de baseline, trecho de CI, a prova do vermelho. Diga o que não rodou.
