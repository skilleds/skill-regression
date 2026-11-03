# Seleção e frequência da suíte de regressão

> Parte da `schematize-regression`. A suíte de regressão só protege se rodar; quando fica lenta, a
> tentação é pular. Aqui está o que se pode otimizar e o que nunca.

## 1. Quando roda o quê

| Gatilho | O que roda | Pode ser reduzido? |
|---|---|---|
| Local, por commit (`tools/ci.sh` / pre-commit) | unitários rápidos, o teste do bug em curso e `scripts/check-regression.sh` | sim (é conveniência) |
| Local, antes do push de uma entrega | seleção por impacto **ou** completa | só com a completa pré-hml (item 3) |
| Pré-hml (tag `hml-*`, uma vez, sobre o acumulado) | **suíte completa** | **não** |
| Sob demanda (`workflow_dispatch`) | completa + lenta (carga, perf, visual completo, e2e longo, mutação por amostragem) | não |
| Antes do release (tag `v*`) | completa verde no commit exato do release | não |

Piso 27: não há "check obrigatório no PR" nem cron noturno por padrão. O gate por commit é **local**;
o CI remoto roda só no dispatch e nas tags de promoção. `schedule` só com `justificativa:` escrita.

## 2. Suíte completa é o piso da promoção

Nenhuma promoção ao hml/release sem a suíte completa verde naquele commit exato. O gate local por
commit pode ser mais rápido que o pré-hml; **o pré-hml não pode ser mais fraco que ele**.

## 3. Seleção por impacto (test impact analysis)

Rodar só os testes afetados pelo diff acelera o ciclo local. Aceite com condições:

- **Mapa arquivo -> teste** derivado do grafo de dependências (build tool) ou da cobertura por teste,
  regenerado a cada pré-hml; mapa velho é falso verde.
- **Falha segura:** arquivo sem entrada no mapa, mudança em configuração, build, dependência,
  `Dockerfile`, esquema do banco ou código gerado => **suíte completa**.
- **A completa roda pré-hml.** Sem isso, seleção por impacto é só pular teste com outro nome.
- Reporte o que foi **selecionado e o que foi pulado** no resumo da entrega, para ninguém achar que a
  suíte inteira passou.

## 4. Nunca pular

**VETADO**
- Pular, desligar ou rebaixar a suíte de regressão "para agilizar" um merge, um release ou um hotfix.
  Hotfix é onde a regressão mais ataca; ele roda a regressão completa (local, pelo `ci.sh`, e pré-hml).
- Marcar o job como `allow-failure` ou "não bloqueante" para destravar. Job que não bloqueia não é gate.
- Retry automático até passar (esconde corrida real; ver `schematize-qa -> references/flaky.md`).
- Suíte lenta resolvida por **apagar teste**. Resolva por paralelismo, fixtures mais baratas, nível mais
  baixo da pirâmide, cache de dependências, sharding.

## 5. Quando a suíte fica lenta

Meça por teste e ataque o topo (curva de Pareto): os 5% mais lentos costumam valer 50% do tempo. Em
ordem: paralelizar e fatiar (shard) -> trocar e2e por teste de nível mais baixo -> fixtures
compartilhadas imutáveis -> banco em memória só onde fiel (preferir o real em contêiner) -> seleção por
impacto no PR. Orçamento de referência: PR em minutos, merge em dezenas de minutos, nightly sem teto
mas com dono.

## 6. Auditoria de saúde da suíte (`/reg-suite`)

Perguntas que a auditoria responde com número, não com impressão: duração p50/p95 do PR e do merge;
testes em quarentena, há quanto tempo e de quem; skips vencidos (`grep regression-skip`); taxa de
flaky por teste; mapa de impacto datado; rotas/módulos críticos sem nenhum teste de regressão.
