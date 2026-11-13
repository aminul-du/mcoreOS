#!/usr/bin/env bash
set -euo pipefail

# Create SmartNet VRFs and dummy/bridge interfaces for site-001
declare -A VRFS=(
  ["vrf-fd02"]="1002:10.0.16.1/20"
  ["vrf-fd03"]="1003:10.0.32.1/20"
  ["vrf-fd08"]="1008:10.0.112.1/20"
  ["vrf-fd13"]="1013:10.0.192.1/20"
)

for vrf in "${!VRFS[@]}"; do
  table="${VRFS[$vrf]%%:*}"
  cidr="${VRFS[$vrf]##*:}"
  br="br-${vrf#vrf-}"

  ip link show "$vrf" >/dev/null 2>&1 || ip link add "$vrf" type vrf table "$table"
  ip link set dev "$vrf" up

  ip link show "$br" >/dev/null 2>&1 || ip link add "$br" type bridge
  ip link set dev "$br" master "$vrf"
  ip addr replace "$cidr" dev "$br"
  ip link set dev "$br" up
done

# Apply SmartNet NFTables rules
if [ -f "/root/mcoreOS/mcoreos/scripts/nftables-radius.nft" ]; then
  nft -f /root/mcoreOS/mcoreos/scripts/nftables-radius.nft
fi

echo "✔ microLab site-001 VRFs and SmartNet firewall active."
