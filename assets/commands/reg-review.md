---
description: schematize-regression — revisa um PR/diff contra o piso de regressão: roda o gate e lê o que a máquina não lê.
argument-hint: "<PR, branch ou range A..B; vazio = último marco hml-*/v*>"
---

# /reg-review — o diff passa; a prova presta?

Alvo: `${ARGUMENTS}`

1. `bash .claude/skills/schematize-regression/scripts/check-regression.sh [--range A..B]` — reprovou
   (rc 1), corrija antes de opinar. rc 2 é "nada para verificar", não aprovação.
2. Leia o que a máquina não lê:
   - **O teste morde?** Foi visto falhar sem o fix? Reverta mentalmente o fix: o teste reclama?
   - **Nível certo:** o teste está no nível mais baixo que reproduz, ou é e2e caro sem necessidade?
   - **Enfraquecimento:** asserção relaxada, tolerância ampliada, mock que dribla o caminho do bug?
   - **Skip e quarentena:** cada marcador tem motivo real, dono e prazo? Há ADR para remoção?
   - **Snapshot/golden:** o diff do snapshot foi lido? Muda só o que o PR explica?
   - **Suíte:** a seleção por impacto tem falha segura? A completa roda pré-hml?
   - **Perf e visual:** mudança de baseline com motivo e dono?
   - **Incidente:** se o PR fecha incidente, há teste de regressão e o culpado registrado?
3. Entregue achados por gravidade, com o trecho e a correção. Waiver só com marcador e motivo escritos.
