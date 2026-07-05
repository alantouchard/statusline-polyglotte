#!/bin/bash
# Statusline Polyglotte v2 — micro-doses de langues + raccourcis clavier, avec répétition espacée
#
# Ligne 1 : decks langues $POLYGLOTTE_DIR/deck-*.json (défaut : ~/.claude/polyglotte)
# Ligne 2 : raccourcis clavier $POLYGLOTTE_DIR/kbd.json (optionnel)
# Désactiver un deck sans le supprimer : le renommer en .off
#
# SRS Leitner passif : state $POLYGLOTTE_DIR/state.json (boîtes 0-4, promotion par expositions)
# `statusline-polyglotte.sh --stats` : progression par deck

DIR="${POLYGLOTTE_DIR:-$HOME/.claude/polyglotte}"
[ -d "$DIR" ] || exit 0

python3 - "$DIR" "$1" <<'PY' 2>/dev/null
import glob, json, os, sys, time

DIR = sys.argv[1]
STATS = len(sys.argv) > 2 and sys.argv[2] == "--stats"
STATE_PATH = os.path.join(DIR, "state.json")

# Boîtes Leitner : promotion après N vues, intervalle de réapparition en slots de 30 s
PROMOTE_AT = [2, 5, 9, 14]            # vues cumulées pour passer en boîte 1,2,3,4
INTERVALS = [4, 16, 60, 240, 1440]    # boîte 0→4 : 2 min, 8 min, 30 min, 2 h, 12 h
MAX_LEARNING = 25                     # cartes max en boîtes 0-1 avant de bloquer les intros

RESET = "\033[0m"
DIM = "\033[2m"
# Couleur par boîte Leitner (0 = tout neuf → 4 = acquis) : rouge → orange → jaune → vert clair → vert
BOX_COLORS = ["\033[38;5;203m", "\033[38;5;215m", "\033[38;5;220m",
              "\033[38;5;149m", "\033[38;5;42m"]

def colorize(text, b):
    return BOX_COLORS[min(b, 4)] + text + RESET

def progress_bar(acquis, total, width=5):
    if total <= 0:
        return ""
    filled = int(round(acquis / total * width))
    bar = "▰" * filled + "▱" * (width - filled)
    return f"{DIM}{bar} {acquis}/{total}{RESET}"

def load_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except Exception:
        return None

def save_state(state):
    tmp = STATE_PATH + ".tmp"
    try:
        with open(tmp, "w") as f:
            json.dump(state, f, ensure_ascii=False)
        os.replace(tmp, STATE_PATH)
        os.chmod(STATE_PATH, 0o600)
    except Exception:
        pass

def pick(deck_id, entries, key_of, slot, state):
    """Choisit une carte par répétition espacée ; retourne (entrée, première_vue, state_modifié)."""
    ds = state.setdefault(deck_id, {"last": {}, "cards": {}})
    last, cards = ds["last"], ds["cards"]
    by_key = {key_of(e): e for e in entries}

    # même slot → réafficher la même carte, sans compter une vue de plus
    if last.get("slot") == slot and last.get("key") in by_key:
        b = cards.get(last["key"], {}).get("b", 0)
        return by_key[last["key"]], last.get("new", False), False, b

    # 1 slot sur 4 = phrase (level 2) si dispo
    phrases = [e for e in entries if e.get("level", 1) >= 2]
    words = [e for e in entries if e.get("level", 1) == 1]
    pool = phrases if (phrases and slot % 4 == 3) else (words or entries)

    seen = [(cards[key_of(e)], e) for e in pool if key_of(e) in cards]
    unseen = [e for e in pool if key_of(e) not in cards]
    due = sorted([(c, e) for c, e in seen if c["due"] <= slot], key=lambda t: t[0]["due"])
    learning = sum(1 for c in cards.values() if c["b"] <= 1)

    is_new = False
    if due and not (unseen and slot % 3 == 0 and learning < MAX_LEARNING):
        entry = due[0][1]                     # la plus en retard d'abord
    elif unseen and learning < MAX_LEARNING:
        entry = unseen[(slot * 7919) % len(unseen)]
        is_new = True
    elif seen:
        entry = min(seen, key=lambda t: t[0]["due"])[1]  # rien de dû : la plus proche de l'être
    else:
        entry = pool[(slot * 7919) % len(pool)]
        is_new = True

    k = key_of(entry)
    c = cards.setdefault(k, {"v": 0, "b": 0, "due": 0})
    c["v"] += 1
    while c["b"] < 4 and c["b"] < len(PROMOTE_AT) and c["v"] >= PROMOTE_AT[c["b"]]:
        c["b"] += 1
    c["due"] = slot + INTERVALS[c["b"]]
    ds["last"] = {"slot": slot, "key": k, "new": is_new}
    return entry, is_new, True, c["b"]

state = load_json(STATE_PATH) or {}
dirty = False
lines = []
slot = int(time.time()) // 30

# ligne 1 — decks langues, alternance round-robin
decks = []
for path in sorted(glob.glob(os.path.join(DIR, "deck-*.json"))):
    d = load_json(path)
    if d and d.get("entries"):
        d["_id"] = os.path.basename(path)[5:-5]  # deck-hr.json → hr
        decks.append(d)

if STATS:
    def report(deck_id, label, entries, key_of):
        cards = state.get(deck_id, {}).get("cards", {})
        ks = {key_of(e) for e in entries}
        vus = [c for k, c in cards.items() if k in ks]
        acquis = sum(1 for c in vus if c["b"] >= 3)
        encours = sum(1 for c in vus if c["b"] <= 1)
        print(f"{label} : {len(vus)}/{len(entries)} vues · {acquis} acquises (boîte 3+) · {encours} en apprentissage")
    for d in decks:
        lang = d.get("lang", "hr")
        report(d["_id"], f"{d.get('flag','')} deck-{d['_id']} ", d["entries"], lambda e, lang=lang: e[lang])
    kbd = load_json(os.path.join(DIR, "kbd.json"))
    if kbd and kbd.get("entries"):
        report("kbd", "⌨️ raccourcis", kbd["entries"], lambda e: e.get("app", "") + "|" + e["k"])
    sys.exit(0)

def count_acquired(deck_id, entries, key_of):
    cards = state.get(deck_id, {}).get("cards", {})
    ks = {key_of(e) for e in entries}
    return sum(1 for k, c in cards.items() if k in ks and c.get("b", 0) >= 3), len(entries)

if decks:
    deck = decks[slot % len(decks)]
    dslot = slot // len(decks)
    lang = deck.get("lang", "hr")
    e, is_new, dirty1, box = pick(deck["_id"], deck["entries"], lambda x: x[lang], dslot, state)
    dirty = dirty or dirty1
    tag = "🆕 " if is_new else ""
    acquis, total = count_acquired(deck["_id"], deck["entries"], lambda x: x[lang])
    bar = progress_bar(acquis, total)
    lines.append(f"{deck.get('flag', chr(0x1F30D))} {tag}{colorize(e[lang], box)} = {e['fr']}  [{e['pron']}]  {bar}")

# ligne 2 — raccourcis clavier, slot décalé de 15 s pour ne pas changer en même temps
kbd = load_json(os.path.join(DIR, "kbd.json"))
if kbd and kbd.get("entries"):
    kslot = (int(time.time()) + 15) // 30
    kkey = lambda x: x.get("app", "") + "|" + x["k"]
    e, is_new, dirty2, box = pick("kbd", kbd["entries"], kkey, kslot, state)
    dirty = dirty or dirty2
    tag = "🆕 " if is_new else ""
    acquis, total = count_acquired("kbd", kbd["entries"], kkey)
    bar = progress_bar(acquis, total)
    lines.append(f"{kbd.get('icon', chr(0x2328))} {tag}{colorize(e['k'], box)} = {e['fr']}  · {e.get('app', '')}  {bar}")

if dirty:
    save_state(state)
print("\n".join(lines))
PY
