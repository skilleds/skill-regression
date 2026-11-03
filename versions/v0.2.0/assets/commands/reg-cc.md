---
description: schematize-regression — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, **grave o handoff** em `<projeto>/<projeto>_archive/context/` no par **context + checklist**
do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`), FEITO vs ABERTO. Inclua: bugs em andamento
(ID, teste vermelho escrito? visto falhar?), bisects abertos (bom/ruim atuais), skips e quarentenas com prazo,
baselines de perf/visual pendentes de revisão e o que o gate `check-regression.sh` acusou. Nunca inclua segredo
nem dado pessoal. Só então rode `/compact`.
