# Permanência do teste de regressão, skip e flaky

> Parte da `schematize-regression`. Teste de regressão é a memória executável do time: apagá-lo é
> esquecer de propósito.

## 1. Permanente

Teste que guarda um bug corrigido **não é apagado, pulado nem enfraquecido** (asserção relaxada,
tolerância ampliada, mock que dribla o caminho) para destravar um merge. Mudou o requisito? Então o
teste muda **com o requisito**, no mesmo PR, com a decisão registrada. Remover ou pular exige **ADR**
(`schematize-docs -> references/adr.md`) que diga: o que o teste cobria, por que não cobre mais, e o
que cobre no lugar.

Remoção legítima existe: a funcionalidade morreu, o teste foi movido (renomear/mover mantém a
contagem de casos), a cobertura passou para nível melhor. Em todos, o marcador abaixo no commit.

## 2. Marcadores que o gate entende

| Marcador | Onde | Autoriza |
|---|---|---|
| `regression-skip: <motivo> <@dono> <AAAA-MM-DD>` | na linha do skip, ou na mensagem de commit **com o arquivo no fim da linha** (vale só para ele) | skip, quarentena ou remoção de teste |
| `regression-ok: fix-sem-teste <motivo>` | corpo do commit `fix:` | fix sem teste automatizável possível |
| `regression-snapshot: <motivo>` | corpo do commit | snapshot/golden alterado sem teste ao lado |

Regras: o `<motivo>` cita o ADR ou o issue; o `<@dono>` é uma pessoa ou time com `@`; o prazo é uma
data ISO. Marcador **incompleto reprova** (`marcador-invalido`): é pior que ausente, porque finge
governança. Prazo vencido vira `skip-vencido`: o gate avisa em todo PR até alguém consertar ou renovar
com justificativa nova.

O que conta como skip: `it.skip`/`describe.only`, `xit`/`xdescribe`, `@Ignore`/`@Disabled`,
`t.Skip`, `#[ignore]`, `pytest.mark.skip`/`xfail`, `skip "..."` (RSpec). `only` entra porque desliga
todos os outros. Ferramenta nova? Acrescente o padrão em `SKIP_RE` do gate e um caso no teste.

## 3. Quarentena

Quarentena é um estado **temporário e visível**, não uma lixeira:

- o teste continua rodando, em job separado que não bloqueia, e relatando;
- tem issue, dono e prazo (o marcador acima);
- sai da quarentena consertado ou apagado com ADR; nunca fica "para sempre".

Detecção, causas e determinismo de teste flaky são da `schematize-qa`
(`schematize-qa -> references/flaky.md`). Aqui vale só a fronteira.

## 4. Flaky não é regressão (e o inverso)

- **Flaky:** o mesmo código passa e falha. É bug do teste (ou corrida real no código). Quarentena com
  dono e prazo, e conserto da causa.
- **Regressão:** o mesmo teste, antes verde, agora falha **de modo determinístico** depois de uma
  mudança. É a suíte funcionando.

O erro caro é chamar regressão de flaky: "re-roda que passa" num teste que falha 30% das vezes **depois
de um commit específico** é regressão intermitente (corrida introduzida, ordem de execução, dado
compartilhado). Antes de quarentenar, prove que é flaky: rode o teste N vezes **no commit anterior**; se
passa 100% lá e falha aqui, é regressão e vai para `references/bisect.md`, não para a quarentena.

## 5. Reaparição

Bug que voltou com o teste já existindo: o teste estava errado (não mordia), foi pulado, ou o nível
era alto demais. Conserte o teste primeiro (vermelho visto de novo), depois o código, e conte na
métrica de reabertura (`references/incidente-e-metricas.md`).
