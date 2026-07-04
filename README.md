# 🌍 Statusline Polyglotte

**Apprenez une langue pendant que Claude Code travaille.**

Des micro-doses de vocabulaire s'affichent dans la statusline de [Claude Code](https://claude.com/claude-code) — une nouvelle carte toutes les 30 secondes, pendant que l'IA réfléchit, code, ou compile.

```
🇭🇷 Trebam pomoć = J'ai besoin d'aide  [trébame pomotch]
🇵🇫 'Aita e pe'ape'a = Pas de problème  [aïta é péapéa]
```

100 % local, zéro dépendance externe, zéro pub, zéro tracking. Juste bash + python3 (préinstallés sur macOS).

## Decks inclus

| Deck | Langue | Contenu |
|------|--------|---------|
| `deck-hr.json` 🇭🇷 | Croate | 193 entrées — bases, vie quotidienne, admin/expatriation, phrases utiles |
| `deck-ty.json` 🇵🇫 | Reo tahiti | 86 entrées — vocabulaire du fenua, chiffres, phrases courantes |

Chaque entrée : mot ou phrase, traduction française, prononciation phonétique FR.

## Installation

```bash
git clone https://github.com/alantouchard/statusline-polyglotte.git
cd statusline-polyglotte
./install.sh
```

L'installeur copie les fichiers dans `~/.claude/polyglotte/` et vous propose d'ajouter le bloc `statusLine` à votre `~/.claude/settings.json` (avec sauvegarde `.bak`). Redémarrez ensuite Claude Code.

### Installation manuelle

1. Copiez `statusline-polyglotte.sh` et les decks dans `~/.claude/polyglotte/`
2. Ajoutez dans `~/.claude/settings.json` :

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/polyglotte/statusline-polyglotte.sh"
}
```

3. Redémarrez Claude Code

## Personnalisation

**N'apprendre qu'une langue** — désactivez un deck en le renommant :

```bash
mv ~/.claude/polyglotte/deck-ty.json ~/.claude/polyglotte/deck-ty.json.off
```

**Créer votre propre deck** — n'importe quelle langue, format `deck-xx.json` :

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

**Changer le rythme** — éditez le `30` dans `statusline-polyglotte.sh` (ligne `slot = int(time.time()) // 30`) : c'est la durée d'affichage d'une carte en secondes.

**Dossier des decks** — par défaut `~/.claude/polyglotte`, surchargeable via la variable d'environnement `POLYGLOTTE_DIR`.

## Comment ça marche

- La statusline de Claude Code exécute le script à chaque rafraîchissement
- Le script découpe le temps en slots de 30 s et alterne entre les decks actifs (round-robin)
- Le parcours des cartes est pseudo-aléatoire mais déterministe (multiplication par un nombre premier) : pas de répétition immédiate, et la même carte reste affichée pendant tout son slot
- Mix progressif : 3 mots pour 1 phrase

## Contribuer

Les decks sont de simples fichiers JSON — les PRs pour corriger une prononciation ou ajouter un deck dans une nouvelle langue sont bienvenues. Māuruuru ! 🙏

## Licence

MIT — voir [LICENSE](LICENSE).

---

*Inspiré du concept de micro-learning dans les temps d'attente, façon spinner ads — mais en version saine : local, privé, gratuit.*
