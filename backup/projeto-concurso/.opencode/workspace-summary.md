# Workspace Summary — Concurso Rio Verde 2026

## Project Goal
Expandir e manter o banco de questões do concurso de Analista Administrativo da Câmara Municipal de Rio Verde (GO), usando `manifesto-topicos.json` como fonte da verdade para sequenciamento FIFO dos tópicos por área.

## Progress
- **Total:** 624 questões (q-0001 a q-0624)
- **Todas geradas**, com páginas individuais em `questoes/q-*.html`
- **Rotação FIFO** por área via `manifesto-topicos.json`

## Areas
12 áreas, cada uma com 52 questões (até a Rodada 20). Tópicos rodam em FIFO: quando a queue de uma área esvazia, todos os covered são reciclados para a queue.

## Data Sources
- `questoes.json` — fonte única de dados (624 questões)
- `index.html` — inline `window.__QUESTOES_DATA__` sync do JSON
- `questoes/q-*.html` — páginas individuais
- `script.js` — lógica SPA com `normalizeArea()` para segurança

## Fixes Aplicados (Sessão Recente)
1. **Scripts duplicados** em q-0588, q-0597, q-0598, q-0599, q-0600: `const questionData` estava em `<script>` separado do IIFE. Mesclados em bloco único.
2. **Áreas normalizadas**: 17 questões com `area` inconsistente corrigidas nos 3 formatos (JSON, index.html, HTMLs). `script.js` recebeu `normalizeArea()`.
3. **Semicolon missing** em q-0613 a q-0618: `var questionData = {...}` sem `;` antes do IIFE `(function()...`. JS interpretava o IIFE como chamada de método no objeto literal → `{(intermediate value)...}` → página vazia. Adicionado `;` entre JSON e IIFE.

## Sync Instructions
- Após alterar `questoes.json`: executar `node gerar-paginas.js` e sync `index.html`
- Para sync do `index.html`: substituir o bloco `<script>` contendo `window.__QUESTOES_DATA__` — usar `</script>` como delimitador (o JSON contém `;` dentro de entidades HTML)

## Relevant Files
- `questoes.json` — 624 questões, áreas normalizadas
- `index.html` — SPA com inline data
- `manifesto-topicos.json` — queue/covered por área para FIFO
- `questoes/q-*.html` — páginas individuais
- `script.js` — app logic com `normalizeArea()`
- `gerar-paginas.js` — geração de HTMLs a partir do JSON
