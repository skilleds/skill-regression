# Regressão de desempenho

> Parte da `schematize-regression`. Lentidão que entra devagar não aparece em nenhum PR; aparece no
> mês em que o p95 dobrou. Benchmark com baseline é o teste de regressão do desempenho.

## 1. O que medir

Escolha poucas métricas que o usuário ou a conta sentem, não todas:

- **Latência** de operações críticas: p50, p95, p99 (não média).
- **Vazão** sob carga fixa.
- **Alocação e memória** por operação (bytes/op, pico de RSS).
- **Tamanho de bundle** e tempo de build/cold start, no front e em binários.
- **Contagem de queries** por requisição (previne o N+1 voltar).

Medição em produção (SLO, profiling contínuo) é da `schematize-observability`; aqui é a medição
**antes do merge**, repetível.

## 2. Baseline versionado

O baseline é um **arquivo no repositório** (`bench/baseline.json` ou equivalente) com métrica,
valor, unidade, ambiente de captura e commit. Muda por commit explícito e revisado, nunca
automaticamente a cada execução. Baseline que se atualiza sozinho aceita a regressão.

## 3. Limiar que trava

Defina por métrica um limiar de regressão, por exemplo "p95 não sobe mais de 10%", "alocação por
operação não sobe", "bundle não cresce mais de 5 KB comprimido". Estourou: o CI **falha**. Justificou
(a feature custa isso)? Novo baseline no mesmo PR, com o motivo no commit e aprovação do dono.

## 4. Ambiente estável

Ruído grande derruba a confiança e leva a "relaxar o limiar", que mata o gate. Controle:

- mesma máquina/runner dedicado para o benchmark, sem vizinho barulhento; mesma imagem e versão de
  toolchain;
- aquecimento (warm-up) descartado; cache e JIT estabilizados;
- sem rede e sem serviço externo real (fake local); dados de entrada fixos e com semente;
- frequência de CPU e carga de fundo conhecidas.

Benchmark que não repete no mesmo commit não serve de gate; conserte o ambiente antes.

## 5. Comparação estatística

Uma amostra não prova nada. **N execuções** (mínimo 10 a 30, conforme o ruído), compare **distribuições**:
mediana e intervalo de confiança, ou teste não paramétrico (Mann-Whitney) entre base e candidato. Reprove
quando a diferença é **estatisticamente significativa e acima do limiar**; ruído abaixo do limiar passa.
Reporte a diferença com o intervalo, não só "mais lento". Ferramenta: a do ecossistema (benchstat,
criterion, hyperfine, k6, lighthouse-ci); o princípio independe dela.

## 6. Onde roda

Local por commit: microbenchmarks rápidos dos caminhos tocados e bundle size. Pré-hml/sob demanda: o conjunto completo, com
histórico em série temporal (a deriva lenta só aparece no gráfico). Regressão achada no conjunto completo vira
bug com bisect (`references/bisect.md`) e teste de benchmark que a pega.

## 7. Efeito externo

Benchmark e carga nunca atingem produção nem dependências de terceiros reais.
