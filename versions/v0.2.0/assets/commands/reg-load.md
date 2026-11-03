---
description: schematize-regression — carrega à força TODO o corpo normativo de regressão e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-regression`. A partir daqui, nesta sessão, isto **não é opcional**.

1. **Leia na íntegra, sem trabalhar de memória.** Caminho: `.claude/skills/schematize-regression/references/*.md`
   (projeto) ou `~/.claude/skills/schematize-regression/references/*.md` (global):
   - `bug-primeiro.md` — bug -> teste vermelho visto falhar -> fix; nível da pirâmide; ID do bug.
   - `permanencia.md` — teste permanente; skip e quarentena com dono e prazo; flaky não é regressão; marcadores.
   - `caracterizacao.md` — golden master antes de refatorar legado; snapshot com diff revisado.
   - `suite.md` — completa no merge e nightly; seleção por impacto só com a completa no merge.
   - `desempenho.md` — baseline versionado, limiar, ambiente estável, estatística.
   - `visual.md` — baseline, threshold, estabilização, revisão do diff.
   - `contrato-dados-ia.md` — regressão de contrato, dados e prompt: as donas.
   - `bisect.md` — `git bisect run`, culpado no postmortem.
   - `incidente-e-metricas.md` — incidente sem teste não fecha; reabertura e escapes.
   - `stack-versoes.md` — anexo volátil.
2. **Se houver git no projeto**, rode o gate: `bash .claude/skills/schematize-regression/scripts/check-regression.sh`
3. **Aplique daqui em diante** e diga qual piso está aplicando quando ele mudar o que você ia fazer.
   Nunca corrija bug sem o teste vermelho antes; nunca apague nem pule teste sem o marcador e o ADR.
