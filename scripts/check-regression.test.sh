#!/usr/bin/env bash
# Vermelho primeiro do gate check-regression.sh. Cada caso é um repo git TEMPORÁRIO isolado (mktemp);
# nunca toca o repo real. Cobre verde (passa) e vermelho (reprova) de cada regra.
#
# EXCEÇÃO DECLARADA (piso da schematize-shell, strict mode): harness roda `set -u` sem `-e`,
# para continuar após um caso vermelho e reportar todos.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-regression.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null HOME="$TMP/home"
mkdir -p "$HOME"
ok=0; fail=0; D=""; NOME=""
FUTURO="2099-12-31"

novo() { # novo <nome>: repo com commit-base (código + teste existentes)
  NOME="$1"; D="$TMP/$1"; mkdir -p "$D"
  git -C "$D" init -q -b main
  git -C "$D" config user.name teste; git -C "$D" config user.email t@example.invalid
  git -C "$D" config commit.gpgsign false
  w src/app.go 'package app'
  w src/app_test.go 'func TestBase(t *testing.T) {}'
  c "chore: base"
}
w() { mkdir -p "$(dirname "$D/$1")"; printf '%s\n' "$2" >"$D/$1"; }   # w <arq> <conteudo>
a() { mkdir -p "$(dirname "$D/$1")"; printf '%s\n' "$2" >>"$D/$1"; }  # a <arq> <linha> (acrescenta)
c() { git -C "$D" add -A; git -C "$D" commit -q -m "$1" ${2:+-m "$2"}; }
R() { echo "$(git -C "$D" rev-list --max-parents=0 HEAD)..HEAD"; }
esperar() { # esperar <exit> <agulha|-> [args do gate...]   (padrão: --range do commit-base)
  local esp="$1" ag="$2" saida rc; shift 2
  if [ $# -eq 0 ]; then set -- --range "$(R)"; elif [ "$1" = "--default" ]; then set --; fi
  saida="$(bash "$G" "$D" "$@" 2>&1)"; rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $NOME: exit $rc, esperado $esp"; printf '      %s\n' "${saida//$'\n'/$'\n      '}"; fail=$((fail+1)); return; fi
  if [ "$ag" != "-" ] && ! grep -qF -- "$ag" <<<"$saida"; then echo "  ✖ $NOME: sem \"$ag\""; printf '      %s\n' "${saida//$'\n'/$'\n      '}"; fail=$((fail+1)); return; fi
  echo "  ✔ $NOME"; ok=$((ok+1))
}

echo "== fix sem teste (regra 1) =="
novo vermelho-fix-sem-teste;      w src/app.go 'package app // v2'; c "fix: corrige total (BUG-12)"; esperar 1 "fix-sem-teste"
novo vermelho-fix-escopo-breaking; w src/app.go 'x'; c "fix(api)!: muda retorno (#7)"; esperar 1 "fix-sem-teste"
novo vermelho-fix-so-docs;        w README.md 'x'; c "fix: typo (#3)"; esperar 1 "fix-sem-teste"
novo verde-fix-com-teste;         w src/app.go 'x'; a src/app_test.go 'func TestBug12(t *testing.T) {}'; c "fix: corrige total (BUG-12)"; esperar 0 "ok"
novo verde-fix-teste-no-anterior; a src/app_test.go 'func TestBug12(t *testing.T) {}'; c "test: reproduz BUG-12"; w src/app.go 'x'; c "fix: corrige total (BUG-12)"; esperar 0 "ok"
novo vermelho-fix-teste-nao-adjacente; a src/app_test.go 'func TestBug12(t *testing.T) {}'; c "test: reproduz BUG-12"; w a.txt 1; c "chore: x"; w src/app.go 'x'; c "fix: corrige (BUG-12)"; esperar 1 "fix-sem-teste"
novo verde-fix-teste-inline-rust; w src/lib.rs $'fn f() {}\n#[test]\nfn bug_12() {}'; c "fix: corrige (BUG-12)"; esperar 0 "ok"
novo verde-feat-sem-teste;        w src/app.go 'x'; c "feat: nova coisa"; esperar 0 "ok"
novo verde-fix-com-waiver;        w README.md 'x'; c "fix: typo na doc (#3)" "regression-ok: fix-sem-teste correção só de texto, sem comportamento"; esperar 0 "ok"
novo vermelho-waiver-sem-motivo;  w README.md 'x'; c "fix: typo (#3)" "regression-ok: fix-sem-teste"; esperar 1 "fix-sem-teste"
novo aviso-fix-sem-id;            w src/app.go 'x'; a src/app_test.go 'func TestX(t *testing.T) {}'; c "fix: corrige total"; esperar 0 "fix-sem-id"

echo "== teste removido (regra 2) =="
novo vermelho-arquivo-removido;   git -C "$D" rm -q src/app_test.go; c "refactor: limpa"; esperar 1 "teste-removido"
novo vermelho-caso-removido;      w src/app_test.go 'package app'; c "refactor: limpa"; esperar 1 "teste-removido"
novo verde-caso-renomeado;        w src/app_test.go 'func TestOutroNome(t *testing.T) {}'; c "refactor: renomeia teste"; esperar 0 "ok"
novo verde-removido-com-marcador; git -C "$D" rm -q src/app_test.go; c "refactor: remove" "regression-skip: ADR-0042 cobre o caso por contrato @maria $FUTURO src/app_test.go"; esperar 0 "ok"
novo vermelho-removido-marcador-sem-dono; git -C "$D" rm -q src/app_test.go; c "refactor: remove" "regression-skip: ADR-0042 $FUTURO"; esperar 1 "marcador-invalido"

echo "== skip/only adicionado (regra 2) =="
skip() { # skip <nome> <arquivo> <linha>: acrescenta a linha ao arquivo e espera reprovar
  novo "vermelho-skip-$1"; a "$2" "$3"; c "test: ajusta"; esperar 1 "skip-sem-marcador"
}
skip jest tests/a.test.js "  it.skip('x', () => {})"
skip jest-only tests/a.test.js "  describe.only('x', () => {})"
skip xit tests/a.test.js "  xit('x', () => {})"
skip go src/app_test.go '	t.Skip("depois")'
skip java src/AppTest.java '  @Ignore'
skip rust src/lib.rs '#[ignore]'
skip pytest tests/test_a.py '@pytest.mark.skip(reason="x")'
skip xfail tests/test_a.py '@pytest.mark.xfail'
skip rspec spec/a_spec.rb '  skip "depois"'
novo verde-skip-iterador;         w src/lib.rs 'let v = it.skip(3).take(2);'; c "feat: usa iterador"; esperar 0 "ok"
novo verde-skip-marcador-linha;   a tests/a.test.js "  it.skip('x', () => {}) // regression-skip: flaky no CI @joao $FUTURO"; c "test: quarentena"; esperar 0 "ok"
novo verde-skip-marcador-commit;  a src/app_test.go '	t.Skip("depois")'; c "test: quarentena" "regression-skip: dependência externa fora do ar @joao $FUTURO src/app_test.go"; esperar 0 "ok"
novo vermelho-marcador-sem-prazo; a src/app_test.go '	t.Skip("depois")'; c "test: quarentena" "regression-skip: flaky @joao"; esperar 1 "marcador-invalido"
novo aviso-skip-vencido;          a src/app_test.go '	t.Skip("depois")'; c "test: quarentena" "regression-skip: flaky @joao 2020-01-01 src/app_test.go"; esperar 0 "skip-vencido"

echo "== snapshot (regra 3) =="
novo aviso-snapshot-sem-teste;    w tests/__snapshots__/home.snap 'novo'; c "chore: atualiza snapshot"; esperar 0 "snapshot-sem-teste"
novo verde-snapshot-com-teste;    w tests/__snapshots__/home.snap 'novo'; a src/app_test.go 'func TestHome(t *testing.T) {}'; c "test: home"; esperar 0 "ok"
novo verde-snapshot-explicado;    w tests/__snapshots__/home.snap 'novo'; c "chore: atualiza snapshot" "regression-snapshot: diff do snapshot revisado por @maria no PR 31"; esperar 0 "ok"
novo aviso-snapshot-nao-reprova;  w tests/home.golden 'novo'; c "chore: golden"; esperar 0 "snapshot-sem-teste"

echo "== uso e entrada (rc 2 não é aprovação) =="
novo erro-range-vazio;            esperar 2 "nada para verificar" --range "HEAD..HEAD"
NOME="erro-nao-e-repo"; D="$TMP/vazio"; mkdir -p "$D"; esperar 2 "não é um repositório" --range "a..b"
novo erro-sem-origem;             esperar 2 "nenhum commit" --default
# marcador de mensagem vale só para o arquivo nomeado (furo: um marcador liberava o range inteiro)
novo vermelho-um-marcador-dois-skips; a src/app_test.go '	t.Skip("a")'; a src/outro_test.go '	t.Skip("b")'; c "test: quarentena" "regression-skip: flaky @joao $FUTURO src/app_test.go"; esperar 1 "src/outro_test.go"
novo vermelho-marcador-sem-arquivo; a src/app_test.go '	t.Skip("a")'; c "test: quarentena" "regression-skip: flaky @joao $FUTURO"; esperar 1 "marcador-sem-arquivo"
# push imediato (piso 22): origin/main == HEAD deixava o range vazio; o padrão passa a ser o último marco
novo vermelho-default-apos-push-com-tag; git -C "$D" tag hml-1; w src/app.go 'x'; c "fix: corrige (BUG-9)"; git -C "$D" update-ref refs/remotes/origin/main HEAD; esperar 1 "fix-sem-teste" --default
novo verde-default-apos-push-com-tag; git -C "$D" tag hml-1; w src/app.go 'x'; a src/app_test.go 'func TestBug9(t *testing.T) {}'; c "fix: corrige (BUG-9)"; git -C "$D" update-ref refs/remotes/origin/main HEAD; esperar 0 "ok" --default
novo vermelho-default-apos-push-sem-tag; w src/app.go 'x'; c "fix: corrige (BUG-9)"; git -C "$D" update-ref refs/remotes/origin/main HEAD; esperar 1 "fix-sem-teste" --default
novo vermelho-default-head-taggeado; w src/app.go 'x'; c "fix: corrige (BUG-9)"; git -C "$D" tag v1.0.0; git -C "$D" update-ref refs/remotes/origin/main HEAD; esperar 1 "fix-sem-teste" --default
novo verde-default-origin-main;   git -C "$D" update-ref refs/remotes/origin/main HEAD; w src/app.go 'x'; a src/app_test.go 'func TestY(t *testing.T) {}'; c "fix: y (#1)"; esperar 0 "ok" --default
novo vermelho-default-origin-main; git -C "$D" update-ref refs/remotes/origin/main HEAD; w src/app.go 'x'; c "fix: y (#1)"; esperar 1 "fix-sem-teste" --default

echo
echo "check-regression.test: $ok ok, $fail falha(s)"
[ "$fail" -eq 0 ]
