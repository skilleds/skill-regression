# Piso de regressão (schematize-regression) — sempre-on

Bug corrigido nunca volta; mudança não quebra o que funcionava. Provado por máquina, não por memória.

1. **Bug -> teste vermelho primeiro:** o teste que reproduz o bug é escrito, **visto falhar** e só então vem o fix. Nível mais baixo da pirâmide que reproduz; cita o ID do bug/incidente. Commit `fix:` sem teste é recusado.
2. **Teste de regressão é permanente:** nunca apague nem pule sem ADR. Skip/quarentena leva `regression-skip: <motivo> <@dono> <AAAA-MM-DD>`. Flaky é bug do teste, não regressão: não esconda falha determinística como flaky.
3. **Refatorar legado sem teste:** golden master (caracterização) antes. Snapshot só se atualiza com o diff revisado por humano, nunca em massa.
4. **Suíte completa pré-hml (tag) e sob demanda;** por commit roda local (`tools/ci.sh`, com `check-regression.sh`); seleção por impacto só local e só se a completa roda pré-hml. Nunca pule a regressão para agilizar.
5. **Desempenho e visual** têm baseline versionado e limiar que trava o CI; comparação estatística, ambiente estável, diff visual revisado.
6. **Regressão se caça com `git bisect run`;** o commit culpado vai para o postmortem. Incidente sem teste de regressão não fecha.
7. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

Mídia: imagem/visual gerado nunca por modelo Claude; detecte Codex/Gemini e pergunte qual usar.

Gate: `bash .claude/skills/schematize-regression/scripts/check-regression.sh [dir] [--range A..B]` — marcadores
`regression-skip:`, `regression-ok: fix-sem-teste`, `regression-snapshot:` (sem motivo não vale).

<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->
