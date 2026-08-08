# Fluxo de Execucao do Jarvis-WEB-TEAM

## Diagrama completo

```
                    ┌──────────────────────────┐
                    │      USUARIO             │
                    │  "Quero um site para..." │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │   PLANNING LAYER         │
                    │   (OpenSpec / Manual)    │
                    │                          │
                    │   proposal.md            │
                    │   design.md              │
                    │   tasks.md               │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  FASE 1: VALIDATE SPECS  │
                    │  (Execution Manager)     │
                    │                          │
                    │  Existem os 3 docs?      │
                    │  AC estao definidos?     │
                    │  Consistente?            │
                    │                          │
                    │  SIM ────────────► Fase 2│
                    │  NAO ──► reporta erro    │
                    └──────────────────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  FASE 2: BUILD GRAPH     │
                    │  (Execution Manager)     │
                    │                          │
                    │  Ordena tasks            │
                    │  Cria execution-state    │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  FASE 3: ARCHITECT       │
                    │                          │
                    │  Detalha design.md       │
                    │  Gera estrutura inicial  │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  FASE 4: DEV             │
                    │                          │
                    │  Dev Frontend ──► Task A │
                    │  Dev Backend  ──► Task B │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
         ┌────────►│  FASE 5: PEER REVIEW     │◄────────┐
         │         │  (Arquiteto revisa)       │         │
         │         │                          │         │
         │         │  APROVADO ──► Fase 6     │         │
         │         │  REPROVADO ──► Fase 4 🔄 │         │
         │         └────────────┬─────────────┘         │
         │                      │                       │
         │         ┌────────────▼─────────────┐         │
         │         │  FASE 6: QA              │         │
         │         │                          │         │
         │         │  Testa task vs AC        │         │
         │         │  Classifica falhas:      │         │
         │         │                          │         │
         │         │  BUG_CODIGO ──► Fase 4   │─────────┘
         │         │  DESIGN_ISSUE ──► Fase 3 │
         │         │  REQUISITO ──► Fase 1    │
         │         │                          │
         │         │  Todas tasks OK?         │
         │         │  SIM ──► Fase 7          │
         │         └────────────┬─────────────┘
         │                      │
         │         ┌────────────▼─────────────┐
         │         │  FASE 7: DEVOPS          │
         │         │                          │
         │         │  Verifica 100% tasks     │
         │         │  Build de producao       │
         │         └────────────┬─────────────┘
         │                      │
         │         ┌────────────▼─────────────┐
         │         │  FASE 8: APROVACAO       │
         │         │                          │
         │         │  "Projeto esta de        │
         │         │  acordo?"                │
         │         │                          │
         │         │  SIM ──► FIM 🎉          │
         └─────────┤  NAO ──► informa o que   │
                   │          mudar e volta   │
                   │          ao inicio       │
                   └──────────────────────────┘
```

## Legenda dos loops de feedback

| Loop | Gatilho | Origem | Destino |
|------|---------|--------|---------|
| Loop A | Peer Review reprovou | Arquiteto | Dev |
| Loop B | QA achou BUG_CODIGO | QA | Dev |
| Loop C | QA achou DESIGN_ISSUE | QA | Arquiteto |
| Loop D | QA achou REQUISITO | QA | Execution Manager |
| Loop E | Usuario reprovou | Usuario | Execution Manager |
