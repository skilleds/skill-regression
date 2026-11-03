# Regressão visual

> Parte da `schematize-regression`. A `schematize-qa` lista regressão visual entre as categorias de
> teste; aqui está como se faz de modo que o time não aprenda a ignorar o vermelho.

## 1. Baseline

Uma imagem de referência **por componente e por rota**, versionada junto do código (git ou LFS),
capturada do produto real em ambiente fixo. Componente isolado (Storybook, harness) pega a regressão
perto da causa; rota completa pega a composição. Faça os dois, mas poucos estados bem escolhidos:
vazio, preenchido, erro, carregando, tema claro e escuro, mobile e desktop.

## 2. Threshold

Comparação por pixel com **tolerância declarada** (por exemplo, até 0,1% de pixels diferentes e
limiar de cor pequeno para anti-aliasing). Tolerância alta demais esconde regressão; zero, em geral, só
gera ruído de renderização. Ajuste o threshold **uma vez, com justificativa**, nunca por teste que
piscou (isso é esconder instabilidade, ver `schematize-qa -> references/flaky.md`).

## 3. Estabilizar o que varia

A maior parte do "flaky visual" é variação que não é regressão:

- **Fontes:** webfonts carregadas e esperadas antes da captura; mesma família no runner (imagem de
  contêiner fixa), nunca as fontes da máquina do dev.
- **Animações e transições:** desligadas (`prefers-reduced-motion`, CSS de teste) ou capturadas num
  estado final; cursor piscando e carrosséis parados.
- **Dados:** fixture fixa; data, hora, avatar, contador e conteúdo aleatório mockados.
- **Rede e imagens:** sem requisição externa; imagem de teste local.
- **Renderizador:** mesmo navegador, versão e sistema operacional da captura. Baseline gerado na
  máquina do dev e comparado no CI dá diferença de pixel garantida.

## 4. Revisão do diff

Falha visual gera um relatório com **baseline, atual e diferença** lado a lado. A pessoa que revisa decide:
regressão (corrige o código) ou mudança intencional (atualiza o baseline, no mesmo PR, com o motivo).
**VETADO** aprovar tudo em massa; o mesmo princípio dos snapshots (`references/caracterizacao.md`).
Mudança de baseline sem mudança de código visual no PR é suspeita e o gate avisa
(`snapshot-sem-teste`).

## 5. Onde roda

Componentes: por commit, local, quando toca o componente (rápido). Rotas completas e matriz de navegadores e
viewports: pré-hml (tag `hml-*`) e sob demanda. Acessibilidade e contraste são de outro gate
(`schematize-qa -> references/categorias.md`); regressão visual não os substitui.

## 6. Regras de mídia

Baseline é captura do produto, nunca imagem gerada. Arte nova segue a regra de mídia da skill: Codex
ou Gemini, perguntando ao usuário qual usar, nunca o Claude.
