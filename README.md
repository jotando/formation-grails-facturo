# Facturo — de Spring Boot à Grails 3.3

Projet fil rouge de la formation « de Spring Boot (Thymeleaf + Spring MVC + Spring Data) à Grails 3.3 (GSP + Groovy + GORM) sur MariaDB orientée calcul ».

- **Ventes** (clients, produits, factures) : code de référence des tutoriels, complet et testé.
- **Achats** (fournisseurs, commandes, réceptions) : tables présentes, **aucun code Grails**. C'est le terrain des 8 exercices.

## Prérequis

| Outil | Version | Installation conseillée |
| --- | --- | --- |
| JDK | 8 | `sdk install java 8.0.452-tem` ([SDKMAN](https://sdkman.io)) |
| Grails (facultatif, le wrapper suffit) | 3.3.11 | `sdk install grails 3.3.11` |
| Docker + Compose | récent | pour MariaDB 10.11 |
| IDE | IntelliJ IDEA conseillé | support Groovy et GSP |

## Démarrer

```bash
docker compose up -d                 # MariaDB 10.11 + exécution de src/main/sql/*.sql
./gradlew bootRun                    # http://localhost:8080
./gradlew check                      # tests Spock
./outils/tests-sql.sh                # tests des fonctions, vues, procédures et triggers
```

Après toute modification d'un script SQL : `./outils/reinit-db.sh` (recrée la base depuis les scripts).

Base : `jdbc:mariadb://localhost:3306/facturo`, utilisateur `facturo` / `facturo`. Surcharge possible par les variables `DB_URL`, `DB_USER`, `DB_PASSWORD`.

## Organisation

| Chemin | Contenu |
| --- | --- |
| `src/main/sql/00_schema.sql` | Tables ventes et achats, contraintes |
| `src/main/sql/01_routines_ventes.sql` | Fonctions, vue, procédures, triggers des tutoriels (modèles des exercices) |
| `src/main/sql/02_donnees.sql` | Jeu d'essai |
| `src/main/sql/2x_exNN_*.sql` | **Vos** scripts d'exercice |
| `src/test/sql/` | Tests SQL (modèle : `test_01_routines_ventes.sql`) |
| `grails-app/` | Application Grails (domain, controllers, services, taglib, views, i18n) |
| `src/test/groovy/` | Tests Spock |
| `docs/exercices/` | Les 8 énoncés |
| `docs/MATRICE_COUVERTURE.md` | Notions couvertes par exercice |
| `docs/GRILLE_EVALUATION.md` | Barème |
| `rendus/_modele/` | Modèles `RENDU.md` et `JOURNAL_IA.md` |
| `rendus/<login>/exNN/` | **Vos** rendus |
| `qcm/` | Banque de questions (JSON source, export Moodle GIFT) |
| `outils/` | Réinitialisation de la base, tests SQL, analyse Git, génération du QCM |

## Avant de commencer les exercices

Lire [`CONTRIBUTING.md`](CONTRIBUTING.md) : branches, messages de commit, règles d'usage de l'IA. Puis [`docs/exercices/README.md`](docs/exercices/README.md).
