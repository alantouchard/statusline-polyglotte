#!/bin/bash
# Installe Statusline Polyglotte pour Claude Code (macOS / Linux)
# Usage : ./install.sh
set -e

TARGET="$HOME/.claude/polyglotte"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "📦 Installation de Statusline Polyglotte…"
mkdir -p "$TARGET"
cp "$REPO_DIR/statusline-polyglotte.sh" "$TARGET/"
chmod +x "$TARGET/statusline-polyglotte.sh"
cp "$REPO_DIR/decks/"deck-*.json "$TARGET/"
cp "$REPO_DIR/decks/kbd.json" "$TARGET/"

echo "✅ Fichiers installés dans $TARGET"
echo ""
echo "Decks installés :"
ls "$TARGET"/deck-*.json "$TARGET"/kbd.json | sed 's/^/  - /'
echo ""
echo "👉 Pour n'apprendre qu'une seule langue, désactivez les autres decks :"
echo "   mv $TARGET/deck-ty.json $TARGET/deck-ty.json.off"
echo "👉 Pour désactiver la ligne 2 (raccourcis clavier) :"
echo "   mv $TARGET/kbd.json $TARGET/kbd.json.off"
echo ""
echo "Dernière étape — ajoutez ce bloc dans ~/.claude/settings.json :"
echo ""
cat <<'JSON'
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/polyglotte/statusline-polyglotte.sh"
  }
JSON
echo ""
read -r -p "Voulez-vous que je l'ajoute automatiquement à ~/.claude/settings.json ? [o/N] " answer
if [ "$answer" = "o" ] || [ "$answer" = "O" ] || [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    python3 - <<'PY'
import json, os, shutil

path = os.path.expanduser("~/.claude/settings.json")
settings = {}
if os.path.exists(path):
    shutil.copy(path, path + ".bak")
    with open(path) as f:
        settings = json.load(f)
    print(f"(sauvegarde créée : {path}.bak)")

if "statusLine" in settings:
    print("⚠️  Un bloc statusLine existe déjà — je ne l'écrase pas.")
    print("   Remplacez-le manuellement si vous voulez utiliser Polyglotte.")
else:
    settings["statusLine"] = {
        "type": "command",
        "command": "bash ~/.claude/polyglotte/statusline-polyglotte.sh",
    }
    with open(path, "w") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
    print("✅ settings.json mis à jour.")
PY
fi
echo ""
echo "🔁 Redémarrez Claude Code pour activer. Sretno! Manuia! 🎉"
