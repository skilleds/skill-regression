---
description: schematize-regression — gera o handoff (context.md + checklist.md) no archive, sem compactar.
---
Gere o handoff em `<projeto>/<projeto>_archive/context/`: `AAAA-MM-DD-<slug>-context.md` (bug/regressão em
curso, teste reprodutor e seu estado vermelho/verde, commit culpado se achado, decisões e o que o gate acusou) e
`AAAA-MM-DD-<slug>-checklist.md` (FEITO vs ABERTO, nas três classes: `- [ ]` máquina · `- [H ]` humano · `- [~]` on-hold).
Não compacte, só grave. Nunca grave segredo nem dado pessoal no handoff.
