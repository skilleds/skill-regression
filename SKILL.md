---
name: schematize-regression
metadata:
  version: 0.1.1
description: >-
  Regressão: bug corrigido nunca volta. Teste vermelho antes do fix, golden master, perf e visual com baseline, git bisect. Use ao corrigir bug ou refatorar legado. Pirâmide: schematize-qa.
---
<!-- cross-skill: testes.md, efeitos-externos.md, orquestracao.md -> schematize-engineering -->

# Regressão: o que funcionava continua funcionando (schematize-regression)

Tese: **bug corrigido nunca volta; mudança não quebra o que funcionava, e isso é provado por máquina,
não por memória.** Regressão é o defeito mais caro porque já foi pago uma vez: o usuário viu, o time
corrigiu, e voltou. Volta quase sempre pelos mesmos três caminhos: o fix não deixou teste, o teste que
o guardava foi apagado ou pulado, ou o "snapshot atualizado" aceitou o comportamento quebrado. Esta
skill é a dona desse ciclo "nunca volta" e das provas que o sustentam: teste vermelho primeiro, teste
permanente, caracterização de legado, seleção da suíte, desempenho, visual e caça ao commit culpado.

**Versão:** skill `schematize-regression` v0.1.1. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:dominio intro="Esta skill é **transversal** (não é linguagem): o ciclo de regressão sobre os testes que a base exige (`schematize-engineering` → `references/testes.md`). **Onde divergir da base em piso, a base manda**; aqui mora o *como*, o rito e o gate." cmd="reg" -->Esta skill é **transversal** (não é linguagem): o ciclo de regressão sobre os testes que a base exige (`schematize-engineering` → `references/testes.md`). **Onde divergir da base em piso, a base manda**; aqui mora o *como*, o rito e o gate.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização do domínio ou da
   ferramenta — o como, o padrão, o gate. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Esta skill herda os pisos da base e
   os comandos dela cobrem o **domínio**, não o piso geral. Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/reg-*` cobrem o domínio desta skill; o piso geral é o da base.<!-- /herdado -->

## Fronteira com as outras skills

| Assunto | Dono | Ponteiro |
|---|---|---|
| **O ciclo "nunca volta"**: bug -> teste vermelho, teste permanente, caracterização, seleção da suíte, perf, visual, bisect, métricas | **esta skill** | `references/*.md` abaixo |
| Estratégia geral de teste: pirâmide, categorias, smoke, a11y, cobertura, flaky (detecção e causas) | `schematize-qa` | `schematize-qa -> references/estrategia.md`, `references/flaky.md` |
| Regressão de contrato: breaking change em OpenAPI/proto, deprecação com data | `schematize-api` | `schematize-api -> references/versionamento-deprecacao.md` |
| Regressão de dados: contrato de dataset, qualidade, backfill | `schematize-data` | `schematize-data -> references/contratos.md`, `references/qualidade.md` |
| Regressão de prompt/LLM: dataset dourado, juiz calibrado, evals que travam a piora | `schematize-ai` | `schematize-ai -> references/evals.md` |
| Postmortem, timeline, commit culpado registrado, ação com dono e prazo | `schematize-incident` | `schematize-incident -> references/postmortem.md` |
| Mensagem de commit (Conventional Commits), PR pequeno, hook | `schematize-git` | `schematize-git -> references/fluxo.md` |
| Pirâmide, TDD e testes na base normativa | `schematize-engineering` | `schematize-engineering -> references/testes.md` |
| Medir em produção (SLO, burn-rate, profiling contínuo) | `schematize-observability` | `schematize-observability -> references/slo-alertas.md` |
| Efeito externo em teste (e-mail, cobrança, webhook reais) | base | `schematize-engineering -> references/efeitos-externos.md` |

Divisa em uma linha: `schematize-qa` decide **o que e como testar**; `schematize-regression` garante
que **o que já foi provado continua provado**.

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/reg-help` | lista os comandos |
| `/reg-load` | carrega à força o corpo normativo (bug primeiro, permanência, caracterização, suíte, desempenho, visual, bisect, métricas) |
| `/reg-bug` | transforma um bug em teste vermelho reprodutor, visto falhar, antes de qualquer fix |
| `/reg-bisect` | acha o commit culpado com `git bisect run` e o teste reprodutor |
| `/reg-suite` | planeja ou audita a suíte: completa vs impacto, pré-hml, quarentena |
| `/reg-perf` | baseline versionado e limiar de benchmark que trava o CI |
| `/reg-visual` | baseline visual por componente/rota, threshold e revisão do diff |
| `/reg-review` | revisa um PR/diff contra o piso e roda `scripts/check-regression.sh` |
| `/reg-claude` | cria/mescla o `CLAUDE.md` sempre-on de regressão |
| `/reg-cc` · `/reg-handoff` | context compact / handoff arquivado |

## Como usar

1. **Rode o gate antes de opinar:** `bash scripts/check-regression.sh [dir] [--range A..B]` (padrão
   último marco `hml-*`/`v*`; sem tag, `origin/main..HEAD` se houver commits, senão os últimos 20 — push imediato não esvazia o range). Ligue ao `tools/ci.sh`/pre-commit: é o gate local por commit. `0` passa · `1` reprova · `2` nada para verificar (não é aprovação).
2. **Veio um bug?** `/reg-bug`: teste vermelho primeiro (`references/bug-primeiro.md`), fix depois.
3. **Teste sendo apagado, pulado ou "atualizado"?** `references/permanencia.md` e
   `references/caracterizacao.md` dizem o que exige ADR, dono e prazo.
4. **Pipeline lento e alguém quer pular a suíte?** `references/suite.md`.
5. **Ficou lento ou mudou de aparência?** `references/desempenho.md` e `references/visual.md`.
6. **Não sabe quando quebrou?** `references/bisect.md`.
7. **Fechando incidente ou medindo qualidade?** `references/incidente-e-metricas.md`.

| Tarefa | Reference |
|---|---|
| Bug -> teste vermelho -> fix; nível da pirâmide; ID do bug; critério de "visto falhar" | `references/bug-primeiro.md` |
| Teste permanente; skip e quarentena com dono e prazo; flaky não é regressão; marcadores do gate | `references/permanencia.md` |
| Golden master antes de refatorar legado; approval/snapshot com revisão humana | `references/caracterizacao.md` |
| Suíte completa vs seleção por impacto; local, pré-hml, release; nunca pular a regressão | `references/suite.md` |
| Benchmark com baseline versionado, limiar, ambiente estável e comparação estatística | `references/desempenho.md` |
| Baseline visual, threshold, estabilização (fonte, animação, dado), revisão do diff | `references/visual.md` |
| Regressão de contrato, dados e prompt: quem é o dono e qual gate trava | `references/contrato-dados-ia.md` |
| `git bisect run`, teste reprodutor, commit culpado no postmortem | `references/bisect.md` |
| Incidente sem teste não fecha; taxa de reabertura; escapes por versão | `references/incidente-e-metricas.md` |
| Versões de ferramenta e fatos voláteis, com data e fonte (anexo volátil) | `references/stack-versoes.md` |

Gate: `scripts/check-regression.sh` (teste: `scripts/check-regression.test.sh`). O que ele reprova:
commit `fix:` sem teste, teste removido, skip/only/ignore sem marcador, marcador sem dono e prazo; e
avisa de snapshot sem teste, fix sem ID e skip vencido.

## Pisos inegociáveis (vetam o atalho)

1. **Bug -> teste primeiro.** Todo fix nasce de um teste que reproduz o bug e é **visto falhar**
   (vermelho) antes do fix, no nível mais baixo da pirâmide que o reproduz, citando o ID do bug ou
   incidente. Fix sem teste só com `regression-ok` e motivo.
2. **Teste de regressão é permanente.** Nunca deletado nem pulado sem ADR; skip e quarentena têm
   dono e prazo no marcador `regression-skip`; prazo vencido é dívida visível, não silêncio.
3. **Flaky não é regressão, e regressão não é flaky.** Flaky é bug do teste: quarentena com dono e
   prazo. Nunca rotule falha determinística como "flaky" para liberar o merge.
4. **Caracterização antes de refatorar legado sem teste.** Golden master que fixa o comportamento
   atual (inclusive os defeitos) primeiro; refatora depois, com o golden verde o tempo todo.
5. **Snapshot nunca às cegas.** Approval/snapshot test exige revisão humana do diff do snapshot; atualizar
   em massa para "deixar o CI verde" é proibido e o gate avisa.
6. **Suíte completa pré-hml (tag) e sob demanda; por commit, local (piso 27).** Seleção por impacto só se a completa roda pré-hml; nunca se pula a suíte de regressão para "agilizar".
7. **Desempenho tem baseline versionado e limiar que trava o CI**, em ambiente estável e com
   comparação estatística (várias amostras), nunca uma medição só.
8. **Regressão visual tem baseline por componente/rota**, threshold, fonte/animação/dado
   estabilizados e revisão humana do diff.
9. **Regressão de contrato, dados e prompt tem dona e gate próprios** (`schematize-api`,
   `schematize-data`, `schematize-ai`); esta skill aponta, não duplica.
10. **Regressão se caça com `git bisect run`** e o teste reprodutor; o commit culpado vai para o
    postmortem (`schematize-incident`).
11. **Incidente de produção sem teste de regressão correspondente não fecha.**
12. **Medir:** taxa de reabertura de bug e escapes por versão são acompanhadas; subir é sinal de
    que o piso 1 ou o 2 está sendo contornado.
13. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

## Regra de mídia

Regressão visual compara pixels, não gera arte. Baseline é captura do produto real, nunca imagem
sintetizada. Mídia nova (ícone, ilustração) nunca sai de modelo Claude: detecte Codex e Gemini
disponíveis e **pergunte ao usuário qual usar**. Nenhum disponível: avise sem rodeio que visual gerado
pelo Claude tem qualidade inversamente proporcional à de código (sai ruim de verdade) e ofereça
alternativas: instalar Codex ou Gemini, imagem de banco com licença comercial, ou asset do cliente.

## Relação com as outras skills

- **`schematize-qa`** — a estratégia e a pirâmide em que os testes de regressão vivem; flaky e visual (lista).
- **`schematize-incident`** — onde o commit culpado e a ação "teste de regressão" são registrados.
- **`schematize-api`**, **`schematize-data`**, **`schematize-ai`** — as donas da regressão de contrato, de dados e de prompt.
- **`schematize-git`** — Conventional Commits (o gate lê `fix:`) e PR pequeno (o que torna o bisect barato).
- **`schematize-engineering`** — a base: testes, DoD, efeito externo e orquestração.

<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->
