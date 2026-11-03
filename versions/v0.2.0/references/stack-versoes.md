# Anexo volátil: ferramentas de regressão

> Fonte volátil: a skill é agnóstica de ferramenta; o que muda com o tempo mora aqui.
> **Verificado em: 2026-10-15**, por execução local do gate e leitura da documentação do git. Nada de
> versão de terceiro entra no corpo normativo.

| Fato | Valor | Fonte | Estado |
|---|---|---|---|
| `git bisect run`: códigos de saída | 0 bom, 1 a 127 exceto 125 ruim, 125 pular, 128 ou mais aborta | `git help bisect` (git instalado na máquina de desenvolvimento) | verificado |
| Merge-base e range `A..B` no gate | `git merge-base`, `git rev-list --no-merges` | execução do `check-regression.test.sh` | verificado |
| shellcheck | gate de shell do catálogo roda limpo sobre `check-regression.sh` | `tools/ci.sh` do catálogo | verificado |
| Ferramentas de snapshot visual e de benchmark por ecossistema | não comparadas nesta rodada | n/a | <!-- reverificar --> a skill é agnóstica de produto |
| Limiares de exemplo (10% p95, 5 KB bundle, 0,1% pixels) | política sugerida, ajustável por ADR do projeto | n/a | convenção da casa, não fato externo |
