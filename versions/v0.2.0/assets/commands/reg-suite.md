---
description: schematize-regression — planeja ou audita a suíte de regressão: completa vs impacto, pré-hml, quarentena e skips vencidos.
argument-hint: "[repo ou pasta; vazio = repo atual]"
---

# /reg-suite — a suíte protege se roda inteira onde importa

Alvo: `${ARGUMENTS}`. Leia antes `references/suite.md` e `references/permanencia.md`.

1. **Mapeie o pipeline real** (CI): o que roda local por commit, pré-hml (tag), sob demanda e no release; aponte `on: pull_request`/`schedule` como achado (piso 27, `check-ci-triggers.sh`).
   Mostre a tabela atual contra a do piso.
2. **Confira os vetos:** a suíte completa roda pré-hml? Há job `allow-failure`, retry até passar, teste
   apagado para acelerar? Seleção por impacto local tem mapa datado e falha segura (completa em mudança
   de config/build/dependência)?
3. **Rode o gate** no histórico recente: `bash scripts/check-regression.sh --range <A..B>`.
4. **Quarentena e skips:** liste os marcadores `regression-skip` (`grep -rn "regression-skip"`), os vencidos
   e os skips sem marcador; cada um com dono e prazo, ou vira ação.
5. **Saúde:** duração p50/p95 do gate local e do pré-hml, testes mais lentos, taxa de flaky, módulos críticos sem
   teste de regressão (`suite.md` seção 6).
6. **Plano:** ações ordenadas (o que dá mais proteção por minuto de CI), cada uma com dono e prazo.

Não altere o CI sem aprovação. Entregue o diagnóstico em achados por gravidade e diga o que não foi medido.
