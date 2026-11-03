#!/usr/bin/env bash
# herdado de schematize-engineering — não edite aqui (fonte: skill-engineering/scripts/check-ci-triggers.test.sh; regenere: node tools/sync-herdados.mjs)
# check-ci-triggers.test.sh — vermelho/verde do gate check-ci-triggers.sh (piso 27).
# strict-ok: harness de teste — roda todos os casos e soma (`schematize-shell` -> `references/piso.md` secao 1)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; G="$HERE/check-ci-triggers.sh"; rc=0
T="$(mktemp -d)"; trap 'rm -rf "${T:?}"' EXIT
CONC=$'concurrency:\n  group: ci-${{ github.ref }}\n  cancel-in-progress: true\n'
nega() { # nome, conteúdo, trecho esperado na saída
  printf '%s' "$2" > "$T/w.yml"
  out="$(bash "$G" "$T/w.yml" 2>&1)" && { echo "FAIL: '$1' deveria reprovar"; rc=1; return; }
  grep -q "$3" <<<"$out" || { echo "FAIL: '$1' sem a mensagem '$3'"; rc=1; }
}
passa() {
  printf '%s' "$2" > "$T/w.yml"
  bash "$G" "$T/w.yml" >/dev/null 2>&1 || { echo "FAIL: '$1' deveria passar"; rc=1; }
}
nega "push em branch" $'name: x\non:\n  push:\n    branches: [main]\n'"$CONC" "push em branch"
nega "push puro" $'name: x\non:\n  push:\n  workflow_dispatch:\n'"$CONC" "push em branch"
nega "inline push" $'name: x\non: [push, workflow_dispatch]\n'"$CONC" "push em branch"
nega "pull_request sem filtro" $'name: x\non:\n  pull_request:\n  workflow_dispatch:\n'"$CONC" "pull_request"
nega "pr com branches" $'name: x\non:\n  pull_request:\n    branches: [main]\n  workflow_dispatch:\n'"$CONC" "pull_request"
nega "pr com paths-ignore" $'name: x\non:\n  pull_request:\n    paths-ignore: ["**.md"]\n'"$CONC" "pull_request"
nega "pr com types" $'name: x\non:\n  pull_request:\n    types: [labeled]\n'"$CONC" "pull_request"
nega "pull_request_target com branches" $'name: x\non:\n  pull_request_target:\n    branches: [main]\n'"$CONC" "pull_request_target"
nega "push tags-ignore (abre branches)" $'name: x\non:\n  push:\n    tags-ignore: [x]\n'"$CONC" "push em branch"
nega "push branches-ignore" $'name: x\non:\n  push:\n    branches-ignore: [wip]\n'"$CONC" "push em branch"
nega "push tags + branches" $'name: x\non:\n  push:\n    tags: ["v*"]\n    branches: [main]\n'"$CONC" "push em branch"
nega "workflow_run" $'name: x\non:\n  workflow_run:\n    workflows: [a]\n'"$CONC" "workflow_run"
nega "merge_group" $'name: x\non:\n  merge_group:\n'"$CONC" "merge_group"
nega "issue_comment fora da allowlist" $'name: x\non:\n  issue_comment:\n'"$CONC" "allowlist"
nega "lista flow com pull_request" $'name: x\non: [workflow_dispatch, pull_request]\n'"$CONC" "pull_request"
nega "lista flow multilinha" $'name: x\non:\n  [workflow_dispatch,\n   pull_request]\n'"$CONC" "pull_request"
nega "lista bloco com -" $'name: x\non:\n  - push\n  - pull_request\n'"$CONC" "pull_request"
nega "lista bloco no mesmo indent" $'name: x\non:\n- workflow_dispatch\n- pull_request\n'"$CONC" "pull_request"
nega "escalar on: pull_request" $'name: x\non: pull_request\n'"$CONC" "pull_request"
nega "escalar on: push" $'name: x\non: push\n'"$CONC" "push em branch"
nega "flow map push sem tags" $'name: x\non: {push: {branches: [main]}, workflow_dispatch: }\n'"$CONC" "push em branch"
nega "flow map pull_request" $'name: x\non: {pull_request: {branches: [main]}}\n'"$CONC" "pull_request"
nega "chave on entre aspas" $'name: x\n"on":\n  pull_request:\n'"$CONC" "pull_request"
nega "evento entre aspas" $'name: x\non:\n  "pull_request":\n'"$CONC" "pull_request"
nega "anchor/alias no on" $'name: x\nx: &gat\n  branches: [main]\non:\n  push: *gat\n'"$CONC" "âncora"
nega "merge key no on" $'name: x\non:\n  push:\n    <<: *g\n'"$CONC" "âncora"
nega "push depois de pr tudo junto" $'name: x\non:\n  workflow_dispatch:\n  push:\n    tags: ["v*"]\n  pull_request:\n'"$CONC" "pull_request"
passa "dispatch + tags" $'name: x\non:\n  workflow_dispatch:\n  push:\n    tags: ["hml-*", "v*"]\n'"$CONC"
passa "tags em flow" $'name: x\non:\n  workflow_dispatch:\n  push: {tags: ["v*"]}\n'"$CONC"
passa "release published" $'name: x\non:\n  release:\n    types: [published]\n'"$CONC"
passa "cron justificado" $'# justificativa: deriva semanal acordada em ADR-9\nname: x\non:\n  schedule:\n    - cron: "0 6 * * 1"\n'"$CONC"
# allowlist versionada com justificativa libera; sem justificativa não
mkdir -p "$T/al"; printf '%s' $'name: x\non:\n  pull_request:\n'"$CONC" > "$T/al/w.yml"
printf 'w.yml pull_request justificativa: ADR-31 repo publico sem custo de CI\n' > "$T/al/ci-triggers-allow.txt"
bash "$G" "$T/al/w.yml" >/dev/null 2>&1 || { echo "FAIL: allowlist justificada deveria liberar"; rc=1; }
printf 'w.yml pull_request\n' > "$T/al/ci-triggers-allow.txt"
bash "$G" "$T/al/w.yml" >/dev/null 2>&1 && { echo "FAIL: allowlist sem justificativa deveria ser ignorada"; rc=1; }
# comentário não conta como gatilho
passa "push só em comentário" $'name: x\non:\n  workflow_dispatch:\n  # push:\n'"$CONC"
# dir sem workflows = nada a checar
mkdir -p "$T/vazio"; bash "$G" "$T/vazio" >/dev/null 2>&1 || { echo "FAIL: dir vazio deveria passar"; rc=1; }
# o template da casa precisa passar
bash "$G" "$HERE/../assets/ci/github-actions-ci.yml" >/dev/null 2>&1 || { echo "FAIL: template assets/ci/github-actions-ci.yml reprovado"; rc=1; }
[ "$rc" -eq 0 ] && echo "check-ci-triggers.test: OK"
exit "$rc"
