#!/usr/bin/env bash
# check-regression.sh — gate de regressão da casa (schematize-regression), agnóstico de linguagem.
#
# Motivo: bug corrigido que volta é o defeito mais caro de reaparecer, e quase sempre volta porque o
# fix não deixou teste, ou porque o teste que o guardava foi apagado, pulado ou "atualizado às cegas".
# Isso é visível no diff, antes do merge; este gate pega na máquina, não na memória do revisor.
# Como funciona: lê um range git (padrão origin/main..HEAD) e aplica as regras:
#   fix-sem-teste       commit `fix:`/`fix(...)` (Conventional Commits) sem arquivo de teste no commit
#                       (aceita `test:` imediatamente anterior no range, ou teste inline adicionado)
#   teste-removido      arquivo de teste apagado, ou arquivo de teste com menos casos do que tinha
#   skip-sem-marcador   skip/only/xit/@Ignore/@Disabled/t.Skip/#[ignore]/xfail adicionado sem marcador
#   marcador-invalido   `regression-skip:` presente mas sem dono (@alguém) e prazo (AAAA-MM-DD)
# Avisos (não reprovam): snapshot-sem-teste (snapshot/golden alterado sem teste no mesmo commit),
#   fix-sem-id (fix sem ID de bug/incidente), skip-vencido (prazo do marcador já passou).
# Marcadores (na linha adicionada ou em qualquer mensagem de commit do range):
#   regression-skip: <motivo> <@dono> <AAAA-MM-DD>   autoriza skip/quarentena ou teste removido (cite o ADR)
#   regression-ok: fix-sem-teste <motivo>            (corpo do commit) fix sem teste automatizável possível
#   regression-snapshot: <motivo>                    (corpo do commit) snapshot revisado por humano
# Entrada: check-regression.sh [dir] [--range A..B]   dir padrão "."
#   Range padrão (piso 22: commit+push na hora deixa origin/main..HEAD sempre vazio): o ÚLTIMO MARCO —
#   a tag hml-*/v* mais recente alcançável que não seja o próprio HEAD —; sem tag, origin/main..HEAD
#   (ou o upstream/main) SE tiver commits; senão os últimos 20 commits (HEAD~20..HEAD). O range escolhido
#   é impresso no resumo.
#   Marcador `regression-skip:` em MENSAGEM de commit só vale para o arquivo que ele nomeia (caminho ou
#   nome do arquivo no fim da linha); marcador sem arquivo não libera nada (aviso marcador-sem-arquivo).
#   Na linha adicionada, o marcador vale para aquela linha.
# Saída: 0 passa · 1 reprova · 2 nada para verificar (sem commits no range, não é repo) — NÃO é aprovação.
set -euo pipefail

DIR="."; RANGE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --range) RANGE="${2:?--range exige A..B}"; shift 2 ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    -*) echo "opção desconhecida: $1" >&2; exit 2 ;;
    *) DIR="$1"; shift ;;
  esac
done

g() { git -C "$DIR" "$@"; }
g rev-parse --git-dir >/dev/null 2>&1 || { echo "check-regression: '$DIR' não é um repositório git — nada para verificar" >&2; exit 2; }

# O que: acha o range padrão quando --range não veio (ver cabeçalho). Devolve 0 e preenche RANGE.
range_nao_vazio() { [ -n "$(g rev-list --no-merges -n 1 "$1" 2>/dev/null)" ]; }
resolver_range() {
  local ref up cur tag head_sha n
  head_sha="$(g rev-parse --verify -q HEAD 2>/dev/null)" || return 1
  # 1. último marco (tag de promoção) que não aponta para o próprio HEAD
  while IFS= read -r tag; do
    [ -n "$tag" ] || continue
    [ "$(g rev-parse --verify -q "$tag^{commit}")" = "$head_sha" ] && continue
    RANGE="$tag..HEAD"; return 0
  done < <(g tag --merged HEAD --sort=-creatordate --list 'hml-*' 'v*' 2>/dev/null)
  # 2. sem marco: a base remota, mas só se ela não for vazia (push imediato esvazia)
  for ref in origin/main origin/master; do
    if g rev-parse --verify -q "$ref^{commit}" >/dev/null 2>&1 && range_nao_vazio "$ref..HEAD"; then RANGE="$ref..HEAD"; return 0; fi
  done
  if up="$(g rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)" && range_nao_vazio "$up..HEAD"; then RANGE="$up..HEAD"; return 0; fi
  cur="$(g rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  for ref in main master; do
    if [ "$cur" != "$ref" ] && g rev-parse --verify -q "$ref^{commit}" >/dev/null 2>&1 && range_nao_vazio "$ref..HEAD"; then RANGE="$ref..HEAD"; return 0; fi
  done
  # 3. janela limitada: os últimos 20 commits (ou o histórico todo, se menor)
  n="$(g rev-list --count HEAD 2>/dev/null || echo 0)"
  [ "$n" -gt 0 ] || return 1
  if [ "$n" -gt 20 ]; then RANGE="HEAD~20..HEAD"; else RANGE="$(g rev-list --max-parents=0 HEAD | tail -n 1)..HEAD"; fi   # histórico curto: da raiz (exclusiva) até HEAD
  return 0
}
if [ -z "$RANGE" ] && ! resolver_range; then
  echo "check-regression: sem commits, tag, origin/main nem main para comparar — informe --range A..B (nada para verificar)" >&2
  exit 2
fi

case "$RANGE" in
  *...*) L="${RANGE%%...*}"; R="${RANGE##*...}" ;;
  *..*)  L="${RANGE%%..*}";  R="${RANGE##*..}" ;;
  *) echo "check-regression: range inválido '$RANGE' (use A..B)" >&2; exit 2 ;;
esac
[ -n "$L" ] || L="HEAD"
[ -n "$R" ] || R="HEAD"
BASE="$(g merge-base "$L" "$R" 2>/dev/null || true)"
[ -n "$BASE" ] || BASE="$(g rev-parse --verify -q "$L^{commit}" 2>/dev/null || true)"
[ -n "$BASE" ] || { echo "check-regression: não resolvi o range '$RANGE' — nada para verificar" >&2; exit 2; }

COMMITS="$(g rev-list --no-merges --reverse "$BASE..$R" 2>/dev/null || true)"
[ -n "$COMMITS" ] || { echo "check-regression: nenhum commit em $RANGE — nada para verificar (não é aprovação)" >&2; exit 2; }
NCOMMITS="$(printf '%s\n' "$COMMITS" | wc -l | tr -d ' ')"

# Padrões (ERE). Ajuste aqui, não espalhe.
FIX_RE='^fix(\([^)]*\))?!?: '
TEST_TYPE_RE='^test(\([^)]*\))?!?: '
TESTPATH_RE='(^|/)(tests?|specs?|__tests__|e2e|testdata|cypress|playwright)/|(_test|_spec|\.test|\.spec|_tests)\.[A-Za-z0-9]+$|(^|/)test_[^/]*\.[A-Za-z0-9]+$|(Test|Tests|IT|Spec)\.(java|kt|cs|scala|swift)$'
SNAP_RE='(^|/)__snapshots__/|\.snap$|\.snap\.[a-z]+$|\.approved\.[A-Za-z0-9]+$|\.received\.[A-Za-z0-9]+$|\.golden$|\.golden\.[a-z]+$|(^|/)golden/|-snapshots/'
INLINE_TEST_RE='#\[(tokio::)?test|#\[cfg\(test\)\]|(^|[^A-Za-z0-9_.])(it|test|specify|describe)\(|def test_|func Test[A-Z_0-9]|fn test_|@Test|\[Fact\]|\[Theory\]|^[[:space:]]*test "'
SKIP_RE='(^|[^A-Za-z0-9_])(xit|xdescribe|xtest|fit|fdescribe)\(|(it|test|describe|context|suite|specify)\.(skip|only)\([[:space:]]*["'"'"'`]|@Ignore|@Disabled|t\.Skip(Now|f)?\(|#\[ignore|pytest\.mark\.(skip|xfail)|pytest\.skip\(|@unittest\.skip|^[[:space:]]*(skip|pending|xit|xspecify)[[:space:]]+["'"'"']'
ID_RE='#[0-9]+|[A-Z][A-Z0-9]+-[0-9]+|(Fixes|Closes|Resolves|Refs)[[:space:]]'
MARC_RE='regression-skip:[[:space:]]+.*[[:space:]][^[:space:]]*@[^[:space:]]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}'
MARC_ANY_RE='regression-skip:'

erros=0; avisos=0
erro()  { printf '%s: [ERRO %s] %s\n' "$1" "$2" "$3"; erros=$((erros+1)); }
aviso() { printf '%s: [AVISO %s] %s\n' "$1" "$2" "$3"; avisos=$((avisos+1)); }

eh_snapshot() { printf '%s' "$1" | grep -Eq "$SNAP_RE"; }
eh_teste() { ! eh_snapshot "$1" && printf '%s' "$1" | grep -Eq "$TESTPATH_RE"; }

# O que: valida os marcadores `regression-skip:` de um texto; devolve 0 se há marcador VÁLIDO.
# Marcador presente porém inválido é reportado (marcador-invalido) uma vez por origem.
marcador_valido() { # marcador_valido <texto> <origem>
  local txt="$1" origem="$2" l tem_valido=1
  while IFS= read -r l; do
    printf '%s' "$l" | grep -q "$MARC_ANY_RE" || continue
    if printf '%s' "$l" | grep -Eq "$MARC_RE"; then
      tem_valido=0
      avisar_vencido "$l" "$origem"
    else
      erro "$origem" "marcador-invalido" "regression-skip exige <motivo> <@dono> <AAAA-MM-DD>: '$(printf '%s' "$l" | cut -c1-100)'"
    fi
  done <<<"$txt"
  return "$tem_valido"
}
avisar_vencido() { # avisar_vencido <linha> <origem>
  local data hoje
  data="$(printf '%s' "$1" | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -n 1)"
  hoje="$(date +%F)"
  if [ -n "$data" ] && [[ "$data" < "$hoje" ]]; then
    aviso "$2" "skip-vencido" "prazo $data já passou: conserte o teste ou renove com justificativa"
  fi
}

# Marcadores em MENSAGENS de commit: só os VÁLIDOS entram, e cada um só vale para o arquivo que nomeia
# (caminho ou nome do arquivo na linha). Marcador sem arquivo não libera nada.
MSGS="$(g log --no-merges --format=%B "$BASE..$R")"
MARC_MSG="$(mktemp)"; trap 'rm -f "${MARC_MSG:?}"' EXIT
if printf '%s' "$MSGS" | grep -q "$MARC_ANY_RE"; then
  while IFS= read -r l; do
    printf '%s' "$l" | grep -q "$MARC_ANY_RE" || continue
    if printf '%s' "$l" | grep -Eq "$MARC_RE"; then
      avisar_vencido "$l" "mensagens($RANGE)"
      printf '%s\n' "$l" >> "$MARC_MSG"
    else
      erro "mensagens($RANGE)" "marcador-invalido" "regression-skip exige <motivo> <@dono> <AAAA-MM-DD> <arquivo>: '$(printf '%s' "$l" | cut -c1-100)'"
    fi
  done <<<"$MSGS"
fi
# cobre <arquivo>: 0 se algum marcador de mensagem nomeia esse arquivo (caminho completo ou basename).
cobre() {
  [ -s "$MARC_MSG" ] || return 1
  grep -qF -- "$1" "$MARC_MSG" || grep -qF -- "$(basename "$1")" "$MARC_MSG"
}
if [ -s "$MARC_MSG" ]; then
  while IFS= read -r l; do
    d="$(printf '%s' "$l" | sed -E 's/.*[0-9]{4}-[0-9]{2}-[0-9]{2}//')"
    [ -n "$(printf '%s' "$d" | tr -d '[:space:]')" ] || aviso "mensagens($RANGE)" "marcador-sem-arquivo" "regression-skip sem arquivo no fim da linha não libera nada: '$(printf '%s' "$l" | cut -c1-80)'"
  done < "$MARC_MSG"
fi

prev_teste=1   # 0 quando o commit imediatamente anterior é `test:` e toca teste
while IFS= read -r sha; do
  [ -n "$sha" ] || continue
  curto="$(g rev-parse --short "$sha")"
  subj="$(g log -1 --format=%s "$sha")"
  body="$(g log -1 --format=%B "$sha")"
  toca_teste=1; toca_snap=1
  while IFS= read -r -d '' f; do
    if eh_snapshot "$f"; then toca_snap=0
    elif eh_teste "$f"; then toca_teste=0; fi
  done < <(g diff-tree --root --no-commit-id --name-only -r -z "$sha")
  patch="$(g show --format= -U0 --no-color --no-ext-diff "$sha" 2>/dev/null | grep '^+' || true)"
  if [ "$toca_teste" -ne 0 ] && printf '%s' "$patch" | grep -Eq "$INLINE_TEST_RE"; then toca_teste=0; fi

  if [[ "$subj" =~ $FIX_RE ]]; then
    if [ "$toca_teste" -ne 0 ] && [ "$prev_teste" -ne 0 ] \
       && ! printf '%s' "$body" | grep -Eq 'regression-ok:[[:space:]]*fix-sem-teste[[:space:]]+[^[:space:]]+'; then
      erro "$curto" "fix-sem-teste" "'$subj' não toca teste: todo fix nasce de um teste que reproduz o bug e foi visto falhar (BUG -> teste vermelho -> fix). Sem teste automatizável possível: 'regression-ok: fix-sem-teste <motivo>' no corpo"
    fi
    if ! printf '%s' "$subj"$'\n'"$body" | grep -Eq "$ID_RE"; then
      aviso "$curto" "fix-sem-id" "fix sem ID de bug/incidente (#123, BUG-12, INC-2026-001): o teste e o postmortem precisam apontar para ele"
    fi
  fi

  if [ "$toca_snap" -eq 0 ] && [ "$toca_teste" -ne 0 ] \
     && ! printf '%s' "$body" | grep -Eq 'regression-snapshot:[[:space:]]*[^[:space:]]+'; then
    aviso "$curto" "snapshot-sem-teste" "snapshot/golden alterado sem teste no commit: snapshot atualizado às cegas é proibido; revise o diff e registre 'regression-snapshot: <motivo>'"
  fi

  prev_teste=1
  if [[ "$subj" =~ $TEST_TYPE_RE ]] && [ "$toca_teste" -eq 0 ]; then prev_teste=0; fi
done <<<"$COMMITS"

# Teste apagado (arquivo inteiro).
while IFS=$'\t' read -r st path; do
  [ "$st" = "D" ] || continue
  if eh_teste "$path" && ! cobre "$path"; then
    erro "$path" "teste-removido" "arquivo de teste apagado: teste de regressão é permanente; remover exige ADR e 'regression-skip: <motivo> <@dono> <AAAA-MM-DD>' no commit"
  fi
done < <(g diff --name-status -M --no-ext-diff "$BASE" "$R")

# Casos de teste a menos dentro de arquivo que continua existindo, e skip adicionado, lidos do diff cumulativo.
DECL_RE='(^|[^A-Za-z0-9_.])(it|test|specify)\(|def test_|func Test[A-Z_0-9]|fn test_|#\[test\]|#\[tokio::test|@Test|\[Fact\]|\[Theory\]|^test "'
DIFF="$(g diff -U0 --no-color --no-ext-diff "$BASE" "$R")"
if [ -n "$DIFF" ]; then
  # awk: por arquivo (não apagado), conta declarações de teste removidas vs adicionadas.
  while IFS=$'\t' read -r path rem add; do
    [ -n "$path" ] || continue
    if eh_teste "$path" && [ "$rem" -gt "$add" ] && ! cobre "$path"; then
      erro "$path" "teste-removido" "$((rem - add)) caso(s) de teste a menos: remover teste exige ADR e 'regression-skip: <motivo> <@dono> <AAAA-MM-DD>' no commit"
    fi
  done < <(printf '%s\n' "$DIFF" | DECL_RE="$DECL_RE" awk '
    BEGIN { decl=ENVIRON["DECL_RE"] }
    /^diff --git / { arq=$4; sub(/^b\//, "", arq); apagado=0; if (!(arq in vis)) { vis[arq]=1; ordem[++n]=arq } ; next }
    /^deleted file mode/ { apagado=1; next }
    /^(---|\+\+\+) / { next }
    apagado { next }
    /^-/ { if (substr($0,2) ~ decl) rem[arq]++; next }
    /^\+/ { if (substr($0,2) ~ decl) add[arq]++; next }
    END { for (i=1;i<=n;i++) { a=ordem[i]; if (rem[a] > 0) printf "%s\t%d\t%d\n", a, rem[a], add[a]+0 } }')

  # Linhas adicionadas: arquivo, linha, texto.
  while IFS=$'\t' read -r path ln texto; do
    [ -n "$path" ] || continue
    if printf '%s' "$texto" | grep -Eq "$SKIP_RE"; then
      if printf '%s' "$texto" | grep -q "$MARC_ANY_RE"; then
        marcador_valido "$texto" "$path:$ln" || erro "$path:$ln" "skip-sem-marcador" "skip adicionado com marcador inválido: '$(printf '%s' "$texto" | sed -E 's/^[[:space:]]+//' | cut -c1-80)'"
      elif ! cobre "$path"; then
        erro "$path:$ln" "skip-sem-marcador" "skip/only/ignore adicionado sem 'regression-skip: <motivo> <@dono> <AAAA-MM-DD>' (na linha, ou na mensagem nomeando o arquivo): '$(printf '%s' "$texto" | sed -E 's/^[[:space:]]+//' | cut -c1-80)'"
      fi
    fi
  done < <(printf '%s\n' "$DIFF" | awk '
    /^diff --git / { arq=$4; sub(/^b\//, "", arq); next }
    /^@@ / { s=$3; sub(/^\+/, "", s); split(s, p, ","); ln=p[1]+0; next }
    /^(---|\+\+\+) / { next }
    /^\+/ { printf "%s\t%d\t%s\n", arq, ln, substr($0,2); ln++ }')
fi

echo "check-regression: $erros erro(s), $avisos aviso(s) em $RANGE ($NCOMMITS commit(s))"
if [ "$erros" -gt 0 ]; then exit 1; fi
echo "ok"
