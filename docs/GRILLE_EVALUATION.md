# Grille d'évaluation

Chaque exercice est noté sur 20. La même grille s'applique aux deux parties ; seul le critère 4 change de contenu.

| Critère | Points | Sources |
| --- | --- | --- |
| 1. Fonctionnel | 8 | Critères d'acceptation de l'énoncé, rejoués après `./outils/reinit-db.sh` |
| 2. Qualité et conformité au cours | 5 | Relecture du code, tests |
| 3. Pratique Git | 4 | `outils/analyse-git.sh`, demande de fusion |
| 4. RENDU et usage de l'IA | 3 | `RENDU.md`, `JOURNAL_IA.md` |

## 1. Fonctionnel (8 points)

Points répartis à parts égales entre les critères d'acceptation de l'énoncé. Un critère est acquis s'il est vérifiable en suivant la section « Comment vérifier mon travail » du RENDU.

## 2. Qualité et conformité au cours (5 points)

| Niveau | Description |
| --- | --- |
| 5 | Contrôleur mince, transaction dans le service, calculs ensemblistes en base, aucun calcul dans les GSP, libellés externalisés, tests pertinents qui passent, code lisible et nommé en français cohérent |
| 3–4 | Un ou deux écarts mineurs (libellé en dur, requête dans une boucle de vue corrigeable, test manquant) |
| 1–2 | Écarts de conception : logique dans le contrôleur, `save()` sans contrôle, `START TRANSACTION` dans une procédure, calcul Groovy de ce que la base doit calculer |
| 0 | Ne compile pas, ou ne respecte pas l'architecture A2 |

Points de relecture rapide : `dbCreate` resté à `none` ; `grails.gorm.transactions.Transactional` ; `belongsTo` réservé à la composition ; flush avant et refresh après un appel de procédure ; `version + 1` dans les `UPDATE` des procédures ; liste blanche du tri ; `max` borné.

## 3. Pratique Git (4 points)

| Niveau | Description |
| --- | --- |
| 4 | Au moins 5 commits ; chacun une intention, message conforme, corps qui explique le pourquoi ; aucun commit géant non justifié ; travail réparti sur plusieurs séances ; demande de fusion remplie honnêtement |
| 3 | Bon historique, quelques messages pauvres ou un commit trop gros |
| 2 | Peu de commits, ou commits fourre-tout (« modifs », « wip ») |
| 0–1 | Un seul commit, historique réécrit après ouverture de la demande, ou travail sur la mauvaise branche |

Indicateurs produits par `outils/analyse-git.sh` : nombre de commits, taux de messages conformes, taux de messages avec corps, plus gros commit, nombre de commits de plus de 300 lignes, nombre de jours de travail, part des commits faits dans les 24 dernières heures, présence des fichiers de rendu, trailers `Assisted-by`. Ce sont des **indices pour la relecture**, pas une note automatique.

## 4. RENDU et usage de l'IA (3 points)

### Partie SANS IA (ex01 à ex04)

| Niveau | Description |
| --- | --- |
| 3 | Choix justifiés (tableau de décision rempli), difficultés décrites, déclaration IA précise et cohérente avec l'historique |
| 2 | RENDU complet mais justifications superficielles |
| 1 | RENDU minimal |
| 0 | RENDU absent, ou usage de l'IA non déclaré et constaté en entretien |

Un usage déclaré de l'IA dans cette partie **n'est pas pénalisé** au titre de ce critère : il est discuté. Seule l'omission l'est.

### Partie AVEC IA (ex05 à ex08)

| Niveau | Description |
| --- | --- |
| 3 | Outils et configuration décrits et justifiés, prompts copiés tels quels, décisions argumentées (accepté, corrigé, rejeté), au moins une erreur de l'IA détectée par une vérification explicite, bilan lucide |
| 2 | Journal complet mais peu critique : l'IA est suivie sans vérification visible |
| 1 | Journal reconstitué après coup, prompts résumés au lieu d'être copiés |
| 0 | Journal absent |

## Points d'attention pour l'entretien de restitution

Ces signaux justifient une question, **jamais une sanction à eux seuls** :

- plusieurs centaines de lignes en un seul commit, juste avant l'échéance ;
- un style de code ou de commentaires très différent d'un exercice à l'autre de la même partie ;
- dans la partie sans IA, des constructions absentes du cours, sans explication dans le RENDU ;
- dans la partie avec IA, aucun trailer `Assisted-by` alors que le journal décrit un usage intensif.

Une question simple tranche presque toujours : « Montrez-moi comment vous modifieriez cette méthode pour … ».
