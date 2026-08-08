---
name: jarvis-web-team
description: >
  Use ONLY when the user asks to create, plan, develop, or deliver a web project
  (site, page, application, landing page, dashboard, SPA, etc.). Orchestrates a
  spec-driven team of subagents (Execution Manager, Architect, Dev Frontend,
  Dev Backend, QA, DevOps) with peer review and classified QA feedback loops.
  Consumes proposal.md, design.md and tasks.md from OpenSpec or any planning tool.
---

# Jarvis-WEB-TEAM

Time de subagentes especializados para execucao de projetos WEB a partir de especificacoes estruturadas (Spec-Driven Development).

## Filosofia

Esta skill **nao cria especificacao**. Ela **consome e executa** uma especificacao existente.

A especificacao pode vir de:
- OpenSpec (proposal.md, design.md, tasks.md)
- Documentos escritos manualmente
- Outra ferramenta de planejamento via IA

## Quando usar

Ative esta skill quando o usuario pedir para criar, planejar, desenvolver ou
entregar um projeto WEB. Exemplos: "criar um site", "preciso de uma landing
page", "fazer um dashboard", "desenvolver um e-commerce", "criar SPA".

A skill detectara automaticamente se existe uma especificacao (proposal.md, design.md, tasks.md).
- Se existir: executara o pipeline completo
- Se nao existir: solicitara que voce forneca ou instale o OpenSpec para gerar

## Subagentes disponiveis

| Subagente | Arquivo | Responsabilidade |
|-----------|---------|-----------------|
| Execution Manager | `jarvis-execution-manager` | Orquestrar pipeline, validar specs, distribuir tasks |
| Arquiteto | `jarvis-arquiteto` | Detalhar design.md, revisar codigo dos devs (Peer Review) |
| Dev Frontend | `jarvis-dev-frontend` | Implementar tasks de frontend |
| Dev Backend | `jarvis-dev-backend` | Implementar tasks de backend |
| QA/Tester | `jarvis-qa-tester` | Validar tasks por acceptance criteria, classificar falhas |
| DevOps/Delivery | `jarvis-devops-delivery` | Build, verificacao final, entrega |

## Pipeline completo

```
1. VALIDATE SPECIFICATION (Execution Manager)
   ├── Verifica existencia de proposal.md, design.md, tasks.md
   ├── Valida consistencia entre documentos
   ├── Verifica acceptance criteria definidos
   └── Se invalido → para e reporta o que falta

2. BUILD EXECUTION GRAPH (Execution Manager)
   ├── Ordena tasks por dependencia
   ├── Cria execution-state.json
   └── Define ordem de execucao

3. ARCHITECT
   ├── Consome design.md
   ├── Detalha decisoes tecnicas
   ├── Gera estrutura inicial do projeto
   └── Prepara ambiente para os devs

4. DEV FRONTEND + DEV BACKEND
   ├── Cada dev recebe tasks especificas do Execution Manager
   ├── Implementa seguindo design.md e acceptance criteria
   └── Auto-revisao antes de entregar

5. PEER REVIEW (Arquiteto)
   ├── Revisa codigo implementado pelos devs
   ├── Verifica aderencia ao design.md
   ├── APROVADO → segue para QA
   └── REPROVADO → retorna ao dev com relatorio

6. QA (validacao task por task)
   ├── Para cada task: testa vs acceptance criteria
   ├── Classifica falhas por tipo:
   │   ├── BUG_CODIGO → retorna ao DEV
   │   ├── DESIGN_ISSUE → retorna ao ARQUITETO
   │   └── REQUISITO → retorna ao EXECUTION MANAGER
   └── LOOP ate todas as tasks passarem

7. DEVOPS / DELIVERY
   ├── Verifica: 100% tasks concluidas e aprovadas
   ├── Build de producao
   ├── Relatorio de entrega final
   └── Exibe caminhos dos arquivos criados

8. APROVACAO DO USUARIO
   ├── "O projeto esta de acordo?"
   ├── Sim → finalizado com sucesso
   └── Nao → Execution Manager reinicia do passo 3 com novos inputs
```

### Fluxo de feedback entre agentes

```
Execution Manager
      │
      ▼
  Architect ──► Devs ──► Peer Review (Architect) ──► QA ──► DevOps ──► Usuario
      ▲            ▲              │                    │
      │            │         REPROVADO            BUG_CODIGO ──► Dev
      │            │              │                    │
      │            │              ▼               DESIGN_ISSUE ──► Architect
      │            │           (loop)                   │
      │            │                              REQUISITO ──► Exec Manager
      │            │                                    │
      └────────────┴────────────────────────────────────┘
```

### Regras importantes

- O pipeline executa automaticamente sem necessidade de aprovacao entre fases
- O usuario so e chamado a intervir se faltar especificacao (fase 1) ou no aceite final (fase 8)
- Se uma task falhar 3 vezes no mesmo ponto, o pipeline aborta com relatorio de erro
- Peer Review e QA sao etapas obrigatorias. Nenhum codigo vai para DevOps sem passar por ambos
- Se o usuario pedir etapa especifica (ex: "so a parte de design"), execute apenas essa etapa com o subagente correspondente

### Execucao automatica

O pipeline roda do inicio ao fim sem intervencao manual. A cada fase:

1. Dispare uma mensagem de status para o usuario informando qual fase esta comecando
2. Execute o subagente da fase via `task`
3. Colete o resultado e use como entrada para a fase seguinte
4. Dispare mensagem de conclusao da fase e status detalhado
5. Prossiga automaticamente para a proxima fase
