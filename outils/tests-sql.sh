#!/usr/bin/env bash
# Exécute les tests SQL de src/test/sql/*.sql dans le conteneur. Un test échoué lève SIGNAL et arrête le script.
set -uo pipefail
cd "$(dirname "$0")/.."
echec=0
for f in src/test/sql/*.sql; do
  [ -e "$f" ] || continue
  if docker exec -i facturo-db mariadb -ufacturo -pfacturo facturo < "$f" > /tmp/test-sql.out 2>&1; then
    echo "OK     $f"
  else
    echo "ÉCHEC  $f"; sed 's/^/       /' /tmp/test-sql.out; echec=1
  fi
done
exit $echec
