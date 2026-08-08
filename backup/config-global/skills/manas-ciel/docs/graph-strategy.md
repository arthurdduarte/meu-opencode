# Graph Strategy: Graphify vs GitNexus

Este documento define quando o Graph Navigator deve usar Graphify, GitNexus,
ou ambos para responder a uma consulta.

## Regra de ouro

Graphify = semantica e comunidades (entende O QUE o codigo faz).
GitNexus = estrutura e impacto (entende COMO o codigo se conecta).

## Matriz de decisao

| Pergunta do subagente | Ferramenta | Motivo |
|---|---|---|
| "explique o modulo X" | **Graphify** `explain` | Unico que entende proposito semantico |
| "o que esse codigo faz?" | **Graphify** `query` | LLM extrai intencao do codigo |
| "caminho entre X e Y" | **Graphify** `path` | Melhor para navegacao semantica |
| "quais comunidades existem?" | **Graphify** (Leiden) | Unico que detecta agrupamentos arquiteturais |
| "quais os god nodes?" | **Graphify** (degree) | Unico que identifica nos criticos |
| "impacto de mudar X?" | **GitNexus** `impact` | Impact analysis em tempo real com confidence score |
| "dependencias de X?" | **GitNexus** `context` | Upstream + downstream completo |
| "o que chama X?" | **GitNexus** `query` | Call graph estrutural exato |
| "onde X e usado?" | **GitNexus** `query` | Cross-file reference tracking |
| "visao geral do projeto" | **Graphify** `GRAPH_REPORT.md` | Resumo executivo com comunidades + god nodes |
| "analise completa de mudanca" | **Ambos** | Graphify para contexto semantico + GitNexus para blast radius |

## Quando usar ambos

Para perguntas complexas, o Navigator deve consultar ambas as ferramentas
e mesclar os resultados:

1. Graphify: entende o que o codigo faz (semantica, comunidades)
2. GitNexus: entende como o codigo se conecta (dependencias, impacto)

Exemplo: "Analise o impacto de modificar o modulo de pagamento"
- GitNexus `impact` -> blast radius estrutural
- Graphify `query` -> proposito de cada modulo afetado
- Graphify `explain` -> god nodes na comunidade de pagamento
- Resultado mesclado: "27 arquivos afetados, 2 god nodes, 3 comunidades"

## Ordem de falha

Se Graphify falhar (sem LLM key, por exemplo):
- Usar GitNexus como fallback para consultas estruturais
- Reportar ao solicitante: "Graphify indisponivel, retornando dados estruturais"

Se GitNexus falhar (sem indice, por exemplo):
- Usar Graphify como fallback para consultas semanticas
- Reportar ao solicitante: "GitNexus indisponivel, retornando dados semanticos"

Se ambos falharem:
- Reportar ao solicitante: "Grafos indisponiveis. Execute 'graphify .' e 'gitnexus analyze' no projeto"
