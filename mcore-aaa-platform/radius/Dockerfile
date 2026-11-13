FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    freeradius freeradius-postgresql freeradius-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1812/udp 1813/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["freeradius", "-f", "-l", "stdout"]
