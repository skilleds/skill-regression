# Regressão de contrato, de dados e de prompt

> Parte da `schematize-regression`. Três tipos de regressão têm dona própria. Esta skill não duplica o
> gate delas; ela diz quando acionar e como encaixar no ciclo "nunca volta".

| Tipo | O que quebra | Dona e gate | Como entra no ciclo |
|---|---|---|---|
| **Contrato de API** | campo removido, tipo mudado, enum que cresceu, status novo, webhook com payload diferente | `schematize-api` (`schematize-api -> references/versionamento-deprecacao.md`): diff de compatibilidade OpenAPI/proto no CI | bug de contrato vira caso no teste de contrato (consumidor-dirigido); mudança incompatível é breaking change com plano de deprecação |
| **Resiliência do microserviço** | serviço caiu porque o vizinho caiu; item perdido ou duplicado na reentrega; fila travada por mensagem envenenada | piso 28 (`schematize-qa -> references/categorias.md`, `scripts/check-resilience.sh`) | incidente de resiliência vira um dos 7 testes do piso 28 + dependência em `resilience.yml`; incidente sem esse teste não fecha |
| **Dados** | schema do dataset muda, qualidade cai, backfill duplica, métrica muda de definição | `schematize-data` (`schematize-data -> references/contratos.md`, `references/qualidade.md`) | dado ruim corrigido vira expectativa de qualidade permanente no pipeline |
| **Prompt / LLM** | troca de prompt ou de modelo piora respostas, guardrail deixa de pegar | `schematize-ai` (`schematize-ai -> references/evals.md`): dataset dourado e juiz calibrado que travam a piora | resposta ruim reportada vira caso no dataset dourado |

## Regra comum

O padrão é o mesmo do bug de código: **a falha observada vira um caso permanente no teste da dona**,
visto falhar antes do conserto (`references/bug-primeiro.md`). Muda o gate, não a disciplina.

## O que cabe aqui

- Decidir **onde** o teste de regressão mora (no contrato, no pipeline, no eval) em vez de forçar tudo
  para teste unitário de código.
- Cobrar no incidente que a ação "teste de regressão" aponta para o lugar certo
  (`references/incidente-e-metricas.md`).
- Migração de banco que quebrou comportamento: o teste fica na camada de integração
  (`schematize-database` cobre expand-contract), com dados de antes e depois da migração.

## O que não cabe aqui

Como escrever o diff de OpenAPI, as regras de qualidade de dado ou a rubrica do juiz de LLM: é da
dona. Esta skill só garante que o caso exista, seja permanente e nasça vermelho.
