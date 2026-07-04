# 🌍 Statusline Polyglotte

**Apprenez une langue (et vos raccourcis clavier) pendant que Claude Code travaille.**

Des micro-doses de vocabulaire s'affichent dans la statusline de [Claude Code](https://claude.com/claude-code) — une nouvelle carte toutes les 30 secondes, pendant que l'IA réfléchit, code, ou compile. Depuis la v2, un système de **répétition espacée** (boîtes de Leitner) fait revenir les cartes au bon moment : souvent au début, de moins en moins à mesure que vous les connaissez.

```
🇭🇷 🆕 Trebam pomoć = J'ai besoin d'aide  [trébame pomotch]
⌨️ ⌘⇧Entrée = zoomer/dézoomer le split actif  · Ghostty
```

100 % local, zéro dépendance externe, zéro pub, zéro tracking. Juste bash + python3 (préinstallés sur macOS).

## Decks inclus

| Deck | Contenu |
|------|---------|
| `deck-hr.json` 🇭🇷 | Croate — 276 entrées : bases, vie quotidienne, nourriture, directions, banque, admin/expatriation, conversation |
| `deck-ty.json` 🇵🇫 | Reo tahiti — 86 entrées : vocabulaire du fenua, chiffres, phrases courantes |
| `kbd.json` ⌨️ | 62 raccourcis clavier macOS, Finder, Ghostty, terminal, Claude Code — affichés en ligne 2 |

Chaque entrée langue : mot ou phrase, traduction française, prononciation phonétique FR.

## Installation

```bash
git clone https://github.com/alantouchard/statusline-polyglotte.git
cd statusline-polyglotte
./install.sh
```

L'installeur copie les fichiers dans `~/.claude/polyglotte/` et vous propose d'ajouter le bloc `statusLine` à votre `~/.claude/settings.json` (avec sauvegarde `.bak`). Redémarrez ensuite Claude Code.

### Installation manuelle

1. Copiez `statusline-polyglotte.sh` et les decks (`decks/*.json`) dans `~/.claude/polyglotte/`
2. Ajoutez dans `~/.claude/settings.json` :

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/polyglotte/statusline-polyglotte.sh"
}
```

3. Redémarrez Claude Code

## Répétition espacée (v2)

Chaque carte progresse dans 5 boîtes de Leitner selon le nombre de fois où vous l'avez vue :

| Boîte | Statut | Revient après |
|-------|--------|---------------|
| 0 | nouvelle (🆕) | 2 min |
| 1 | en apprentissage | 8 min |
| 2 | connue | 30 min |
| 3 | acquise | 2 h |
| 4 | maîtrisée | 12 h |

- Les nouvelles cartes sont introduites progressivement (au plus 1 slot sur 3, et jamais plus de 25 cartes en apprentissage simultané)
- La progression est stockée dans `~/.claude/polyglotte/state.json` — supprimez-le pour repartir de zéro
- Suivez votre progression :

```bash
bash ~/.claude/polyglotte/statusline-polyglotte.sh --stats
# 🇭🇷 deck-hr  : 84/276 vues · 12 acquises (boîte 3+) · 19 en apprentissage
# ⌨️ raccourcis : 31/62 vues · 5 acquises (boîte 3+) · 8 en apprentissage
```

## Personnalisation

**N'apprendre qu'une langue** — désactivez un deck en le renommant :

```bash
mv ~/.claude/polyglotte/deck-ty.json ~/.claude/polyglotte/deck-ty.json.off
```

**Désactiver la ligne raccourcis clavier** :

```bash
mv ~/.claude/polyglotte/kbd.json ~/.claude/polyglotte/kbd.json.off
```

**Créer votre propre deck langue** — n'importe quelle langue, format `deck-xx.json` :

```json
{
  "lang": "es",
  "name": "Espagnol — mon deck",
  "version": 1,
  "flag": "🇪🇸",
  "entries": [
    { "es": "hola", "fr": "salut", "pron": "ola", "level": 1 },
    { "es": "¿Qué tal?", "fr": "Ça va ?", "pron": "ké tal", "level": 2 }
  ]
}
```

- La clé du mot dans chaque entrée = la valeur de `lang`
- `level: 1` = mot isolé, `level: 2` = phrase (affichée 1 fois sur 4)
- Astuce : demandez à Claude de vous générer un deck 😉

**Personnaliser les raccourcis** — `kbd.json` suit le même principe :

```json
{
  "name": "Raccourcis clavier",
  "icon": "⌨️",
  "entries": [
    { "k": "⌘ Espace", "fr": "Spotlight", "app": "macOS", "level": 1 }
  ]
}
```

**Changer le rythme** — remplacez les `30` dans `statusline-polyglotte.sh` (calcul des slots) : c'est la durée d'affichage d'une carte en secondes.

**Dossier des decks** — par défaut `~/.claude/polyglotte`, surchargeable via la variable d'environnement `POLYGLOTTE_DIR`.

## Comment ça marche

- La statusline de Claude Code exécute le script à chaque rafraîchissement
- Le script découpe le temps en slots de 30 s et alterne entre les decks langues actifs (round-robin) ; la ligne raccourcis a son propre slot, décalé de 15 s
- À chaque slot, la répétition espacée choisit : une carte **due** (la plus en retard d'abord), sinon une **nouvelle** carte (parcours pseudo-aléatoire déterministe), sinon la carte la plus proche d'être due
- La même carte reste affichée pendant tout son slot, sans compter de vue supplémentaire
- Mix progressif : 3 mots pour 1 phrase

## Contribuer

Les decks sont de simples fichiers JSON — les PRs pour corriger une prononciation ou ajouter un deck dans une nouvelle langue sont bienvenues. Māuruuru ! 🙏

## Licence

MIT — voir [LICENSE](LICENSE).

---

*Inspiré du concept de micro-learning dans les temps d'attente, façon spinner ads — mais en version saine : local, privé, gratuit.*
