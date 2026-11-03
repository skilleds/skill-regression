# Caracterização (golden master) e approval/snapshot

> Parte da `schematize-regression`. Refatorar sem teste é apostar; caracterizar primeiro transforma a
> aposta em medição.

## 1. Quando

Código legado sem teste que vai ser **refatorado, migrado ou estendido** (`schematize-engineering ->
references/refactor.md`). Antes de mudar uma linha de estrutura, fixe o comportamento **atual**. O teste
de caracterização não diz que o comportamento está certo; diz que **não mudou**.

## 2. Como

1. **Escolha as costuras**: o ponto de entrada estável (função pública, endpoint, CLI, job) por onde o
   legado se observa sem mexer nele.
2. **Gere entradas representativas**: tráfego real anonimizado, fixtures de produção sem dado pessoal,
   ou grade de valores de borda. Cubra os ramos que importam, não só o caminho feliz.
3. **Grave a saída atual** como golden (texto, JSON normalizado, arquivo). Normalize o que varia:
   relógio, UUID, ordem de mapa, caminho absoluto, ponto flutuante (tolerância declarada).
4. **Rode duas vezes seguidas sem mexer no código**: tem de dar o mesmo golden. Diferente é
   não-determinismo escondido; conserte a normalização antes de seguir.
5. **Refatore em passos pequenos** com o golden verde a cada passo. Golden vermelho = o passo mudou o
   comportamento: reverta o passo, não o golden.
6. **Bug achado no golden** (o legado erra): documente com o teste que o fixa **como está** e abra o
   bug; corrija depois, num commit separado, atualizando o golden com a razão. Misturar refatoração e
   correção destrói a leitura do diff.

Mutação como segunda opinião: estrague o código de propósito (inverta uma condição) e veja o golden
reclamar. Se nada reclama, a entrada não cobre aquele ramo.

## 3. Approval e snapshot tests

Snapshot é golden mantido por ferramenta (`.snap`, `.approved`, `__snapshots__/`, `testdata/*.golden`).
É útil e perigoso pelo mesmo motivo: atualizar é um comando só.

**MUST**
- **Revisão humana do diff do snapshot**, linha a linha, no PR. O diff do snapshot é código novo.
- Atualização sempre **ao lado do motivo**: o teste ou o código que justifica a mudança está no mesmo
  commit, ou o corpo cita `regression-snapshot: <motivo>`. O gate avisa (`snapshot-sem-teste`) quando
  só o snapshot muda.
- Snapshot **pequeno e legível** (componente, não página inteira; campo, não resposta inteira).
  Snapshot gigante ninguém revisa, então ele aprova qualquer coisa.
- Snapshot **determinístico**: nada de data, id aleatório ou ordem instável dentro dele.

**VETADO**
- `-u`/`--update-snapshots`/`approve all` para "deixar o CI verde" sem ler o diff.
- Snapshot que guarda erro como se fosse o esperado (stack trace, mensagem de falha, página de erro).
- Atualizar snapshot em PR de outro assunto (refatoração, dependência) sem explicação do porquê.

## 4. Visual

Snapshot de imagem é o caso especial e tem regras próprias em `references/visual.md`.
