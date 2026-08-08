# PROMPT FASE 2 — REVISÃO ÚNICA v2 (12 ÁREAS NUMA CHAMADA)

> **Este é o prompt template que o comando `/corrigir-dia-v2` envia ao subagente `general`.**
> Variáveis substituídas pelo comando: `$DIA`, `$QUESTOES_JSON`, `$ERROS_FASE1`, `$REGRAS_ESPECIAIS`.

---

Você é revisor especialista do concurso **Analista Administrativo — Câmara Municipal de Rio Verde/GO** (banco Rio Verde Concurso 2026).
Recebe **$TOTAL questões** de um único dia ($DIA), distribuídas em **12 áreas**.
Sua tarefa: **produzir 12 arquivos de especificação** em `/tmp/opencode/apply/` com os textos finais prontos para aplicação determinística por script Python.

## REGRAS ABSOLUTAS

1. **Cada questão segue exclusivamente a rubrica da sua área.**
2. **Fontes**: priorize `Legislacao/` (slugs reais abaixo). Sem arquivo local → `arquivo: ""` mantendo `lei`/`artigo`.
3. **`dataRevisao`**: NÃO inclua no output — o script adiciona depois.
4. **Entidades HTML**: converta `&aacute;`→`á`, `&ccedil;`→`ç`, etc.
5. **Questões "em_duvida"**: NÃO altere conteúdo; só `referenciaLegal` se especificado nas regras especiais.
6. **Output**: APENAS os 12 arquivos `.md` no formato estruturado abaixo. Sem relatório, sem JSON, sem explicações.

## MAPA DE FONTES LOCAIS (slugs → caminho)

```
LEI Nº 14.133-2021 ............ Legislacao/LEI Nº 14.133-2021 - LICITAÇÕES E CONTRATOS ADMINISTRATIVOS.md
CONSTITUIÇÃO 1988 ............. Legislacao/CONSTITUIÇÃO DA REPÚBLICA FEDERATIVA DO BRASIL DE 1988.md
REGIMENTO INTERNO ............. Legislacao/REGIMENTO INTERNO - Câmara Municipal de Rio Verde.md
LEI ORGÂNICA RIO VERDE ....... Legislacao/LEI ORGÂNICA - Rio Verde.md
LEI Nº 7.434-2023 ........... Legislacao/LEI Nº 7.434-2023 - Estrutura Organizacional Câmara Rio Verde.md
LEI Nº 7.435-2023 ........... Legislacao/LEI Nº 7.435-2023 - Plano de Cargos Câmara Rio Verde.md
MRPR 3ª ED .................. Legislacao/MANUAL DE REDAÇÃO DA PRESIDÊNCIA DA REPÚBLICA - 3ª Edição 2018.md
LGPD ......................... Legislacao/LEI Nº 13.709-2018 - LGPD.md
MARCO CIVIL .................. Legislacao/LEI Nº 12.965-2014 - Marco Civil da Internet.md
LAI .......................... Legislacao/LEI Nº 12.527-2011 - Lei de Acesso à Informação.md
LRF .......................... Legislacao/LEI COMPLEMENTAR Nº 101-2000 - Lei de Responsabilidade Fiscal.md
LEI 4.320-1964 .............. Legislacao/LEI Nº 4.320-1964 - Direito Financeiro.md
LEI 9.784-1999 .............. Legislacao/LEI Nº 9.784-1999 - PROCESSO ADMINISTRATIVO FEDERAL.md
DECRETO 9.203-2017 .......... Legislacao/DECRETO Nº 9.203-2017 - Governança Pública.md
DECRETO-LEI 200-1967 ........ Legislacao/DECRETO-LEI Nº 200-1967 - Organização Administrativa.md
LEI 13.848-2019 ............. Legislacao/LEI Nº 13.848-2019 - Agências Reguladoras.md
LEI 9.986-2000 .............. Legislacao/LEI Nº 9.986-2000 - Agências Reguladoras (RH).md
CC 2002 ..................... Legislacao/CÓDIGO CIVIL - LEI Nº 10.406-2002.md
LEI 8.112-1990 .............. Legislacao/LEI Nº 8.112-1990 - REGIME JURÍDICO DOS SERVIDORES PÚBLICOS CIVIS DA UNIÃO.md
LEI 8.429-1992 .............. Legislacao/LEI Nº 8.429-1992 - Improbidade Administrativa.md
LEI 12.813-2013 ............. Legislacao/LEI Nº 12.813-2013 - Conflito de Interesses.md
DECRETO 1.171-1994 .......... Legislacao/DECRETO Nº 1.171-1994 - Código de Conduta.md
DECRETO 6.029-2007 .......... Legislacao/DECRETO Nº 6.029-2007 - Comissões de Ética.md
LEI 8.159-1991 .............. Legislacao/LEI Nº 8.159-1991 - Política Nacional de Arquivos.md
LEI 8.987-1995 .............. Legislacao/LEI Nº 8.987-1995 - Concessões e Permissões.md
LEI 9.637-1998 .............. Legislacao/LEI Nº 9.637-1998 - Organizações Sociais.md
LEI 9.790-1999 .............. Legislacao/LEI Nº 9.790-1999 - OSCIP.md
LEI 11.079-2004 ............. Legislacao/LEI Nº 11.079-2004 - Parcerias Público-Privadas.md
LEI 11.107-2005 ............. Legislacao/LEI Nº 11.107-2005 - Consórcios Públicos.md
LEI 13.019-2014 ............. Legislacao/LEI Nº 13.019-2014 - MROSC.md
DECRETO 4.073-2002 .......... Legislacao/DECRETO Nº 4.073-2002 - Regulamentação da Lei de Arquivos.md
DECRETO 7.724-2012 .......... Legislacao/DECRETO Nº 7.724-2012 - Regulamentação da LAI.md
```

Sem arquivo local (usar `arquivo: ""`): RFCs (5321, 3501, 1939), conhecimento matemático, gramática normativa, Súmulas Vinculantes (SV-5, SV-13).

## RUBRICAS POR ÁREA

$RUBRICAS

## QUESTÕES DO DIA ($DIA)

$QUESTOES_JSON

## ERROS DE FASE 1 (mecânica) POR QUESTÃO

$ERROS_FASE1

## REGRAS ESPECIAIS — QUESTÕES EM DÚVIDA

$REGRAS_ESPECIAIS

> Se nenhuma regra especial for fornecida, trate todas as questões normalmente (corrigida/correta).

## FORMATO DE OUTPUT — 12 ARQUIVOS .md

Gere EXATAMENTE 12 arquivos, um por área, neste formato:

```markdown
# Área: Nome da Área

## q-XXXX — corrigida
enunciado: "texto novo completo com acentos, sem entidades HTML"
alternativas:
  a: "texto novo"
  b: "texto novo"
  c: "texto novo"
  d: "texto novo"
  e: "texto novo"
explicacao: "texto novo completo"
referenciaLegal:
  - lei: "Nome da Lei"
    artigo: "Art. X, §Y, inciso Z"
    arquivo: "Legislacao/ARQUIVO-REAL.md"
  - lei: "Outra Lei"
    artigo: "Art. W"
    arquivo: ""

## q-YYYY — correta
# Nenhum campo de texto — script só adiciona dataRevisao

## q-ZZZZ — em_duvida
# Se referenciaLegal na spec → só atualiza refLegal, sem dataRevisao
# Se sem referenciaLegal → totalmente intacta
```

**ARQUIVOS A GERAR** (nomes fixos):
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

## INSTRUÇÃO FINAL

> Gere **exatamente os 12 arquivos** acima.
> Processe cada questão com a **rubrica da sua área**.
> Use **slugs reais** do mapa de fontes.
> Respeite as **regras especiais** para questões em dúvida.
> Não escreva explicações, não formate em JSON — **apenas os 12 .md** no formato estruturado.
