---
description: Revisar/corrigir todas as questões de um dia, área por área (sequencial e isolado). Ex.: /corrigir-dia 2026-08-02 ou /corrigir-dia 2026-08-02 --aplicar
---

Revise e corrija as questões de um dia específico do banco Rio Verde Concurso, processando as 12 áreas **de forma sequencial e isolada** (uma área por vez, cada uma em um subagente próprio — NUNCA em paralelo).

O dia é $1 (formato AAAA-MM-DD). Flags opcionais:
- `--aplicar` → aplica as correções no banco (default é só relatório).
- `--forcar` → re-revisa questões que já tenham `dataRevisao`.
- `--internet` → autoriza consulta a fontes externas/internet (ver política abaixo).

## POLÍTICA DE FONTES (flexível)

A verificação **prioriza as fontes locais** em `Legislacao/` e o conteúdo programático, pois são a base confiável do projeto. Mas o processo **não é engessado**:

- Fonte local disponível → confira a citação contra ela.
- Fonte local ausente → o revisor usa o próprio conhecimento técnico como referência (norte) e, se o usuário autorizou `--internet`, pode consultar a web para confirmar/suplementar.
- Em caso de **dúvida real** (informação divergente ou conflitante entre fontes), o revisor marca a questão como **"Em dúvida"** e reporta, em vez de alterar no escuro. É um sinalizador para você decidir, não um bloqueio: se houver base sólida para corrigir, corrija.

## FASE 1 — Validação mecânica

Execute: `python3 validar_questoes.py --dia $1`

Use a saída para:
1. Confirmar quantas questões do dia existem e listá-las (grupo por área).
2. Guardar os **erros** de Fase 1 (entidades, acentos, slugs inexistentes, respostaCorreta inválida, etc.) para repassar aos subagentes.
3. **Regra anti-re-trabalho**: se uma questão já tem `dataRevisao` E o usuário NÃO passou `--forcar`, marque-a como já revisada e não a inclua na revisão da Fase 2 (mencione no relatório).

## FASE 2 — Revisão por área (sequencial)

Ordem das áreas = ordem do `manifesto-topicos.json` (as questões já nascem desse manifesto — não é preciso cruzá-lo durante a correção). Para CADA área, nesta ordem, **um de cada vez, esperando terminar antes do próximo**:

1. Leia a seção da área em `rubricas-correcao.md`.
2. Chame o subagente `revisor-questoes` (mode subagent) passando: `area`, `rubrica`, as questões da área do dia (excluindo as já revisadas, salvo `--forcar`), `modo` (`aplicar` se `--aplicar` foi dado, senão `report-only`), `usar_internet` (true apenas se `--internet` foi dado) e os erros de Fase 1 daquelas questões.
3. Aguarde o relatório dele, registre no relatório geral e passe para a próxima área.

## APLICAÇÃO (após o último subagente)

Se o modo for **aplicar** (ou se o usuário aprovar depois do relatório em modo `report-only`):

1. Rode a sincronização: `node gerar-paginas.js` e `python3 gerar_questoes.py --index`.
2. Smoke test: `python3 validar_questoes.py --dia $1` — deve apontar 0 erros nas questões revisadas.
3. Atualize `resumo_revisoes.md` (padrão já existente) com o resultado por área.
4. Faça **um único commit final** com mensagem descritiva (ex.: "Revisão das questões de {data}"), SOMENTE se o usuário autorizar.

## RELATÓRIO FINAL (entregue ao usuário)

- Tabela por área: questões revisadas / corrigidas / corretas / já revisadas (puladas).
- Detalhe das correções (o que mudou e por quê, com a fonte que comprova).
- Erros de Fase 1 corrigidos.
- **Questões marcadas "Em dúvida"** (não alteradas — aguardam decisão do usuário).
- Aviso se o dia não existir no banco ou se todas as questões já estavam revisadas.

## NÃO FAÇA

- Não processe duas áreas em paralelo; o fluxo é estritamente sequencial.
- Não edite `index.html`, `questoes/q-*.html`, `script.js` ou `styles.css` manualmente — use os scripts.
- Não altere `id`, `area` ou `dataCriacao` (exceto se Fase 1 apontar data errada do dia).
- Não invente citação sem conferir a fonte em `Legislacao/`.
- Não faça commit sem autorização explícita do usuário.
