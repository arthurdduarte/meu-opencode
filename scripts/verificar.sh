#!/usr/bin/env bash
# =============================================================================
# verificar.sh — Checa se a instalação do pacote "Meu-opencode" está consistente.
# Uso: ./verificar.sh [--projeto /caminho/do/repo]
# =============================================================================
set -uo pipefail

PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config/opencode"
LEGACY="$HOME/.opencode"
PASS=0; FAIL=0

chk() { # chk <ok-msg> <fail-msg> <cond...>
  if eval "${@:3}"; then echo "  [OK]   $1"; PASS=$((PASS+1)); else
    echo "  [FALHA] $2"; FAIL=$((FAIL+1)); fi
}

echo "== Verificação do pacote Meu-opencode =="

echo "-- Binário opencode --"
chk "binário presente e executável" "opencode ausente no PATH" \
  'command -v opencode >/dev/null 2>&1'
chk "versão compatível (>=1.18)" "versão abaixo do alvo 1.18.15" \
  '[[ "$(opencode --version 2>/dev/null)" =~ 1\.1[89] ]]'

echo "-- Config global ($CONFIG) --"
chk "opencode.json presente" "faltando opencode.json" \
  '[ -f "$CONFIG/opencode.json" ]'
chk "opencode.jsonc presente" "faltando opencode.jsonc" \
  '[ -f "$CONFIG/opencode.jsonc" ]'
chk "MCP gitnexus habilitado" "gitnexus não habilitado ou ausente" \
  'grep -q "gitnexus" "$CONFIG/opencode.jsonc"'

echo "-- Agentes globais --"
n_agent=$(ls "$CONFIG"/agent/*.md 2>/dev/null | wc -l)
chk "$n_agent agentes instalados (esperado 27)" "agentes ausentes" \
  '[ "$n_agent" -ge 20 ]'
chk "jarvis-* presente" "faltando agentes jarvis" \
  'ls "$CONFIG"/agent/jarvis-*.md >/dev/null 2>&1'
chk "manas-* presente" "faltando agentes manas" \
  'ls "$CONFIG"/agent/manas-*.md >/dev/null 2>&1'
chk "sec-* presente" "faltando agentes sec" \
  'ls "$CONFIG"/agent/sec-*.md >/dev/null 2>&1'

echo "-- Skills globais --"
for skill in graphify jarvis-web-team manas-ciel sec-audit-team; do
  chk "skill $skill presente" "faltando skill $skill" \
    '[ -f "$CONFIG/skills/'"$skill"'/SKILL.md" ]'
done

echo "-- Legado ~/.opencode --"
chk "plugin graphify.js presente" "faltando plugins/graphify.js" \
  '[ -f "$LEGACY/plugins/graphify.js" ]'
chk "opencode.json (legado) registra plugin" "legado sem plugin registrado" \
  'grep -q "graphify" "$LEGACY/opencode.json" 2>/dev/null'
chk "PATH do opencode no ~/.bashrc" "PATH não adicionado ao bashrc" \
  'grep -q "opencode/bin" "$HOME/.bashrc" 2>/dev/null'

echo "-- Dependências externas --"
chk "node disponível" "node ausente (MCP gitnexus depende de npx)" \
  'command -v node >/dev/null 2>&1'
chk "graphify disponível" "graphify ausente (pipx install graphifyy)" \
  'command -v graphify >/dev/null 2>&1'

echo "-- Segredos (não devem vazar placeholder sem valor) --"
for ph in SEU_CONTEXT7_API_KEY SEU_GITHUB_TOKEN SUA_OPENAI_API_KEY SUA_CHAVE_9ROUTER; do
  if grep -rq "$ph" "$CONFIG" 2>/dev/null; then
    echo "  [AVISO] placeholder $ph ainda presente — preencha em $CONFIG"
  fi
done

echo
echo "Resultado: $PASS ok, $FAIL falhas."
[ "$FAIL" -eq 0 ] && echo "Pacote aplicado corretamente." || echo "Há itens para revisar."
exit "$FAIL"
