#!/bin/bash
# Statusline Polyglotte — micro-doses de langues pendant que Claude Code travaille
#
# Decks actifs : $POLYGLOTTE_DIR/deck-*.json (défaut : ~/.claude/polyglotte)
# Désactiver un deck sans le supprimer : le renommer en deck-xx.json.off
# Rotation : nouvelle carte toutes les 30 s, alternance entre decks actifs ;
#            1 slot sur 4 = phrase (level 2), le reste = mots (level 1)

DIR="${POLYGLOTTE_DIR:-$HOME/.claude/polyglotte}"
ls "$DIR"/deck-*.json >/dev/null 2>&1 || exit 0

python3 - "$DIR" <<'PY' 2>/dev/null
import glob, json, os, sys, time

decks = []
for path in sorted(glob.glob(os.path.join(sys.argv[1], "deck-*.json"))):
    try:
        with open(path) as f:
            d = json.load(f)
        if d.get("entries"):
            decks.append(d)
    except Exception:
        pass
if not decks:
    sys.exit(0)

slot = int(time.time()) // 30
deck = decks[slot % len(decks)]
dslot = slot // len(decks)

lang = deck.get("lang", "hr")
flag = deck.get("flag", "\U0001F30D")
entries = deck["entries"]
words   = [e for e in entries if e.get("level", 1) == 1]
phrases = [e for e in entries if e.get("level", 1) >= 2]

# parcours pseudo-aléatoire déterministe (nombre premier) pour ne pas défiler dans l'ordre du fichier
if phrases and dslot % 4 == 3:
    e = phrases[(dslot * 7919) % len(phrases)]
elif words:
    e = words[(dslot * 7919) % len(words)]
else:
    e = entries[(dslot * 7919) % len(entries)]

print(f"{flag} {e[lang]} = {e['fr']}  [{e['pron']}]")
PY
