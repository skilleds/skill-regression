---
description: Mapa da skill schematize-regression (regressão: bug corrigido nunca volta, provado por máquina).
---
**schematize-regression** — bug corrigido nunca volta; mudança não quebra o que funcionava.

| Comando | O que faz |
|---|---|
| `/reg-help` | esta lista |
| `/reg-load` | carrega à força TODO o corpo normativo (bug primeiro, permanência, caracterização, suíte, desempenho, visual, bisect, métricas) e passa a aplicá-lo |
| `/reg-bug` | transforma um bug em teste vermelho reprodutor, visto falhar, antes do fix |
| `/reg-bisect` | acha o commit culpado com `git bisect run` e o teste reprodutor |
| `/reg-suite` | planeja ou audita a suíte: completa vs impacto, nightly, quarentena |
| `/reg-perf` | baseline versionado e limiar de benchmark que trava o CI |
| `/reg-visual` | baseline visual por componente/rota, threshold e revisão do diff |
| `/reg-review` | revisa um PR/diff contra o piso e roda `scripts/check-regression.sh` |
| `/reg-claude` | cria ou mescla o `CLAUDE.md` sempre-on de regressão |
| `/reg-cc` · `/reg-handoff` | context compact / handoff no archive |

Pareia com: `schematize-qa` (estratégia e pirâmide), `schematize-incident` (postmortem), `schematize-api`
(contrato), `schematize-data` (dados), `schematize-ai` (evals), `schematize-git` (commits).
