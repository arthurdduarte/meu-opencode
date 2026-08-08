#!/usr/bin/env bash
# =============================================================================
# install.sh — Instala/aplica o pacote "Meu-opencode" em um ambiente limpo.
#
# Uso:
#   ./install.sh                 # instala opencode + configurações globais
#   ./install.sh --com-projeto   # também restaura o .opencode/ do projeto concurso
#   ./install.sh --dry-run       # apenas mostra o que faria (não altera nada)
#   ./install.sh --skip-binary   # não (re)instala o binário do opencode
#
# Segredos: o script lê estes placeholders dos ARQUIVOS copiados. Se o arquivo
# ainda contiver "SEU_" / "SUA_" (placeholder não preenchido), o script avisa e
# sugere preencher. Você também pode exportar as env vars abaixo para que o
# script substitua os placeholders automaticamente:
#   OPENCODE_CONTEXT7_API_KEY
#   OPENCODE_GITHUB_TOKEN
#   OPENCODE_OPENAI_API_KEY
#   OPENCODE_9ROUTER_KEY
#
# O que NÃO é feito por segurança: não copia auth.json (refaça `opencode auth login`)
# e não inclui o binário (baixa do script oficial, mantendo a versão em opencode --version).
# =============================================================================
set -euo pipefail

# --- Config ---------------------------------------------------------------
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$PKG_DIR/backup"
CONFIG_DEST="$HOME/.config/opencode"
LEGACY_DEST="$HOME/.opencode"
BIN_DEST="$LEGACY_DEST/bin"
PROJ_SRC="$BACKUP_DIR/projeto-concurso/.opencode"
VERSION_TARGET="1.18.15"

DRY=false
COM_PROJETO=false
SKIP_BINARY=false
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=true ;;
    --com-projeto) COM_PROJETO=true ;;
    --skip-binary) SKIP_BINARY=true ;;
    *) echo "Aviso: argumento desconhecido '$a' ignorado." ;;
  esac
done

say()  { printf '\033[1;36m[instalar]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[aviso]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
run()  { if $DRY; then say "(dry-run) $*"; else "$@"; fi; }

# --- Pré-requisitos -------------------------------------------------------
check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then ok "$1 encontrado: $($1 --version 2>&1 | head -1)"; else
    warn "$1 NÃO encontrado. Necessário: $2"; return 1; fi
}
need_node=false; need_pipx=false
command -v node  >/dev/null 2>&1 || need_node=true
command -v pipx  >/dev/null 2>&1 || need_pipx=true
check_cmd curl  "curl (instalação do opencode)"
if $need_node; then warn "node/npm não encontrado — o MCP gitnexus (via npx) não funcionará sem ele."; else ok "node: $(node --version 2>&1)"; fi
if $need_pipx; then warn "pipx não encontrado — a skill graphify não poderá ser instalada. (python3 -m pip install --user pipx)"; else ok "pipx: $(pipx --version 2>&1)"; fi

echo
say "Diretório do pacote: $PKG_DIR"
say "Destino config global: $CONFIG_DEST"
if $DRY; then echo; warn "MODO DRY-RUN — nada será alterado."; echo; fi

# --- Passo 1: binário opencode ---------------------------------------------
if ! $SKIP_BINARY; then
  echo
  say "Passo 1/5 — binário opencode"
  if command -v opencode >/dev/null 2>&1; then
    cur=$(opencode --version 2>/dev/null | head -1)
    ok "opencode já instalado: $cur (target do pacote: $VERSION_TARGET). Use --skip-binary para não tocar."
  else
    say "Instalando opencode via script oficial (target: $VERSION_TARGET)..."
    run bash -c "curl -fsSL https://opencode.ai/install | bash"
    run bash -lc "export PATH=\"$BIN_DEST:\$PATH\"; opencode --version"
  fi
fi

# --- Passo 2: config global -------------------------------------------------
echo
say "Passo 2/5 — config global (~/.config/opencode)"
run mkdir -p "$CONFIG_DEST/agent" "$CONFIG_DEST/skills"
if [ -f "$CONFIG_DEST/opencode.json" ] && ! $DRY; then
  warn "Já existe $CONFIG_DEST/opencode.json — salvando backup em opencode.json.pre-package.$(date +%Y%m%d%H%M%S)"
  run cp "$CONFIG_DEST/opencode.json" "$CONFIG_DEST/opencode.json.pre-package.$(date +%Y%m%d%H%M%S)"
fi
run cp "$BACKUP_DIR/config-global/opencode.json"        "$CONFIG_DEST/"
run cp "$BACKUP_DIR/config-global/opencode.jsonc"       "$CONFIG_DEST/"
run cp "$BACKUP_DIR/config-global/opencode.json.bak"    "$CONFIG_DEST/" || true
run cp "$BACKUP_DIR/config-global/agent/"*.md           "$CONFIG_DEST/agent/"
run cp -r "$BACKUP_DIR/config-global/skills/"*          "$CONFIG_DEST/skills/"

# --- Passo 3: legado ~/.opencode (plugin graphify + PATH) --------------------
echo
say "Passo 3/5 — legado ~/.opencode (plugin graphify + PATH)"
run mkdir -p "$LEGACY_DEST/plugins"
run cp "$BACKUP_DIR/legacy-opencode/opencode.json"      "$LEGACY_DEST/"
run cp "$BACKUP_DIR/legacy-opencode/plugins/graphify.js" "$LEGACY_DEST/plugins/"
if ! grep -q "$BIN_DEST" "$HOME/.bashrc" 2>/dev/null; then
  say "Adicionando PATH do opencode no ~/.bashrc"
  if $DRY; then say "(dry-run) echo 'export PATH=$BIN_DEST:\$PATH' >> ~/.bashrc"; else
    printf '\n# opencode\nexport PATH=%s:$PATH\n' "$BIN_DEST" >> "$HOME/.bashrc"
  fi
else
  ok "PATH do opencode já está no ~/.bashrc"
fi

# --- Passo 4: skills externas (graphify via pipx) -----------------------------
echo
say "Passo 4/5 — skills externas (graphify via pipx)"
if command -v pipx >/dev/null 2>&1; then
  if command -v graphify >/dev/null 2>&1; then
    ok "graphify já instalado ($(graphify --version 2>&1 | head -1))"
  else
    say "Instalando graphifyy (expõe graphify + graphify-mcp)..."
    run pipx install graphifyy
  fi
else
  warn "pipx ausente — pule a skill graphify. Instale depois: python3 -m pip install --user pipx && pipx install graphifyy"
fi

# --- Passo 5: segredos / placeholders -----------------------------------------
echo
say "Passo 5/5 — placeholders de segredos"
apply_placeholder() {
  local file="$1" placeholder="$2" envvar="$3"
  [ -f "$file" ] || return 0
  if grep -q "$placeholder" "$file"; then
    if [ -n "${!envvar:-}" ]; then
      run sed -i "s|$placeholder|${!envvar}|g" "$file"
      ok "$envvar aplicado em $(basename "$file")"
    else
      warn "placeholder $placeholder ainda presente em $(basename "$file") — preencha manualmente ou exporte $envvar."
    fi
  fi
}
apply_placeholder "$CONFIG_DEST/opencode.jsonc" "SEU_CONTEXT7_API_KEY"  "OPENCODE_CONTEXT7_API_KEY"
apply_placeholder "$CONFIG_DEST/opencode.jsonc" "SEU_GITHUB_TOKEN"      "OPENCODE_GITHUB_TOKEN"
apply_placeholder "$CONFIG_DEST/opencode.jsonc" "SUA_OPENAI_API_KEY"    "OPENCODE_OPENAI_API_KEY"
apply_placeholder "$CONFIG_DEST/opencode.json"  "SUA_CHAVE_9ROUTER"     "OPENCODE_9ROUTER_KEY"

# --- Opcional: projeto concurso ----------------------------------------------
if $COM_PROJETO; then
  echo
  say "Extra — .opencode/ do projeto Rio Verde Concurso"
  if [ -d "$PROJ_SRC" ]; then
    warn "Copiando para o diretório atual. Para copiar para outro projeto, use o script aplicar-projeto.sh"
    run cp -r "$PROJ_SRC/." ./.opencode/
  else
    warn "backup/projeto-concurso/.opencode não encontrado."
  fi
fi

# --- Validação ----------------------------------------------------------------
echo
say "Validação final"
if $DRY; then
  ok "dry-run concluído — execute ./install.sh sem --dry-run para aplicar."
else
  if command -v opencode >/dev/null 2>&1; then
    ok "opencode: $(opencode --version 2>&1 | head -1)"
  else
    warn "opencode não está no PATH. Recarregue o shell (source ~/.bashrc) e confirme."
  fi
  say "Agentes instalados em ~/.config/opencode/agent: $(ls "$CONFIG_DEST/agent"/*.md 2>/dev/null | wc -l)"
  say "Skills instaladas em ~/.config/opencode/skills: $(ls "$CONFIG_DEST/skills" 2>/dev/null | wc -l)"
  echo
  ok "Instalação concluída. Reinicie o opencode para carregar a nova config."
  warn "Se aplicou placeholders pendentes, edite ~/.config/opencode/opencode.jsonc e opencode.json antes de usar."
  warn "Refaça o login de autenticação: opencode auth login"
fi
