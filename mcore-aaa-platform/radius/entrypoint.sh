#!/bin/sh
set -e

: "${DB_HOST:=10.0.112.10}"
: "${DB_DATABASE:=mcore_aaa}"
: "${RADIUS_DB_USER:=radius}"
: "${RADIUS_DB_PASSWORD:=change_me_strong_db_pass}"
: "${RADIUS_NAS_SECRET:=change_me_nas_secret}"
: "${RADIUS_LOCAL_SECRET:=change_me_local_secret}"

# Render configuration templates into /etc/freeradius/3.0/
if [ -d "/raddb-tpl" ]; then
  [ -f "/raddb-tpl/clients.conf" ] && cp /raddb-tpl/clients.conf /etc/freeradius/3.0/clients.conf
  if [ -d "/raddb-tpl/clients.d" ]; then
    mkdir -p /etc/freeradius/3.0/clients.d
    cp -r /raddb-tpl/clients.d/* /etc/freeradius/3.0/clients.d/ 2>/dev/null || true
  fi
  [ -f "/raddb-tpl/mods-enabled/sql" ] && cp /raddb-tpl/mods-enabled/sql /etc/freeradius/3.0/mods-enabled/sql
  [ -f "/raddb-tpl/sites-enabled/default" ] && cp /raddb-tpl/sites-enabled/default /etc/freeradius/3.0/sites-enabled/default
  [ -f "/raddb-tpl/dictionary.mikrotik" ] && cp /raddb-tpl/dictionary.mikrotik /etc/freeradius/3.0/dictionary.mikrotik
fi

# Preserve master dictionary and include dictionary.mikrotik
if [ -f "/etc/freeradius/3.0/dictionary.mikrotik" ]; then
  grep -q "dictionary.mikrotik" /etc/freeradius/3.0/dictionary || \
    echo '$INCLUDE /etc/freeradius/3.0/dictionary.mikrotik' >> /etc/freeradius/3.0/dictionary
fi

# Expand environment variables
for f in /etc/freeradius/3.0/clients.conf /etc/freeradius/3.0/clients.d/* /etc/freeradius/3.0/mods-enabled/sql; do
  [ -f "$f" ] || continue
  sed -i \
    -e "s|\${ENV:DB_HOST}|${DB_HOST}|g" \
    -e "s|\$ENV{DB_HOST}|${DB_HOST}|g" \
    -e "s|\${ENV:DB_DATABASE}|${DB_DATABASE}|g" \
    -e "s|\$ENV{DB_DATABASE}|${DB_DATABASE}|g" \
    -e "s|\${ENV:RADIUS_DB_USER}|${RADIUS_DB_USER}|g" \
    -e "s|\$ENV{RADIUS_DB_USER}|${RADIUS_DB_USER}|g" \
    -e "s|\${ENV:RADIUS_DB_PASSWORD}|${RADIUS_DB_PASSWORD}|g" \
    -e "s|\$ENV{RADIUS_DB_PASSWORD}|${RADIUS_DB_PASSWORD}|g" \
    -e "s|\${ENV:RADIUS_NAS_SECRET}|${RADIUS_NAS_SECRET}|g" \
    -e "s|\$ENV{RADIUS_NAS_SECRET}|${RADIUS_NAS_SECRET}|g" \
    -e "s|\${ENV:RADIUS_LOCAL_SECRET}|${RADIUS_LOCAL_SECRET}|g" \
    -e "s|\$ENV{RADIUS_LOCAL_SECRET}|${RADIUS_LOCAL_SECRET}|g" \
    "$f"
done

# Ensure SQL group and profile queries don't break on missing optional tables
grep -q "group_attribute" /etc/freeradius/3.0/mods-enabled/sql 2>/dev/null || \
  sed -i '/client_table/a \	group_attribute = "SQL-Group"' /etc/freeradius/3.0/mods-enabled/sql
grep -q "read_groups" /etc/freeradius/3.0/mods-enabled/sql 2>/dev/null || \
  sed -i '/group_attribute/a \	read_groups = no\n	read_profiles = no' /etc/freeradius/3.0/mods-enabled/sql

# Enforce freerad permissions
mkdir -p /var/log/freeradius /var/run/freeradius
chown -R freerad:freerad /etc/freeradius/3.0 /var/log/freeradius /var/run/freeradius
chmod -R u=rwX,g=rX,o= /etc/freeradius/3.0

exec "$@"
