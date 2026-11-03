---
description: schematize-regression — transforma um bug em teste vermelho reprodutor, visto falhar, ANTES de qualquer fix.
argument-hint: "<ID do bug ou descrição do sintoma>"
---

# /reg-bug — o bug vira teste antes de virar código

Bug: `${ARGUMENTS}`. Leia antes `references/bug-primeiro.md`.

1. **Entenda o sintoma e o ID.** Sem ID de bug/incidente, peça ou abra um; ele vai no nome do teste e
   no commit. Não reproduz? Pare: é hipótese, não fix (`bug-primeiro.md` seção 6).
2. **Escolha o nível mais baixo da pirâmide** que reproduz (unitário -> integração -> contrato ->
   e2e) e diga por quê. Para bug de contrato, dado ou prompt, aponte a dona (`contrato-dados-ia.md`).
3. **Escreva o teste reprodutor** com o ID. Ele não dispara efeito externo real.
4. **Rode e VEJA FALHAR.** Cole a saída do vermelho e confirme que falha pelo motivo do bug, não por
   erro de compilação ou fixture. Não falhou? O teste não reproduz; reescreva.
5. **Só então corrija**, no menor passo, e rode o teste (verde) e a suíte do módulo.
6. **Commit** `fix(<escopo>): <resumo> (<ID>)` com o teste no mesmo commit, ou `test:` reprodutor
   imediatamente antes do `fix:`. Rode `bash scripts/check-regression.sh`.
7. Se o bug veio de incidente: acrescente a ação "teste de regressão" ao postmortem
   (`references/incidente-e-metricas.md`).

Entregue: ID, nível do teste e por quê, saída do vermelho, saída do verde, commit, saída do gate. Diga o
que não rodou.
