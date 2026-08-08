---
description: Criar novas questões com o pipeline v3 (comando + script determinístico). Ex.: /novas-questoes-v3 24
---

Crie $1 novas questões para o concurso público da Câmara Municipal de Rio Verde (GO).

Se o número de questões não for informado, crie 12 (1 por área). Distribua as questões igualmente entre as 12 áreas do conhecimento; se a quantidade não for múltipla de 12, distribua as sobras pelas áreas na ordem do manifesto. Use dataCriacao igual à data de hoje (se o usuário pedir uma data específica, use a pedida).

LEIA ANTES DE COMEÇAR:
- "Cargo-Analista-Administrativo" → descrição e atribuições do cargo (contexto das questões)
- "manifesto-topicos.json" → filas de tópicos (queue/covered) por área
- "Legislacao/" → fontes das leis; use apenas nomes de arquivos existentes como slugs de referenciaLegal

REGRAS DE CONTEÚDO:
- Aplicação no contexto da cidade de Rio Verde (GO), situações extraordinárias.
- Crie alternativas curtas. Posição aleatória para a resposta correta. 
- Explicações completas e bem fundamentadas.
- Para questões de Informática envolvendo planilhas pode desenhar tabelas.
- Elementos visuais (diagramas, esquemas, fluxogramas, tabelas, SVG) são bem-vindos quando ajudarem no entendimento.
- Cada questão do lote deve ter APENAS: area, enunciado, alternativas (a–e), respostaCorreta, explicacao, diagramas[] (opcional) e referenciaLegal[] (só slugs existentes em Legislacao/). NÃO inclua id, dataCriacao ou dataRevisao — o script atribui.

CONSUMO DO MANIFESTO (entendimento — o script executa):
- Cada questão consome o primeiro tópico da queue da área (queue[0] → covered[]).
- Se a queue da área esvaziar, o script reinicia o ciclo (todo covered[] volta para a queue) e avisa no relatório. Confira no relatório do script que o reset ocorreu.

EXECUÇÃO (passos do comando — a IA executa os scripts internamente; o usuário não opera Python):
1. Rode o preview: python3 gerar_lote.py --preview --qtd $1 --dia DIA
   (substitua DIA pela data. Mostra os IDs e os tópicos que serão consumidos por área, além de avisar quais ciclos serão reiniciados.)
2. Escreva o lote em /tmp/opencode/lote_DIA.json (array JSON, só conteúdo, sem id/data). Escreva o arquivo completo com as questões.
3. Rode o pipeline: python3 gerar_lote.py --lote /tmp/opencode/lote_DIA.json --dia DIA
   O script: atribui IDs sequenciais, define dataCriacao, consome queue[0]→covered por área (reiniciando ciclos automaticamente), grava em questoes_novas.json, roda gerar_questoes.py (páginas + JSON + index), valida só o dia (--dia) e checa duplicatas cross-day. Ele apaga o arquivo de lote ao final.
4. Confira o relatório (IDs, tópicos consumidos, ciclos reiniciados, validação do dia, duplicatas).

NÃO FAÇA:
- Não edite manualmente index.html, questoes.json, questoes_novas.json, manifesto-topicos.json ou questoes/q-*.html — o gerar_lote.py e o gerar_questoes.py os atualizam.
- Não escreva scripts de build ad-hoc (build_q_*.py) — o gerar_lote.py substitui esse fluxo.
- Não use os scripts antigos (gerar-12-questoes.js, gerar-mais-12.js, gerar-mais12-v*.js, gerar-paginas.js) — estão obsoletos.
- Não altere script.js, styles.css.
- Não faça commit, a menos que o usuário peça.

RELATÓRIO FINAL (entregue ao usuário):
- Lista das novas questões com área e tópico consumido (use a saída do gerar_lote.py).
- Avisos de ciclos reiniciados.
- Resultado das validações (saída do script: validação do dia + duplicatas).

ARQUIVOS ENVOLVIDOS:
- `.opencode/commands/novas-questoes-v3.md` (este comando)
- `gerar_lote.py` (pipeline determinístico v3)
- `gerar_questoes.py` (gera páginas/JSON/index — chamado pelo pipeline)
- `validar_questoes.py` (validação mecânica — chamado pelo pipeline com --dia)
- `manifesto-topicos.json`, `questoes.json`, `questoes_novas.json`, `Legislacao/`
