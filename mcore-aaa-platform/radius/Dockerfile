FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    freeradius freeradius-postgresql freeradius-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mv /usr/sbin/freeradius /usr/sbin/freeradius.bin && \
    printf '#!/bin/sh\nCFG_DIR="/etc/freeradius/3.0"\n[ -d "/etc/freeradius/run" ] && CFG_DIR="/etc/freeradius/run"\nfor arg in "$@"; do\n  [ "$arg" = "-d" ] && exec /usr/sbin/freeradius.bin "$@"\ndone\nexec /usr/sbin/freeradius.bin -d "$CFG_DIR" "$@"\n' > /usr/sbin/freeradius && \
    chmod +x /usr/sbin/freeradius

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1812/udp 1813/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["freeradius", "-f", "-l", "stdout"]
