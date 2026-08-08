---
description: Criar novas questões e atualizar o banco. Ex.: /novas-questoes 24
---

Crie $1 novas questões para o cargo de Analista Administrativo da Câmara Municipal de Rio Verde (GO) no exercício de suas funções (descritas no arquivo "Cargo-Analista-Administrativo").

Se o número de questões não for informado, crie 12 (1 por área). Distribua as questões igualmente entre as 12 áreas do conhecimento; se a quantidade não for múltipla de 12, distribua as sobras pelas áreas na ordem do manifesto. Use dataCriacao igual à data de hoje (se o usuário pedir uma data específica, use a pedida).

LEIA ANTES DE COMEÇAR:
- "Conteúdo programático da prova.docx" → as 12 áreas de conhecimento
- "manifesto-topicos.json" → filas de tópicos (queue/covered) por área
- "Legislacao/" → fontes das leis; use apenas nomes de arquivos existentes como slugs de referenciaLegal

REGRAS DE CONTEÚDO:
- Privilegiar assuntos e procedimentos internos da Câmara Municipal de Rio Verde (GO) e/ou relacionamento entre poderes municipais (legislativo e executivo).
- Crie alternativas curtas (evite evidenciar a alternativa correta).
- Explicações bem didáticas, elaboradas e bem fundamentadas.
- Elementos visuais (diagramas, esquemas, fluxogramas, tabelas, SVG) são bem-vindos quando ajudarem no entendimento.
- Cada questão deve ter: id sequencial a partir do maior existente, area, dataCriacao, enunciado, alternativas (a–e), respostaCorreta, explicacao, diagramas[] e referenciaLegal[] (só slugs existentes em Legislacao/).

CONSUMO DO MANIFESTO (questão a questão):
- Use o primeiro tópico da queue da área e mova-o para covered[] da mesma área.
- Se a queue da área esvaziar, mova TODO o covered[] de volta para a queue (reinicia o ciclo) e avise o usuário no relatório final.

EXECUÇÃO (nesta ordem):
1. Grave as novas questões em questoes_novas.json (adicionando ao array, sem apagar o que já existe).
2. Execute: python3 gerar_questoes.py
3. Valide: total em questoes.json (684 + novas), ids únicos e sequenciais, respostaCorreta válida, todos os referenciaLegal existentes em Legislacao/, nenhuma queue do manifesto vazia.

NÃO FAÇA:
- Não edite manualmente index.html, questoes.json ou questoes/q-*.html — o gerar_questoes.py os atualiza.
- Não use os scripts antigos (gerar-12-questoes.js, gerar-mais-12.js, gerar-mais12-v*.js, gerar-paginas.js) — estão obsoletos.
- Não altere script.js, styles.css.
- Não faça commit, a menos que o usuário peça.

RELATÓRIO FINAL (entregue ao usuário):
- Lista das novas questões com área e tópico consumido.
- Avisos de ciclos reiniciados.
- Resultado das validações.
