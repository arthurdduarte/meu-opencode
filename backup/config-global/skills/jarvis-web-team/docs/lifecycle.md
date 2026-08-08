# Ciclo de Vida de uma Task

Cada task no Jarvis-WEB-TEAM passa por estados bem definidos:

## Estados

```
                    ┌──────────┐
                    │ PENDING  │  Task aguardando na fila
                    └────┬─────┘
                         │
                    ┌────▼─────┐
                    │ RUNNING  │  Task sendo executada pelo responsavel
                    └────┬─────┘
                         │
                    ┌────▼──────┐
                    │PEER REVIEW│  Task aguardando revisao do Arquiteto
                    └────┬──────┘
                         │
                    ┌────▼────┐
                    │ QA_TEST │  Task em teste pelo QA
                    └────┬────┘
                         │
               ┌─────────┴──────────┐
               │                    │
          ┌────▼────┐         ┌─────▼──────┐
          │APPROVED │         │  FAILED    │
          └────┬────┘         └─────┬──────┘
               │                    │
          Pronto para         ┌──────┴──────┐
          entrega/merge       │             │
                         BUG_CODIGO   DESIGN_ISSUE
                              │             │
                         volta a        volta ao
                         RUNNING       RUNNING
                                        │
                                  Arquiteto revisa
                                  design.md
```

## Transicoes

| De | Para | Gatilho |
|----|------|---------|
| PENDING | RUNNING | Execution Manager disparou a task |
| RUNNING | PEER_REVIEW | Dev concluiu implementacao |
| PEER_REVIEW | RUNNING | Arquiteto reprovou (volta pra correcao) |
| PEER_REVIEW | QA_TEST | Arquiteto aprovou |
| QA_TEST | APPROVED | QA aprovou todos AC |
| QA_TEST | FAILED | QA reprovou |
| FAILED | RUNNING | Execution Manager redirecionou para correcao |

## Politica de maximo de tentativas

- Maximo de tentativas por task: **3**
- Se a mesma task falhar 3 vezes consecutivas em qualquer estado:
  - O pipeline e abortado
  - Um relatorio de erro detalhado e gerado
  - O usuario recebe o relatorio para decidir o que fazer

## Rastreamento

Todas as transicoes sao registradas no execution-state.json, permitindo:
- Saber exatamente onde cada task esta
- Retomar execucoes interrompidas
- Gerar metricas de performance do pipeline
- Identificar gargalos (tasks que voltam muito ao RUNNING)
