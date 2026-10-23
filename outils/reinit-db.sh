#!/usr/bin/env bash
# Recrée la base à partir de src/main/sql/*.sql (00_, 01_, 02_, puis vos scripts 2x_).
# À lancer après chaque modification d'un script SQL.
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down -v
docker compose up -d
echo "Attente de MariaDB..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' facturo-db 2>/dev/null)" = "healthy" ]; do sleep 2; done
docker compose logs mariadb | grep -iE "error|warning" | grep -v "\[Warning\] Aborted connection" || true
echo "Base prête. Tests SQL : ./outils/tests-sql.sh"
