#!/bin/sh
set -e

: "${DB_HOST:=10.0.112.10}"
: "${DB_DATABASE:=mcore_aaa}"
: "${RADIUS_DB_USER:=radius}"
: "${RADIUS_DB_PASSWORD:=change_me_strong_db_pass}"
: "${RADIUS_NAS_SECRET:=change_me_nas_secret}"
: "${RADIUS_LOCAL_SECRET:=change_me_local_secret}"

mkdir -p /etc/freeradius/run
cp -rL /etc/freeradius/3.0/* /etc/freeradius/run/

if ! grep -q "/usr/share/freeradius/dictionary" /etc/freeradius/run/dictionary 2>/dev/null; then
  sed -i '1s|^|$INCLUDE /usr/share/freeradius/dictionary\n|' /etc/freeradius/run/dictionary
fi

for f in /etc/freeradius/run/clients.conf /etc/freeradius/run/clients.d/* /etc/freeradius/run/mods-enabled/sql; do
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

grep -q "group_attribute" /etc/freeradius/run/mods-enabled/sql 2>/dev/null || sed -i '/client_table/a \	group_attribute = "SQL-Group"' /etc/freeradius/run/mods-enabled/sql
grep -q "read_groups" /etc/freeradius/run/mods-enabled/sql 2>/dev/null || sed -i '/group_attribute/a \	read_groups = no\n	read_profiles = no' /etc/freeradius/run/mods-enabled/sql

mkdir -p /var/log/freeradius /var/run/freeradius
chown -R freerad:freerad /etc/freeradius/run /var/log/freeradius /var/run/freeradius
chmod -R u=rwX,g=rX,o= /etc/freeradius/run

exec "$@"
