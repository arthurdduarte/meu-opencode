---
description: Revisar/corrigir todas as questões de um dia com arquitetura v2.1 (1 chamada LLM por área, sequencial + script determinístico). Ex.: /corrigir-dia-v2-1 2026-08-02 ou /corrigir-dia-v2-1 2026-08-02 --aplicar
---

Revise e corrija as questões de um dia específico do banco Rio Verde Concurso usando **arquitetura v2.1**: **uma chamada LLM por área de conhecimento, estritamente sequencial**, gerando specs `.md` no mesmo formato da v2, aplicadas por **script Python determinístico** (0 LLM).

O dia é $1 (formato AAAA-MM-DD). Flags opcionais:
- `--aplicar` → aplica as correções no banco (default é só gerar specs/report).
- `--forcar` → re-revisa questões que já tenham `dataRevisao`.
- `--internet` → autoriza consulta a fontes externas/internet (repassada ao LLM).

A v2.1 é **independente da v2**: não altera `corrigir-dia-v2.md`, `fase2-v2.md`, `aplicar_specs.py`. Usa o mesmo diretório `/tmp/opencode/apply/`, mas **limpa os specs antigos** antes de gerar os seus.

## POLÍTICA DE FONTES (flexível) — mesma da v2

- Fonte local em `Legislacao/` disponível → conferir a citação contra ela.
- Fonte local ausente → conhecimento técnico como referência; com `--internet`, pode consultar a web.
- Dúvida real (fonte divergente/conflitante) → marcar "Em dúvida" sem alterar (sinalizador; não bloqueio).

## FASE 1 — Validação mecânica

Execute: `python3 validar_questoes.py --dia $1`

Use a saída para:
1. Confirmar quantas questões do dia existem e listá-las (grupo por área).
2. Guardar os **erros** de Fase 1 (entidades, acentos, slugs inexistentes, respostaCorreta inválida, etc.) para incluir no prompt Fase 2 por questão.
3. **Regra anti-re-trabalho**: se uma questão já tem `dataRevisao` E o usuário NÃO passou `--forcar`, marque-a como já revisada e exclua da Fase 2 (mencione no relatório).

Escreva as questões **não revisadas** do dia em `/tmp/opencode/v2-1/dia-$1.json` como **array JSON** (objetos completos, sem alterar nada), usando um comando python de leitura/escrita (ex.: filtrar `questoes.json` por `dataCriacao == $1` e `dataRevisao` ausente — ou filtrar também de `questoes_novas.json` se houver). Não edite `questoes.json` neste passo.

## FASE 2 — Revisão por área (1 chamada LLM por área, sequencial)

**Limpeza**: antes de começar, remova os 12 arquivos de spec de execuções anteriores em `/tmp/opencode/apply/` (`01-*.md` … `12-*.md`) para a v2.1 nunca aplicar specs misturadas.

**Loop sequencial**: percorra as 12 áreas **na ordem do `manifesto-topicos.json`** (Língua Portuguesa, Matemática, Informática, Administração Geral, Gestão Administrativa, Legislação Aplicada à Administração Pública, Legislação Específica, Noções de Administração Pública, Noções de Direito Administrativo, Noções de Direito Constitucional, Redação Oficial, Ética na Administração Pública). Para cada área **com questões não revisadas no dia**, **uma de cada vez, esperando terminar antes da próxima**:

1. Leia a seção da área em `rubricas-correcao.md` (rubrica).
2. Monte o prompt a partir do template `.opencode/prompts/fase2-v2-1.md`, substituindo:
   - `$DIA` → $1
   - `$AREA` → nome da área
   - `$ARQUIVO_SPEC` → `/tmp/opencode/apply/NN-<slug>.md` (nomes fixos abaixo)
   - `$RUBRICA` → seção da área em `rubricas-correcao.md`
   - `$QUESTOES_JSON` → JSON das questões **não revisadas** daquela área (do `dia-$1.json`)
   - `$ERROS_FASE1` → erros de Fase 1 daquelas questões (ou "nenhum")
   - `$REGRAS_ESPECIAIS` → q-0595, q-0646, q-0611 (só `referenciaLegal`, sem `dataRevisao`) se alguma estiver na área; senão vazio
   - `$USAR_INTERNET` → true se `--internet`, senão false
3. Chame o subagente `general` (Task) **UMA vez** para esta área com o prompt completo. Aguarde o retorno.
4. **Gate de validação por área**: leia o spec gerado em `$ARQUIVO_SPEC` e confirme que **todas** as questões não revisadas da área aparecem com status válido (`corrigida` | `correta` | `em_duvida`). Se faltar alguma ou o formato estiver quebrado, re-invoque o `general` para a **mesma área** (até 2 tentativas). Se persistir a falha, marque a área como **FALHA** no relatório e **siga para a próxima** (não bloqueie as demais).
5. Registre o resultado da área e passe para a próxima.

**NOMES FIXOS DE SPEC** (ordem do manifesto):
1. `/tmp/opencode/apply/01-lingua-portuguesa.md`
2. `/tmp/opencode/apply/02-matematica.md`
3. `/tmp/opencode/apply/03-informatica.md`
4. `/tmp/opencode/apply/04-administracao-geral.md`
5. `/tmp/opencode/apply/05-gestao-administrativa.md`
6. `/tmp/opencode/apply/06-legislacao-aplicada.md`
7. `/tmp/opencode/apply/07-legislacao-especifica.md`
8. `/tmp/opencode/apply/08-nocoes-administracao-publica.md`
9. `/tmp/opencode/apply/09-nocoes-direito-administrativo.md`
10. `/tmp/opencode/apply/10-nocoes-direito-constitucional.md`
11. `/tmp/opencode/apply/11-redacao-oficial.md`
12. `/tmp/opencode/apply/12-etica.md`

## APLICAÇÃO — Script Determinístico (0 LLM)

Se `--aplicar` (ou usuário aprovar após specs):

1. Execute: `python3 aplicar_specs.py --dia $1` (dry-run primeiro para conferir, depois `--aplicar`)
   - Lê specs em `/tmp/opencode/apply/*.md`
   - Merge determinístico em `questoes.json`:
     - `corrigida`: substitui enunciado/alternativas/explicacao/referenciaLegal + adiciona `dataRevisao`
     - `correta`: só adiciona `dataRevisao`
     - `em_duvida`: pula (exceto q-0595/q-0646/q-0611: só atualiza `referenciaLegal`, sem `dataRevisao`)
   - Se questão existir em `questoes_novas.json`, aplica lá também
   - Valida JSON resultante

2. Sincronização: `node gerar-paginas.js` + `python3 gerar_questoes.py --index`

3. Smoke test: `python3 validar_questoes.py --dia $1` — deve apontar 0 erros nas questões revisadas (exceto as em dúvida intocadas)

4. Atualize `resumo_revisoes.md` com resultado por área (menção explícita da arquitetura v2.1)

5. **Um único commit final** SOMENTE se o usuário autorizar

## RELATÓRIO FINAL (entregue ao usuário)

- Tabela por área: questões revisadas / corrigidas / corretas / em dúvida / já revisadas (puladas)
- Áreas com FALHA (se houver) e motivo
- Detalhe das correções (o que mudou e por quê, com fonte)
- Erros de Fase 1 corrigidos
- **Questões marcadas "Em dúvida"** (não alteradas — aguardam decisão)
- Aviso se dia não existir no banco ou se todas já revisadas

## NÃO FAÇA

- Não processe áreas em paralelo; o fluxo é estritamente sequencial (1 chamada LLM por vez)
- Não altere NENHUM arquivo da v1, v2 ou v3 (`corrigir-dia.md`, `corrigir-dia-v2.md`, `fase2-v2.md`, `aplicar_specs.py`, `.opencode/agent/revisor-*.md`, `/tmp/opencode/v3/`)
- Não edite `index.html`, `questoes/q-*.html`, `script.js` ou `styles.css` manualmente — use os scripts
- Não altere `id`, `area` ou `dataCriacao` (exceto se Fase 1 apontar data errada do dia)
- Não invente citação sem conferir a fonte em `Legislacao/`
- Não faça commit sem autorização explícita do usuário

## ARQUIVOS ENVOLVIDOS

- `.opencode/commands/corrigir-dia-v2-1.md` (este comando)
- `.opencode/prompts/fase2-v2-1.md` (template de prompt por área)
- `aplicar_specs.py` (script determinístico de aplicação — reutilizado da v2)
- `/tmp/opencode/apply/*.md` (specs geradas pelo LLM)
- `/tmp/opencode/v2-1/dia-$1.json` (questões não revisadas do dia)
- `validar_questoes.py`, `gerar-paginas.js`, `gerar_questoes.py` (scripts existentes)
- `rubricas-correcao.md`, `Legislacao/`, `manifesto-topicos.json`, `questoes.json`, `questoes_novas.json`
