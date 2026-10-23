# Règles de travail sur le dépôt

Ces règles font partie de l'évaluation : l'historique Git est lu comme le journal de votre démarche.

## 1. Mise en place (une fois)

```bash
git clone <url-du-depot> facturo && cd facturo
git config core.hooksPath .githooks      # contrôle du format des messages
git config commit.template .gitmessage   # gabarit affiché à chaque commit
git switch -c etu-<login>                # votre branche d'intégration, créée depuis main
git push -u origin etu-<login>
```

`<login>` : votre identifiant en minuscules, sans espace ni accent (ex. `jdupont`).

## 2. Une branche par exercice

```text
main ──● (code de référence, ne jamais committer dessus)
        \
         etu-jdupont ──────────●──────────●────── …   (intégration : reçoit les exercices terminés)
                      \        /\        /
                       ●──●──●   ●──●──●
                  jdupont/ex01-…   jdupont/ex02-…
```

1. Partir de votre branche d'intégration à jour : `git switch etu-<login> && git pull`.
2. Créer la branche de l'exercice : `git switch -c <login>/ex01-fournisseurs` (noms dans chaque énoncé).
3. Travailler par petits commits, pousser régulièrement : `git push -u origin <login>/ex01-fournisseurs`.
4. Rendre : ouvrir une *pull request* (GitHub) ou *merge request* (GitLab) de `<login>/exNN-…` **vers `etu-<login>`**, en remplissant le modèle. Ne pas fusionner vous-même.
5. Après relecture, l'enseignant fusionne **sans squash** et pose le tag `rendu/<login>/exNN`.

Ne réécrivez pas l'historique d'une branche déjà poussée (`push --force` interdit après ouverture de la demande de fusion).

## 3. Messages de commit

Format *Conventional Commits*, vérifié par le hook :

```text
<type>(exNN): <description à l'infinitif, 10 à 72 caractères>

<corps : pourquoi, et quelle alternative a été écartée>

Assisted-by: <outil> (<modèle>)      ← seulement si une IA a contribué au commit
```

| Type | Usage |
| --- | --- |
| `feat` | nouvelle fonctionnalité |
| `fix` | correction |
| `refactor` | restructuration sans changement de comportement |
| `test` | ajout ou modification de tests (Spock ou SQL) |
| `docs` | RENDU.md, JOURNAL_IA.md, commentaires |
| `chore`, `build`, `style`, `perf` | le reste |

Attendus mesurés par `outils/analyse-git.sh` :

- au moins 5 commits par exercice, chacun avec une intention unique ;
- chaque commit compile (`./gradlew compileGroovy`) ;
- pas de commit de plus de 300 lignes modifiées, sauf fichier généré ou déplacé (à justifier dans le corps) ;
- un corps de message pour tout commit non trivial ;
- des commits répartis dans le temps, pas tous la veille de l'échéance.

## 4. Usage de l'IA

| Exercices | Règle | À fournir |
| --- | --- | --- |
| ex01 à ex04 | **Sans IA** : ni génération de code, ni complétion IA dans l'IDE, ni assistant en ligne ou hors ligne. Documentation, cours, forums : autorisés. | `rendus/<login>/exNN/RENDU.md` avec la déclaration d'usage. **Tout usage, même ponctuel, doit être déclaré** : il n'est pas sanctionné en soi, une omission l'est. |
| ex05 à ex08 | **Avec IA** : obligatoire et documenté. | `RENDU.md` + `JOURNAL_IA.md` : outils et configuration, prompts écrits, ce qui a été accepté, corrigé ou rejeté, et pourquoi. Trailer `Assisted-by:` sur chaque commit concerné. |

Désactivez la complétion IA de votre IDE pendant la partie sans IA (Copilot, JetBrains AI Assistant, Codeium, Cursor Tab…), et indiquez-le dans le RENDU.

## 5. Ce qui ne doit jamais être committé

Mots de passe, clés d'API, jetons, fichiers `.env`, configuration d'outil IA contenant une clé. Le dossier `rendus/<login>/exNN/config-ia/` reçoit des copies **expurgées**.
