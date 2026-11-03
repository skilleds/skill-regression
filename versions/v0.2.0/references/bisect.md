# Caça à regressão com git bisect

> Parte da `schematize-regression`. Achar o commit que quebrou deve ser busca binária automática, não
> leitura de histórico. Repo com PR pequeno e commits atômicos faz o bisect custar minutos.

## 1. Pré-requisito: o teste reprodutor

Sem um teste que **falha de modo determinístico**, não há o que bisseccionar. Primeiro `/reg-bug`
(`references/bug-primeiro.md`): escreva o teste vermelho no commit atual. Se o sintoma é
intermitente, rode-o N vezes por commit (script abaixo) ou conserte o determinismo antes.

## 2. O script de decisão

O script devolve o código de saída que o bisect espera:

- `0` = commit **bom** (o teste passa);
- `1` a `124` e `126`/`127` (exceto o `125`) = commit **ruim**;
- `125` = **pular** o commit (não compila, dependência quebrada), que não decide nada.

```bash
#!/usr/bin/env bash
# bisect-test.sh: decide bom/ruim/pular para o commit em teste.
set -u
build_or_deps || exit 125          # não compila => pula
./run-teste-reprodutor.sh          # o MESMO teste que falha hoje
```

Cuidado: o teste reprodutor precisa existir **em cada commit testado**. Mantenha-o fora da árvore
versionada (cópia em `/tmp` ou `git stash`/`git checkout <commit-com-teste> -- caminho/do/teste`
dentro do script) ou o bisect só encontra "o commit onde o teste nasceu".

## 3. Rodar

```bash
git bisect start
git bisect bad  HEAD                 # onde o bug aparece
git bisect good v1.4.0               # último ponto conhecido bom (tag, release)
git bisect run  ./bisect-test.sh     # automático, termina em "<sha> is the first bad commit"
git bisect log > bisect.log          # evidência para o postmortem
git bisect reset                     # volta à branch original; nunca esqueça
```

Rode em **worktree separada** (`git worktree add ../bisect <sha>`) se houver trabalho não commitado.
Árvore suja pode estragar a bisecção e o `reset` pode perder trabalho.

## 4. Depois do culpado

1. Leia o commit e o PR: o fix correto raramente é "reverter", mas reverter é a mitigação segura
   quando o incidente está aberto (`schematize-incident -> references/mitigacao.md`).
2. **Registre** o SHA culpado, o PR e o `bisect.log` no postmortem
   (`schematize-incident -> references/postmortem.md`): o commit culpado é dado de aprendizado (por que
   a revisão e a suíte não pegaram?).
3. O teste reprodutor entra no repo como teste permanente (`references/permanencia.md`) no commit do
   fix, citando o ID.
4. Pergunte por que a suíte não pegou: faltou caso, nível errado, teste pulado? A resposta vira ação
   com dono e prazo.

## 5. Quando o bisect falha

- **Commits que não compilam**: `125` resolve; muitos `125` seguidos sugerem histórico não atômico.
- **Merge commits**: o bisect segue o primeiro pai por padrão; commits de merge enormes escondem o
  culpado dentro. PR pequeno e rebase/squash disciplinado (`schematize-git`) reduzem isso.
- **Regressão por dado ou ambiente**, não por código: o bisect de código dá "primeiro ruim" falso.
  Fixe dados e ambiente no script.
- **Intermitente**: rode o teste várias vezes por commit; declare "bom" só se passar todas.
