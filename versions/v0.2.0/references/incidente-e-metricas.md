# Incidente sem teste não fecha, e as métricas de regressão

> Parte da `schematize-regression`. O incidente é a regressão que escapou; fechá-lo sem teste é
> deixar a porta aberta.

## 1. Incidente de produção só fecha com teste de regressão

Postmortem de SEV1/2 (e de qualquer bug de produção reaberto) tem uma ação de máquina obrigatória: o
**teste de regressão correspondente**, com link para o commit ou PR e para o teste, escrito
vermelho-primeiro (`references/bug-primeiro.md`). O formato do postmortem e a regra de ação com dono
e prazo são da `schematize-incident` (`schematize-incident -> references/postmortem.md`); aqui está o
critério de fechamento:

- [ ] existe teste que **falhava** antes do fix e passa depois, no nível certo da pirâmide;
- [ ] o teste cita o ID do incidente;
- [ ] incidente de **resiliência** (vizinho caiu, item perdido/duplicado, fila travada) vira um dos 7 testes do piso 28 e a dependência entra em `resilience.yml`;
- [ ] o commit culpado está no postmortem quando foi bisseccionado (`references/bisect.md`);
- [ ] a causa que a suíte não pegou está explicada (faltou caso? nível errado? teste pulado?);
- [ ] se a causa for classe de erro (não só instância), há gate/ADR conforme `schematize-incident ->
  references/recorrencia.md`.

Sem o primeiro item o incidente fica **aberto**, mesmo com a produção estável. Exceção só por
`regression-ok: fix-sem-teste <motivo>` no commit, com o motivo no postmortem.

## 2. Métricas

Poucas, calculadas por máquina (issue tracker + git), em série por versão:

| Métrica | Como se calcula | O que um valor ruim indica |
|---|---|---|
| **Taxa de reabertura de bug** | bugs reabertos (ou duplicados do mesmo sintoma) / bugs fechados no período | fix sem teste vermelho, teste que não morde, causa raiz não tratada |
| **Escapes por versão** | bugs de produção atribuídos à versão X / mudanças entregues em X | suíte não pega o que importa; pirâmide vazia em algum ponto |
| **Fix com teste** | commits `fix:` com teste / total de `fix:` (o gate dá o numerador) | contorno do piso 1 |
| **Skips vencidos** | marcadores `regression-skip` com prazo passado | quarentena virando lixeira |
| **Tempo até a causa** | do alerta ao commit culpado | falta de teste reprodutor, bisect caro |

Use para decidir onde investir em teste, não para punir pessoas (blameless, como no postmortem). Meta
por métrica e dono vão no ADR da equipe; número solto em dashboard sem dono é decoração.

## 3. Ritual

Mensal ou por release: revise reabertura e escapes, abra ação para os dois maiores (qual módulo, qual
nível da pirâmide falhou), e confira se os skips vencidos foram consertados ou apagados com ADR.
