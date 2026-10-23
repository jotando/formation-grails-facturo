# Matrice de couverture des notions

Cinq couches de l'architecture A2, quatre notions fondamentales chacune. ● = notion évaluée dans l'exercice, ○ = notion réutilisée.

| Couche | Code | Notion | ex01 | ex02 | ex03 | ex04 | ex05 | ex06 | ex07 | ex08 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GSP | G1 | Layout SiteMesh, `<meta name="layout">` | ● | ○ | ○ | ○ | ○ | ○ | ○ | ● |
| GSP | G2 | Tags `g:` : `each`, `if`, `link`, `form`, `field`, `select`, `paginate` | ● | ● | ○ | ○ | ● | ● | ○ | ○ |
| GSP | G3 | Templates `_x.gsp` et `g:render` | | ● | ● | ○ | ○ | ○ | ● | ● |
| GSP | G4 | TagLib personnalisée | | | | | | | ● | ● |
| Contrôleur | C1 | Conventions d'URL et `UrlMappings` | ● | ○ | ○ | | | ● | ○ | ● |
| Contrôleur | C2 | Liaison des paramètres, command objects | | ● | ○ | | ○ | ● | | ● |
| Contrôleur | C3 | Réponses : `render`, `redirect`, `flash`, statut HTTP | ● | ● | ● | | ● | ○ | ○ | ○ |
| Contrôleur | C4 | Intercepteurs | | | | | | | ● | ○ |
| Service | S1 | Injection par nom, Data Service | | ● | ○ | | ○ | ○ | ○ | ● |
| Service | S2 | Transactions `@Transactional`, `readOnly` | | | ● | | ● | ○ | | ● |
| Service | S3 | Exceptions métier et rollback | | | ● | | ● | | ○ | ○ |
| Service | S4 | Tests unitaires Spock | | ● | ● | | | ● | ○ | ● |
| GORM | O1 | Mapping d'une domain class sur une table existante | ● | | ● | ● | | ○ | ● | ○ |
| GORM | O2 | Contraintes et validation, validateur personnalisé | | ● | ○ | | | ○ | | ○ |
| GORM | O3 | Associations : référence, `hasMany`, `belongsTo`, chargement | ● | | ● | | | | | ○ |
| GORM | O4 | Requêtes : finders, `where`, criteria, pagination | ● | ○ | ○ | ● | | ● | ○ | ● |
| MariaDB | B1 | Fonctions | | | | ● | | | | ● |
| MariaDB | B2 | Vues et domain class en lecture seule | | | | ● | | ● | | ● |
| MariaDB | B3 | Procédures stockées participantes, `SIGNAL`, `Sql.call` | | | | | ● | | ○ | ● |
| MariaDB | B4 | Triggers et contraintes déclaratives | | | | | | | ● | ○ |
| — | I | Mise en commun des couches, arbre de décision | | | | | | | | ● |

## Lecture

- Chaque notion est évaluée (●) au moins une fois. G4, C4, B3 et B4 ne le sont que dans la partie AVEC IA.
- Si vous voulez observer les procédures stockées **sans** IA, permutez les exercices 4 et 5 : l'exercice 5 n'utilise pas les objets de l'exercice 4. L'exercice 6 a alors besoin de la vue de l'exercice 4, à faire en premier dans la partie AVEC IA.
- La comparaison « même notion, avec et sans IA » est directe pour O4 (ex01 / ex06), C3 (ex02 / ex05), S2 et S3 (ex03 / ex05), B2 (ex04 / ex06).
