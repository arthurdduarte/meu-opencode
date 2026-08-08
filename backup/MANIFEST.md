# MANIFEST — Estado coletado (08/08/2026)

Pacote gerado a partir da máquina do arthur (Debian) — **opencode v1.18.15**.

## O que existe além de uma instalação "recém-instalada"

Uma instalação limpa do opencode traz apenas: `build`, `plan`, `general`, `explore`
(agentes built-in) e nenhuma skill/MCP/config custom. O que foi **adicionado** nesta máquina:

### 1. Config global (`~/.config/opencode/`)
| Arquivo | O que faz |
|---|---|
| `opencode.json` | Provider `9router` (endpoint local `127.0.0.1:20128/v1`, modelo `Combo01`) + modelo default `9router/Combo01` + override do agente `explorer` |
| `opencode.jsonc` | MCP `gitnexus` (local via `npx gitnexus@latest mcp`, **habilitado**), MCP `context7` e `github` (desabilitados, chaves sanitizadas), provider `openai` (chave sanitizada), permissões `allow` para tools gitnexus |
| `opencode.json.bak` | Backup antigo (config `hybrid` de embeddings locais via Ollama) — **não mais ativa** |

### 2. Agentes globais (`~/.config/opencode/agent/`) — 27 subagentes
- **jarvis-*** (6): `jarvis-execution-manager`, `jarvis-arquiteto`, `jarvis-dev-backend`, `jarvis-dev-frontend`, `jarvis-devops-delivery`, `jarvis-qa-tester`
- **manas-*** (15): `manas-ciel-execution-manager`, `manas-ciel-architect`, `manas-ciel-dev-backend`, `manas-ciel-dev-frontend`, `manas-ciel-devops-delivery`, `manas-ciel-qa-tester`, `manas-ciel-graph-indexer`, `manas-ciel-graph-navigator`, `manas-bash-expert`, `manas-cpp-expert`, `manas-database-expert`, `manas-golang-expert`, `manas-java-expert`, `manas-python-expert`, `manas-rust-expert`
- **sec-*** (6): `sec-execution-manager`, `sec-recon-dns`, `sec-scanner`, `sec-network`, `sec-webapp`, `sec-reporter`

### 3. Skills globais (`~/.config/opencode/skills/`) — 4 skills
- `graphify` v0.9.8 — knowledge graph (query/path/explain); requer binário `graphify` (pipx: `graphifyy`)
- `jarvis-web-team` v2.0.0 — pipeline web spec-driven (proposal/design/tasks + QA)
- `manas-ciel` — evolução do Jarvis com knowledge graphs (Graphify + GitNexus)
- `sec-audit-team` — auditoria de segurança (recon, scanner, network, webapp, reporter)

### 4. Legado `~/.opencode/` (instalação do binário + plugin)
- `bin/opencode` — **binário v1.18.15** (reinstalável via script oficial; NÃO incluído aqui por ser 183MB)
- `opencode.json` — registra o plugin `graphify.js`
- `plugins/graphify.js` — hook `tool.execute.before`: injeta lembrete do grafo em comandos bash quando `graphify-out/` existe
- PATH: `~/.opencode/bin` (e `~/.opencode2/bin`) adicionado no `.bashrc`

### 5. Específico do projeto Rio Verde Concurso (`.opencode/` do repo)
- **Agentes** (15): `organizador-correcao` + `revisor-*` (12 áreas + `revisor-questoes`)
- **Commands** (12): `corrigir-dia*` (v1/v2/v2.1/v3), `novas-questoes*` (v1/v3), `opsx-*` (explore/propose/apply/sync/archive)
- **Prompts** (2): `fase2-v2.md`, `fase2-v2-1.md`
- **Skills** (5): `openspec-*` (explore/propose/apply-change/archive-change/sync-specs)
- `AGENTS.md`, `workspace-summary.md`

## Dependências externas (reinstalar na máquina nova)
- **node/npm** ≥ 22 (usado pelo MCP `gitnexus` via `npx`)
- **pipx** (para instalar `graphifyy`, que expõe `graphify` e `graphify-mcp`)
- **git** (obviamente)

## Segredos sanitizados (NÃO estão no pacote)
Estas chaves foram substituídas por placeholders em `backup/config-global/`:
- `SEU_CONTEXT7_API_KEY` (opencode.jsonc — MCP context7, desabilitado)
- `SEU_GITHUB_TOKEN` (opencode.jsonc — MCP github, desabilitado)
- `SUA_OPENAI_API_KEY` (opencode.jsonc — provider openai)
- `SUA_CHAVE_9ROUTER` (opencode.json — provider 9router, dummy local `sk_9router`)
- `auth.json` (`~/.local/share/opencode/auth.json`) NÃO é copiado — refazer `opencode auth login` na máquina nova.

Preencha os placeholders antes de rodar o `install.sh`, ou exporte as env vars documentadas no script.
