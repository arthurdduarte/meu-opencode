---
description: Revisar/corrigir todas as questões de um dia com arquitetura v3 (organizador + 12 subagentes revisor-* por área, sequenciais, specs + script determinístico). Ex.: /corrigir-dia-v3 2026-07-28 ou /corrigir-dia-v3 2026-07-28 --aplicar
---

Revise e corrija as questões de um dia específico do banco Rio Verde Concurso usando **arquitetura v3**: um agente **organizador** separa as questões por área e conduz, **estritamente sequencial** (uma por vez, NUNCA em paralelo), **12 subagentes revisor-*** (um por área, cada um com a rubrica própria embutida), recebe as correções de volta, valida as specs e entrega o resultado. A aplicação é feita por **script Python determinístico** (0 LLM).

O dia é $1 (formato AAAA-MM-DD). Flags opcionais:
- `--aplicar` → aplica as correções no banco (default é só gerar specs/report).
- `--forcar` → re-revisa questões que já tenham `dataRevisao`.
- `--internet` → autoriza consulta a fontes externas/internet (repassada aos revisores).

O v3 é **independente do v2**: não altera `corrigir-dia-v2.md`, `fase2-v2.md`, `aplicar_specs.py` nem `/tmp/opencode/apply/`.

## POLÍTICA DE FONTES (flexível) — mesma das versões anteriores

- Fonte local em `Legislacao/` disponível → conferir a citação contra ela.
- Fonte local ausente → conhecimento técnico como referência; com `--internet`, pode consultar a web.
- Dúvida real (fonte divergente/conflitante) → marcar "Em dúvida" sem alterar (sinalizador; não bloqueio).

## FASE 1 — Validação mecânica

Execute: `python3 validar_questoes.py --dia $1`

Use a saída para:
1. Confirmar quantas questões do dia existem e listá-las (grupo por área).
2. Guardar os **erros** de Fase 1 (entidades, acentos, slugs inexistentes, respostaCorreta inválida, etc.) para repassar ao organizador.
3. **Regra anti-re-trabalho**: se uma questão já tem `dataRevisao` E o usuário NÃO passou `--forcar`, exclua-a do dia (mencione no relatório como "já revisada").

Escreva as questões **não revisadas** do dia em `/tmp/opencode/v3/dia-$1.json` como **array JSON** (objetos completos, sem alterar nada), usando um comando python de leitura/escrita (ex.: filtrar `questoes.json` por `dataCriacao == $1` e `dataRevisao` ausente). Não edite `questoes.json` neste passo.

## FASE 2 — Organizador + Revisores por área (sequencial)

Invoque o subagente `organizador-correcao` (Task) passando:
- `dia`: $1
- `dia_path`: `/tmp/opencode/v3/dia-$1.json`
- `erros_fase1`: erros da Fase 1 (agrupados por questão)
- `usar_internet`: true se `--internet`, senão false
- `regras_especiais`: q-0595, q-0646, q-0611 (só `referenciaLegal`, sem `dataRevisao`) — e outras que o usuário indicar

O organizador:
1. Lê o dia, separa em 12 bundles por área (`/tmp/opencode/v3/bundles/`).
2. Loop **sequencial** (área 1 → 12): chama `revisor-{slug}`, aguarda, recebe a spec + relatório, valida a spec (todas as questões presentes, campos corretos) **antes** de avançar, re-invocando o revisor se quebrada (até 2 tentativas).
3. Retorna o relatório consolidado e a lista de specs prontas (`/tmp/opencode/v3/specs/*.md`).

## APLICAÇÃO — Script Determinístico (0 LLM)

Se `--aplicar` (ou usuário aprovar após o relatório):

1. Execute: `python3 aplicar_specs_v3.py --dia $1`
   - Lê specs em `/tmp/opencode/v3/specs/*.md`
   - Merge determinístico em `questoes.json`:
     - `corrigida`: substitui enunciado/alternativas/explicacao/referenciaLegal + adiciona `dataRevisao`
     - `correta`: só adiciona `dataRevisao`
     - `em_duvida`: pula (exceto q-0595/q-0646/q-0611: só `referenciaLegal`, sem `dataRevisao`)
   - Se a questão existir em `questoes_novas.json`, aplica lá também
   - Rode primeiro em modo dry-run para conferir, depois `--aplicar`.

2. Sincronização: `node gerar-paginas.js` + `python3 gerar_questoes.py --index`

3. Smoke test: `python3 validar_questoes.py --dia $1` — deve apontar 0 erros nas questões revisadas.

4. Atualize `resumo_revisoes.md` com uma seção `# Revisão de {data} — Dia $1 (60 questões, 12 áreas) — **Arquitetura v3**` no padrão existente (resultado por área, correções com fonte, validação pós-aplicação, sincronização).

5. **Um único commit final** SOMENTE se o usuário autorizar.

## RELATÓRIO FINAL (entregue ao usuário)

- Tabela por área: questões revisadas / corrigidas / corretas / em dúvida / já revisadas (puladas).
- Detalhe das correções (o que mudou e por quê, com a fonte que comprova) — use o relatório do organizador.
- Erros de Fase 1 corrigidos.
- **Questões marcadas "Em dúvida"** (não alteradas — aguardam decisão).
- Áreas com FALHA (se houver) e motivo.
- Aviso se o dia não existir no banco ou se todas as questões já estavam revisadas.

## NÃO FAÇA

- Não processe áreas em paralelo; o organizador segue o fluxo estritamente sequencial.
- Não altere NENHUM arquivo do v1 ou do v2 (`corrigir-dia.md`, `corrigir-dia-v2.md`, `fase2-v2.md`, `aplicar_specs.py`, `/tmp/opencode/apply/`).
- Não edite `index.html`, `questoes/q-*.html`, `script.js` ou `styles.css` manualmente — use os scripts.
- Não altere `id`, `area` ou `dataCriacao` (exceto se Fase 1 apontar data errada do dia).
- Não invente citação sem conferir a fonte em `Legislacao/`.
- Não faça commit sem autorização explícita do usuário.

## ARQUIVOS ENVOLVIDOS

- `.opencode/commands/corrigir-dia-v3.md` (este comando)
- `.opencode/agent/organizador-correcao.md` (organizador)
- `.opencode/agent/revisor-*.md` (12 revisores por área)
- `aplicar_specs_v3.py` (script determinístico v3, independente do v2)
- `/tmp/opencode/v3/{dia,bundles,specs,reports}/` (área de trabalho do v3)
- `validar_questoes.py`, `gerar-paginas.js`, `gerar_questoes.py` (scripts existentes)
- `rubricas-correcao.md`, `Legislacao/`, `manifesto-topicos.json`, `questoes.json`, `questoes_novas.json`
