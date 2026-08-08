---
description: Revisar/corrigir todas as questões de um dia com arquitetura v2 (1 chamada LLM + script determinístico). Ex.: /corrigir-dia-v2 2026-08-02 ou /corrigir-dia-v2 2026-08-02 --aplicar
---

Revise e corrija as questões de um dia específico do banco Rio Verde Concurso usando **arquitetura v2**: uma única chamada LLM para gerar specs + script Python determinístico para aplicação.

O dia é $1 (formato AAAA-MM-DD). Flags opcionais:
- `--aplicar` → aplica as correções no banco (default é só gerar specs/report).
- `--forcar` → re-revisa questões que já tenham `dataRevisao`.
- `--internet` → autoriza consulta a fontes externas/internet (passada ao LLM).

## POLÍTICA DE FONTES (flexível) — mesma do v1

## FASE 1 — Validação mecânica

Execute: `python3 validar_questoes.py --dia $1`

Use a saída para:
1. Confirmar quantas questões do dia existem e listá-las (grupo por área).
2. Guardar os **erros** de Fase 1 (entidades, acentos, slugs inexistentes, respostaCorreta inválida, etc.) para incluir no prompt Fase 2.
3. **Regra anti-re-trabalho**: se uma questão já tem `dataRevisao` E o usuário NÃO passou `--forcar`, marque-a como já revisada e exclua da Fase 2 (mencione no relatório).

## FASE 2 — Revisão Única (1 chamada LLM)

**Uma única chamada** ao subagente `general` com prompt estruturado contendo:
- 60 questões do dia (JSON)
- 12 rubricas (de `rubricas-correcao.md`)
- 30 fontes locais (mapa slug → caminho)
- Erros de Fase 1 por questão
- Regras especiais (q-0595, q-0646, q-0611 — não alterar conteúdo, só refLegal se especificado)

O LLM **gera 12 arquivos spec** em `/tmp/opencode/apply/01-...md` a `12-...md` com:
- Por questão: status (`corrigida` | `correta` | `em_duvida`)
- Textos novos literais (enunciado, alternativas, explicacao, referenciaLegal)
- **SEM `dataRevisao`** (script adiciona depois)

## APLICAÇÃO — Script Determinístico (0 LLM)

Se `--aplicar` (ou usuário aprovar após specs):

1. Execute: `python3 aplicar_specs.py --dia $1`
   - Lê specs em `/tmp/opencode/apply/*.md`
   - Merge determinístico em `questoes.json`:
     - `corrigida`: substitui enunciado/alternativas/explicacao/referenciaLegal + adiciona `dataRevisao`
     - `correta`: só adiciona `dataRevisao`
     - `em_duvida`: pula (exceto q-0611: só atualiza `referenciaLegal`, sem `dataRevisao`)
   - Se questão existir em `questoes_novas.json`, aplica lá também
   - Valida JSON resultante

2. Sincronização: `node gerar-paginas.js` + `python3 gerar_questoes.py --index`

3. Smoke test: `python3 validar_questoes.py --dia $1` — deve apontar 0 erros nas questões revisadas (exceto as 3 em dúvida intocadas)

4. Atualize `resumo_revisoes.md` com resultado por área

5. **Um único commit final** SOMENTE se o usuário autorizar

## RELATÓRIO FINAL (entregue ao usuário)

- Tabela por área: questões revisadas / corrigidas / corretas / em dúvida / já revisadas (puladas)
- Detalhe das correções (o que mudou e por quê, com fonte)
- Erros de Fase 1 corrigidos
- **Questões marcadas "Em dúvida"** (não alteradas — aguardam decisão)
- Aviso se dia não existir no banco ou se todas já revisadas

## NÃO FAÇA

- Não processe áreas em paralelo; o LLM processa tudo numa chamada, o script aplica tudo de uma vez
- Não edite `index.html`, `questoes/q-*.html`, `script.js` ou `styles.css` manualmente — use os scripts
- Não altere `id`, `area` ou `dataCriacao` (exceto se Fase 1 apontar data errada do dia)
- Não invente citação sem conferir a fonte em `Legislacao/`
- Não faça commit sem autorização explícita do usuário

## ARQUIVOS ENVOLVIDOS

- `.opencode/commands/corrigir-dia-v2.md` (este comando)
- `aplicar_specs.py` (script determinístico de aplicação)
- `/tmp/opencode/apply/*.md` (specs geradas pelo LLM)
- `validar_questoes.py`, `gerar-paginas.js`, `gerar_questoes.py` (scripts existentes)
- `rubricas-correcao.md`, `Legislacao/`, `manifesto-topicos.json`, `questoes.json`, `questoes_novas.json`