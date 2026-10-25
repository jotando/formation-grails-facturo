#!/usr/bin/env bash
# Exécute les tests SQL de src/test/sql/*.sql dans le conteneur. Un test échoué lève SIGNAL et arrête le script.
set -uo pipefail
cd "$(dirname "$0")/.."
# Client SQL : conteneur Docker par défaut ; MARIADB_CLI permet d'utiliser une base locale
# ex. MARIADB_CLI="mariadb -h127.0.0.1 -ufacturo -pfacturo facturo" ./outils/tests-sql.sh
CLI=${MARIADB_CLI:-docker exec -i facturo-db mariadb -ufacturo -pfacturo facturo}
echec=0
for f in src/test/sql/*.sql; do
  [ -e "$f" ] || continue
  if $CLI < "$f" > /tmp/test-sql.out 2>&1; then
    echo "OK     $f"
  else
    echo "ÉCHEC  $f"; sed 's/^/       /' /tmp/test-sql.out; echec=1
  fi
done
exit $echec
