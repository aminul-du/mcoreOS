#!/usr/bin/env bash
set -euo pipefail

cd /root/mcoreOS/mcore-aaa-platform
[ -f .env ] || cp .env.example .env
set -a && source .env && set +a

echo ">>> Starting PostgreSQL (FD-08) & FreeRADIUS (FD-02)..."
docker compose -f docker/docker-compose.prod.yml up -d

echo ">>> Seeding test MikroTik voucher (user: test10m, rate: 10M/10M)..."
docker exec -i aaa-postgres psql -U "$RADIUS_DB_USER" -d "$DB_DATABASE" \
  -c "SELECT fn_seed_test_voucher('test10m', 'pass1234', '10M/10M');"

echo ">>> Running radtest against FreeRADIUS (10.0.16.2)..."
docker exec aaa-freeradius radtest test10m pass1234 127.0.0.1 0 "$RADIUS_LOCAL_SECRET"
