---
name: manas-ciel
description: >
  Use quando o usuario pedir para criar, planejar, desenvolver ou entregar um
  projeto WEB ou nova feature usando o pipeline Manas-Ciel. Versao melhorada
  do Jarvis-WEB-TEAM com knowledge graphs (Graphify + GitNexus).
  O usuario geralmente ativa com frases como "com Manas-Ciel", "usando Manas-Ciel",
  "quero o Manas-Ciel", ou "chama o Manas-Ciel".
---

# Manas-Ciel: Pipeline Spec-Driven com Knowledge Graphs

Manas-Ciel e a evolucao do Jarvis-WEB-TEAM. Mantem o mesmo fluxo de 2 interacoes
(/opsx-propose + chamar a skill) mas adiciona uma camada invisivel de
knowledge graphs (Graphify + GitNexus) que eliminam a re-exploracao de codigo.

## Filosofia

Manas-Ciel **nao cria especificacao**. Ela **consome e executa** especificacoes
existentes (proposal.md, design.md, tasks.md) vindas do OpenSpec ou de documentos
manuais.

A diferenca para o Jarvis: cada subagente tem acesso a um mapa completo do
codebase (Graphify para semantica + GitNexus para estrutura), eliminando
grep/glob exploratorio e reduzindo consumo de tokens em 50-70%.

## Quando usar

Ative esta skill quando o usuario pedir para criar, planejar, desenvolver ou
entregar um projeto WEB citando Manas-Ciel. Exemplos:
- "quero criar um site com Manas-Ciel"
- "chama o Manas-Ciel para implementar a feature X"
- "usando Manas-Ciel, desenvolva o projeto"

Se o usuario nao citar Manas-Ciel explicitamente, use o Jarvis original.

## Subagentes disponiveis

| Subagente | Arquivo | Responsabilidade |
|---|---|---|---|
| Graph Indexer | `manas-ciel-graph-indexer` | Manter indices Graphify + GitNexus atualizados |
| Graph Navigator | `manas-ciel-graph-navigator` | Consultar grafos (decide qual ferramenta usar) |
| Execution Manager | `manas-ciel-execution-manager` | Orquestrar pipeline com dados do grafo |
| Arquiteto | `manas-ciel-architect` | Arquitetura + Peer Review com impact analysis |
| Dev Frontend | `manas-ciel-dev-frontend` | Implementar tasks de frontend com navegacao por grafo |
| **Dev Backend** | `manas-ciel-dev-backend` | **Coordenador backend**: analisa tasks, decompoe em micro-tasks, delega para experts, faz merge (fallback se nao ha expert) |
| **Python Expert** | `manas-python-expert` | **NOVO** — Implementa micro-tasks de Python (FastAPI, Flask, Django, scripts) |
| **Golang Expert** | `manas-golang-expert` | **NOVO** — Implementa micro-tasks de Go (Gin, Echo, workers, CLI) |
| **Database Expert** | `manas-database-expert` | **NOVO** — Todos os bancos (SQL, NoSQL, cache, vector DB, migrations, schema) |
| **Bash Expert** | `manas-bash-expert` | **NOVO** — Scripts shell, CI/CD, deploy, automacao |
| **Rust Expert** | `manas-rust-expert` | **NOVO** — Implementa micro-tasks de Rust (Axum, Actix, sistemas) |
| **C/C++ Expert** | `manas-cpp-expert` | **NOVO** — Implementa micro-tasks de C/C++ (nativos, bindings, perf) |
| **Java Expert** | `manas-java-expert` | **NOVO** — Implementa micro-tasks de Java/Kotlin (Spring, Quarkus) |
| QA/Tester | `manas-ciel-qa-tester` | Validar tasks com foco em regressao via grafo |
| DevOps/Delivery | `manas-ciel-devops-delivery` | Build + relatorio com status dos grafos |

## Pipeline completo

```
Fase 0: GRAPH INDEX (Graph Indexer)
   ├── Verifica se Graphify index existe e esta fresco
   ├── Se nao: executa "graphify ."
   ├── Verifica se GitNexus index existe e esta fresco
   ├── Se nao: executa "gitnexus analyze"
   └── Saida: relatorio de prontidao dos grafos

Fase 1: VALIDATE SPECIFICATION (Execution Manager)
   ├── Verifica existencia de proposal.md, design.md, tasks.md
   ├── Valida consistencia entre documentos
   ├── Verifica acceptance criteria definidos
   ├── [NOVO] Le GRAPH_REPORT.md para contexto do codebase
   └── Se invalido → para e reporta o que falta

Fase 2: BUILD EXECUTION GRAPH (Execution Manager)
   ├── [NOVO] Chama Graph Navigator para entender god nodes e comunidades
   ├── Ordena tasks por dependencia
   ├── [NOVO] Tasks que afetam god nodes recebem prioridade ALTA
   ├── [NOVO] Tasks na mesma comunidade sao paralelizadas
   └── Cria execution-state.json enriquecido

Fase 3: ARCHITECT (Arquiteto)
   ├── [NOVO] Chama Graph Navigator para entender codebase existente
   ├── Detalha design.md com conhecimento do grafo
   ├── Gera estrutura inicial do projeto
   └── Preparar ambiente para os devs

Fase 4: DEV FRONTEND + DEV BACKEND (COORDENADOR)
   ├── Dev Frontend: implementa tasks de frontend (inalterado)
   ├── Dev Backend (COORDENADOR):
   │     ├── Recebe task do Execution Manager
   │     ├── Consulta Navigator para contexto inicial (hibrido)
   │     ├── Cria backend-execution-state.json
   │     ├── Decompoe a task em micro-tasks por stack
   │     ├── Executa experts em paralelo ou sequencial:
   │     │     ├── manas-python-expert  (Python)
   │     │     ├── manas-golang-expert  (Golang)
   │     │     ├── manas-database-expert (todos os bancos)
   │     │     ├── manas-bash-expert    (shell/CI/CD)
   │     │     ├── manas-rust-expert    (Rust)
   │     │     ├── manas-cpp-expert     (C/C++)
   │     │     └── manas-java-expert    (Java/Kotlin)
   │     ├── [FALLBACK] Se nao ha expert para a stack, implementa diretamente
   │     ├── Merge dos resultados
   │     └── Auto-revisao antes de entregar
   └── Cada expert pode consultar Navigator adicionalmente se necessario

Fase 5: PEER REVIEW (Arquiteto)
   ├── [NOVO] Usa Graph Navigator para impact analysis
   ├── Revisa codigo vs design.md
   ├── APROVADO → segue para QA
   └── REPROVADO → retorna ao dev com relatorio + dados de impacto

Fase 6: QA (validacao task por task)
   ├── [NOVO] Consulta Navigator para descobrir modulos em risco
   ├── Para cada task: testa vs acceptance criteria
   ├── Classifica falhas por tipo:
   │   ├── BUG_CODIGO → retorna ao DEV
   │   ├── DESIGN_ISSUE → retorna ao ARQUITETO
   │   └── REQUISITO → retorna ao EXECUTION MANAGER
   ├── [NOVO] Regression test prioriza comunidades afetadas
   └── LOOP ate todas as tasks passarem

Fase 7: DEVOPS / DELIVERY
   ├── Verifica: 100% tasks concluidas e aprovadas
   ├── [NOVO] Verifica estado dos grafos
   ├── Build de producao
   ├── [NOVO] Relatorio inclui status dos grafos
   └── Exibe caminhos dos arquivos criados

Fase 8: APROVACAO DO USUARIO
   ├── "O projeto esta de acordo?"
   ├── Sim → finalizado com sucesso
   └── Nao → Execution Manager reinicia com novos inputs

Fase 9: GRAPH REINDEX (Graph Indexer)
   ├── Verifica se houve commits
   ├── Se sim: reindexa Graphify + GitNexus
   └── Se nao: "Grafos mantidos"
```

## Fluxo de feedback entre agentes

```
Execution Manager
      │
      ▼
  Graph Indexer (Fase 0)
      │
      ▼
  Graph Navigator (consultas durante todo o pipeline)
      │
      ▼
  Architect ──► Devs ──► Peer Review ──► QA ──► DevOps ──► Usuario ──► Graph Indexer (Fase 9)
      ▲            ▲              │                    │
      │            │         REPROVADO            BUG_CODIGO ──► Dev
      │            │              │                    │      (Dev Backend coordena)
      │            │              ▼                    │
      │            │           (loop)                  ├── Dev Backend
      │            │                                   │     ├── manas-python-expert
      │            │                                   │     ├── manas-golang-expert
      │            │                                   │     ├── manas-database-expert
      │            │                                   │     ├── manas-bash-expert
      │            │                                   │     ├── manas-rust-expert
      │            │                                   │     ├── manas-cpp-expert
      │            │                                   │     └── manas-java-expert
      │            │                                   │
      │            │                              DESIGN_ISSUE ──► Architect
      │            │                                   │
      │            │                              REQUISITO ──► Exec Manager
      │            │                                   │
      └────────────┴───────────────────────────────────┘
```

## Regras importantes

- O pipeline executa automaticamente sem necessidade de aprovacao entre fases
- O usuario so intervem se faltar especificacao (Fase 1) ou no aceite final (Fase 8)
- Se uma task falhar 3 vezes no mesmo ponto, o pipeline aborta com relatorio
- Peer Review e QA sao obrigatorios
- Os grafos sao consultados mas NAO sao obrigatorios: se estiverem indisponiveis,
  o pipeline prossegue com metodos tradicionais (grep/glob)
- O Graph Navigator e chamado sob demanda, nao em todas as interacoes
- Se o usuario pedir etapa especifica, execute apenas essa etapa

## Instalacao dos grafos (necessario para o pleno funcionamento)

Antes de executar o pipeline, os grafos precisam estar instalados no projeto:

```bash
# Graphify
pip install graphifyy
graphify install --platform opencode

# GitNexus
npx gitnexus@latest analyze
```

O Graph Indexer tentara executar isso automaticamente, mas se faltarem
dependencias (Python, npm), o pipeline prosseguira sem os grafos.
