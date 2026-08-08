#!/usr/bin/env bash
# =============================================================================
# aplicar-projeto.sh — Restaura o .opencode/ específico do projeto concurso
# (agentes revisor-*, commands corrigir-dia*, prompts fase2-v2*, skills openspec-*)
# dentro de um repositório alvo.
#
# Uso:
#   ./aplicar-projeto.sh /caminho/para/Projeto-Concurso-RioVerde2026
#   ./aplicar-projeto.sh            # usa o diretório atual
#   ./aplicar-projeto.sh --dry-run /caminho
# =============================================================================
set -euo pipefail

PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_SRC="$PKG_DIR/backup/projeto-concurso/.opencode"
DRY=false
[ "${1:-}" = "--dry-run" ] && { DRY=true; shift; }

TARGET="${1:-$PWD}"

if [ ! -d "$PROJ_SRC" ]; then
  echo "Erro: backup/projeto-concurso/.opencode não encontrado no pacote."
  exit 1
fi
if [ ! -d "$TARGET" ]; then
  echo "Erro: alvo '$TARGET' não é um diretório."
  exit 1
fi

echo "Pacote  : $PKG_DIR"
echo "Origem  : $PROJ_SRC"
echo "Alvo    : $TARGET/.opencode"
$DRY && { echo "MODO DRY-RUN — nada será copiado."; }

mkdir -p "$TARGET/.opencode"
if ! $DRY; then
  cp -r "$PROJ_SRC/." "$TARGET/.opencode/"
  echo "OK — .opencode/ restaurado em $TARGET/.opencode"
else
  echo "(dry-run) cp -r '$PROJ_SRC/.' '$TARGET/.opencode/'"
fi
