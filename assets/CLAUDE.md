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

Herda os pisos 22–29 da `schematize-engineering` (git como trava de conclusão, deploy só do git, ops é o gate da IA, sem agents inúteis, relatório 30 min/handoff 6 h, CI remoto só antes do hml, microserviço autônomo, build em dev/hml + higiene).
