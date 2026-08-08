# Politica de Retry do Jarvis-WEB-TEAM

## Objetivo
Garantir que falhas transientes nao interrompam o pipeline, enquanto falhas sistematicas sao identificadas e reportadas rapidamente.

## Limite de tentativas

Cada task pode ser executada no maximo **3 vezes**.
A contagem e acumulativa atraves de todas as fases (dev, peer-review, qa).

```
Tentativa 1: Dev implementa → Peer Review reprova → Volta ao Dev
Tentativa 2: Dev corrige → Peer Review aprova → QA reprova → Volta ao Dev
Tentativa 3: Dev corrige → Peer Review aprova → QA reprova
             → ABORTA (atingiu 3 tentativas)
```

## Tabela de decisoes por tipo de falha

| Tipo de falha | Acao | Reset de contagem? |
|---------------|------|-------------------|
| BUG_CODIGO | Retorna ao DEV | Nao |
| DESIGN_ISSUE | Retorna ao ARQUITETO | Sim (contagem separada para arquiteto) |
| REQUISITO | Retorna ao EXECUTION MANAGER | Sim (contagem separada) |
| Peer Review reprovou | Retorna ao DEV | Nao |
| Build falhou | Retorna ao DEV | Contagem separada (max 2) |
| Erro de comunicacao (timeout, parse) | Retenta automaticamente | Nao conta |

## Contagem de tentativas separada

Devs e Arquiteto tem contadores independentes:

```
DEV: max 3 tentativas por task
ARQUITETO: max 3 tentativas por task (para DESIGN_ISSUE)
EXECUTION MANAGER: max 2 tentativas de correcao de requisito
```

Isso evita que um DESIGN_ISSUE consuma as tentativas do DEV.

## Abortando o pipeline

Se qualquer contador atingir o limite:

1. Pare o pipeline imediatamente
2. Gere um relatorio contendo:
   - Task que falhou
   - Historico de tentativas
   - Erro encontrado em cada tentativa
   - recomendacao para o usuario
3. Apresente o relatorio ao usuario
4. O usuario decide: abortar definitivamente ou reiniciar com ajustes

## Backoff entre tentativas

Para evitar loops infinitos rapidos:

| Tentativa | Tempo de espera |
|-----------|-----------------|
| 1 → 2     | Imediato        |
| 2 → 3     | 1 ciclo de feedback |

Isso permite que o agente anterior tenha tempo de processar o feedback e corrigir adequadamente.

## Casos especiais

### Se o QA reportar DESIGN_ISSUE
A task volta para o Arquiteto, nao para o Dev.
O contador do Arquiteto e incrementado (nao o do Dev).

### Se o QA reportar BUG_CODIGO + DESIGN_ISSUE juntos
Prioridade: primeiro DESIGN_ISSUE (arquiteto corrige), depois BUG_CODIGO (dev corrige).
Isso evita que o dev corrija algo que o arquiteto vai mudar.

### Se o build de producao falhar
O DevOps tem 2 tentativas de build. Se falhar 2x, relata ao Execution Manager.
Pode ser DESIGN_ISSUE (arquiteto) ou BUG_CODIGO (dev) dependendo do erro.

## Resumo

```
┌────────────────────────────────────────────────────────┐
│            POLITICA DE RETRY                           │
│                                                        │
│  Erro de comunicacao → retenta automaticamente        │
│  BUG_CODIGO → max 3x → aborta                        │
│  DESIGN_ISSUE → max 3x → aborta                     │
│  REQUISITO → max 2x → aborta                       │
│  Build → max 2x → aborta                          │
│                                                    │
│  Contagem independente por tipo de agente          │
│  Feedback loop não queima tentativa do outro       │
└────────────────────────────────────────────────────────┘
```
