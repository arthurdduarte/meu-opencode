# Meu-opencode

Pacote de configuração do **opencode** do arthur — tudo o que existe além de uma
instalação recém-instalada, pronto para restaurar num ambiente limpo (ex.: após
formatar a máquina).

Coletado em **08/08/2026** — opencode **v1.18.15** (Debian).

## O que o pacote contém

```
Meu-opencode/
├── backup/
│   ├── MANIFEST.md                    # inventário detalhado do que foi coletado
│   ├── config-global/                 # → ~/.config/opencode/
│   │   ├── opencode.json              # provider 9router + modelo default + override explorer
│   │   ├── opencode.jsonc             # MCP gitnexus (habilitado) + context7/github (off) + openai
│   │   ├── opencode.json.bak          # backup antigo (config hybrid — inativa)
│   │   ├── agent/                     # 27 subagentes (jarvis-* 6, manas-* 15, sec-* 6)
│   │   └── skills/                    # 4 skills (graphify, jarvis-web-team, manas-ciel, sec-audit-team)
│   ├── legacy-opencode/               # → ~/.opencode/
│   │   ├── opencode.json              # registra o plugin graphify
│   │   └── plugins/graphify.js        # hook bash: lembrete do knowledge graph
│   └── projeto-concurso/.opencode/    # específico do repo Rio Verde Concurso
│       ├── agent/                     # organizador-correcao + revisor-* (15)
│       ├── commands/                  # corrigir-dia*, novas-questoes*, opsx-*
│       ├── prompts/                   # fase2-v2*, fase2-v2-1*
│       ├── skills/                    # openspec-* (5)
│       ├── AGENTS.md
│       └── workspace-summary.md
├── install.sh                         # instalador principal (5 passos)
├── scripts/
│   ├── aplicar-projeto.sh             # restaura o .opencode/ do projeto num repo
│   └── verificar.sh                   # checagem pós-instalação
└── docs/
    └── guia-instalacao.html           # passo a passo em HTML
```

## Como instalar num ambiente limpo

```bash
# 1. (se ainda não tem) pré-requisitos
sudo apt install git curl 2>/dev/null || true

# 2. clonar/abrir o pacote
git clone <url-do-repo-Meu-opencode> ~/Projects/Meu-opencode
cd ~/Projects/Meu-opencode

# 3. preencher os segredos antes de instalar (opcional, mas recomendado)
#    edite backup/config-global/opencode.json e opencode.jsonc
#    (placeholders: SEU_CONTEXT7_API_KEY, SEU_GITHUB_TOKEN, SUA_OPENAI_API_KEY, SUA_CHAVE_9ROUTER)

# 4. instalar (baixa o binário opencode v1.18.15, copia config/agentes/skills/plugin,
#    instala graphify via pipx, adiciona o PATH no ~/.bashrc)
./install.sh

# 5. conferir
./scripts/verificar.sh

# 6. (opcional) restaurar o .opencode/ do projeto concurso num repo
./scripts/aplicar-projeto.sh /caminho/para/Projeto-Concurso-RioVerde2026
```

Opções do `install.sh`:

| Flag | Efeito |
|---|---|
| `--dry-run` | mostra o que faria sem alterar nada |
| `--skip-binary` | não reinstala o binário do opencode |
| `--com-projeto` | copia o `.opencode/` do projeto para o diretório atual |

Env vars para substituir placeholders automaticamente: `OPENCODE_CONTEXT7_API_KEY`,
`OPENCODE_GITHUB_TOKEN`, `OPENCODE_OPENAI_API_KEY`, `OPENCODE_9ROUTER_KEY`.

## Segurança

- **Segredos NÃO estão no pacote** (sanitizados como placeholders).
- `auth.json` (`~/.local/share/opencode/auth.json`) **não é copiado** — faça `opencode auth login` na máquina nova.
- O binário do opencode (~183MB) **não é versionado** — o install.sh baixa do script oficial.

## Dependências externas reinstaladas

- `node`/`npm` (MCP `gitnexus` roda via `npx`)
- `pipx` + `graphifyy` (expõe `graphify` e `graphify-mcp`)

Veja o guia passo a passo em `docs/guia-instalacao.html`.
