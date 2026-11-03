# Bug primeiro: teste vermelho, depois fix

> Parte da `schematize-regression`. O fix mais barato é o que já nasce com a prova de que o bug existiu.

## 1. A regra

Todo bug corrigido passa por três passos, nesta ordem, e o gate lê a ordem no histórico:

1. **Reproduza com um teste** que falha pelo motivo do bug (não por erro de compilação, fixture
   quebrada ou import faltando).
2. **Veja o teste falhar** (vermelho) e guarde a saída: a mensagem do vermelho é a evidência de que
   o teste testa o bug. Teste que nunca foi visto falhar pode estar passando por qualquer motivo.
3. **Corrija** e veja o mesmo teste ficar verde, com o resto da suíte verde.

Por quê: sem o vermelho visto, o teste pode ser decorativo (asserção que passa com ou sem o fix), e
o bug volta numa refatoração sem que nada reclame. O vermelho é a prova de que o teste "morde".

## 2. Nível mais baixo da pirâmide que reproduz

Escolha o teste **mais barato e mais próximo da causa** que ainda reproduz o defeito:

| Se a causa está em | Teste no nível |
|---|---|
| uma função pura, um cálculo, um parser | unitário |
| a fronteira entre dois módulos, SQL, serialização | integração |
| um contrato entre serviços | contrato (`schematize-api`) |
| só aparece com navegador, rede ou estado de UI | e2e/componente, mínimo possível |

E2E só quando nenhum nível abaixo reproduz. Teste alto demais é lento, flaky e some na primeira
"limpeza" de suíte. Se a causa é uma classe de entrada (nulo, fuso, unicode, valor-limite), escreva o
caso concreto que quebrou **e** o teste de propriedade ou a tabela de casos da classe, para o próximo
irmão do bug não passar.

## 3. Referência ao bug

O teste carrega o **ID do bug ou incidente** no nome ou em comentário curto (`BUG-123`, `#456`,
`INC-2026-014`), e o commit `fix:` cita o mesmo ID. O ID liga código, teste, postmortem e métrica de
escape (`references/incidente-e-metricas.md`). O gate avisa de `fix` sem ID.

## 4. Como o gate lê isto

`scripts/check-regression.sh` reprova o commit `fix:`/`fix(escopo):` que não toca arquivo de teste.
Aceita três formas honestas:

- teste e fix **no mesmo commit** (o mais comum);
- commit `test:` que reproduz o bug **imediatamente antes** do `fix:` no range (mostra o vermelho no
  histórico; o CI do PR roda no último commit, então o vermelho intermediário não bloqueia o merge);
- teste inline adicionado no mesmo arquivo de código (módulo `#[cfg(test)]`, `test "..."` do Zig).

O que o gate **não** consegue ver: se o teste foi visto falhar. Isso é do `/reg-bug` e da revisão.

## 5. Quando não há teste automatizável possível

Raro e declarado: correção de texto de documentação, de configuração só de produção, de arquivo de
infra sem harness. No corpo do commit: `regression-ok: fix-sem-teste <motivo>`. Sem motivo não vale.
"É difícil testar" não é motivo; é sinal de que falta uma costura (injeção de relógio, de rede, de
armazenamento) e abrir essa costura é parte do fix.

## 6. Bug que não reproduz

Não reproduz em teste: ainda não é fix, é hipótese. Registre o que se tentou, instrumente (log
estruturado, trace) e solte o fix só com o ID de rastreio de que o sintoma sumiu. Fix "às cegas" sem
teste nem medição é o gerador principal de reabertura de bug.

## 7. Efeito externo

O teste reprodutor nunca dispara efeito real (e-mail, cobrança, webhook): sink local ou fake. Regra da
base em `schematize-engineering -> references/efeitos-externos.md`.
