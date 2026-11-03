# Changelog — schematize-regression

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.2.0] — 2026-11-03
### Corrigido
- `check-regression.sh`: o range padrão deixa de ser `origin/main..HEAD` (sempre vazio com push imediato, piso 22): agora é o último marco `hml-*`/`v*`, senão a base remota se não vazia, senão os últimos 20 commits.
- `regression-skip:` em mensagem de commit só vale para o arquivo que nomeia (antes um marcador liberava todos os `teste-removido`/`skip-sem-marcador` do range); marcador sem arquivo avisa e não libera nada.
- Suíte/perf/visual: "PR / merge / nightly" trocado por local por commit, pré-hml (tag), sob demanda e release (piso 27); `/reg-suite` aponta `pull_request`/`schedule` como achado.
### Adicionado
- Incidente de resiliência vira um dos 7 testes do piso 28; bloco "Herda os pisos 22–29"; 10 testes novos do gate (um marcador/dois skips, push imediato com e sem tag, HEAD taggeado).
### Pendente (on-hold)
- `[~]` "fix com teste" ainda aceita qualquer arquivo de teste e não prova a ordem vermelho→verde (exige decisão: ID do bug no teste / `Red-run:`).

## [0.1.1] — 2026-10-15
### Corrigido
- CHANGELOG da 0.1.0 dizia "10 comandos `/reg-*`"; são 11 (`assets/commands/`).
- Removido `versions/v0.0.0/` (`.gitkeep` provisório do hack que o `tools/release.mjs` exigia antes de
  suportar a 1ª versão nativamente); `versions/` agora só tem versões realmente publicadas.
- Porquê: snapshot fantasma de uma versão que nunca existiu confunde quem audita o histórico.

## [0.1.0] — 2026-10-15
Primeira versão. A `schematize-qa` cobre estratégia e pirâmide, mas ninguém era dono do ciclo "bug
corrigido nunca volta": o fix sem teste, o teste apagado ou pulado "para destravar o merge", o snapshot
atualizado às cegas e o incidente fechado sem teste correspondente são os caminhos pelos quais o mesmo
bug retorna, e todos são visíveis no diff, antes do merge.

### Adicionado
- `SKILL.md` com 13 pisos, fronteira com qa/api/data/ai/incident/git e 11 comandos `/reg-*`
  (`bug`, `bisect`, `suite`, `perf`, `visual`, `review` mais os herdados).
- 9 references: bug primeiro, permanência, caracterização, suíte, desempenho, visual,
  contrato/dados/IA, bisect, incidente e métricas; mais o anexo volátil.
- `scripts/check-regression.sh`: reprova commit `fix:` sem teste, teste removido e skip/only/ignore
  sem marcador `regression-skip` (dono e prazo); avisa de snapshot sem teste, fix sem ID e skip
  vencido. Com `check-regression.test.sh` (repos temporários, vermelho e verde).

### Não verificado
- Ferramentas de snapshot visual e benchmark por ecossistema: a skill é agnóstica e não as comparou.
