---
description: schematize-regression — acha o commit culpado com git bisect run e o teste reprodutor, e prepara o registro no postmortem.
argument-hint: "<comando do teste reprodutor> [bom=<tag/sha>]"
---

# /reg-bisect — busca binária automática do commit culpado

Alvo: `${ARGUMENTS}`. Leia antes `references/bisect.md`.

1. **Pré-requisito:** o teste reprodutor falha de modo determinístico no commit atual (`/reg-bug`). Se é
   intermitente, rode-o N vezes por commit no script ou conserte o determinismo antes.
2. **Defina o bom e o ruim:** `bad` = HEAD (ou onde o bug aparece); `good` = última tag/release em que o
   teste passa (confirme rodando lá, não presuma).
3. **Isole:** crie uma worktree (`git worktree add`) para não sujar o trabalho em curso.
4. **Escreva o script de decisão** (0 bom, 1 ruim, 125 pular quando não compila) que garante que o teste
   reprodutor existe em cada commit testado.
5. **Rode** `git bisect run <script>`, guarde `git bisect log` e **sempre** `git bisect reset` e remova a worktree.
6. **Leia o commit culpado e o PR:** reverter é mitigação segura em incidente aberto
   (`schematize-incident`); o fix definitivo leva o teste permanente com o ID.
7. **Registre** SHA, PR, `bisect.log` e a pergunta "por que a suíte não pegou?" no postmortem.

Entregue: o SHA culpado, a evidência (log), a ação proposta e o que não foi verificado (ex.: commits pulados).
