# MCOREOS P1 DEBIAN 13 DISASTER RECOVERY RUNBOOK
**Document ID:** `RBK-MCOREOS-P1-RECOV-005`  
**Directive Version:** `1.0.0` | **Priority:** P1 (Production Execution)  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Host Target:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001` / `113.11.1.161`)  
**Date:** November 18, 2026  

---

## 1. Disaster Recovery Overview & Target SLAs

This runbook provides the definitive operational blueprint to reconstruct the entire MCoreOS bare-metal host, network namespaces, microservices, and databases from zero state.

### Target Service Level Agreements (SLAs)
- **Recovery Time Objective (RTO):** < 15 Minutes (Full service restoration).
- **Recovery Point Objective (RPO):** < 6 Hours (Maximum committed state lag).
- **Recovery Financial Cost:** **$0.00** (Zero commercial tools or proprietary recovery licenses).

---

## 2. Prerequisites & Minimum System Requirements

Before executing recovery on a clean or repaired node, verify the following baseline hardware and OS configurations:

| Hardware / OS Prerequisite | Minimum Specification | Verification Command | Expected Output |
|---|---|---|---|
| **Operating System** | Debian GNU/Linux 13 (Trixie) | `cat /etc/os-release` | `PRETTY_NAME="Debian GNU/Linux 13 (trixie)"` |
| **Linux Kernel** | Kernel 6.1+ with NetNS & VRF support | `uname -r` | `6.18.*` or newer |
| **Storage Capacity** | Minimum 50 GB NVMe/SSD on `/srv` | `df -h /srv` | > 40 GB Free Space |
| **Administrative Access** | User `mcoreai` with sudo privileges | `id -un && sudo whoami` | `mcoreai` / `root` |
| **Egress Connectivity** | GitHub SSH Port 22 or Bundle Vault | `ssh -T git@github.com` | `Hi aminul-du! You've successfully authenticated` |

---

## 3. Step-by-Step Restoration Execution Procedures

### Step 1: Base Operating System & Toolchain Bootstrap
On the target Debian 13 node, install core utilities and disable terminal pagers:

```bash
# Update APT repository cache
sudo apt update

# Install mandatory runtime dependencies
sudo apt install -y git curl wget iproute2 iptables ufw pigz jq postgresql-client

# Enforce Git non-interactive SSH transport
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# Restore user id_ed25519 key to ~/.ssh/id_ed25519 and secure permissions:
chmod 600 ~/.ssh/id_ed25519
ssh-keyscan github.com >> ~/.ssh/known_hosts && chmod 600 ~/.ssh/known_hosts
```

---

### Step 2: Repository Restoration (Select Mode)

#### Mode A: Online Restoration from GitHub Remotes (Default)
```bash
# 1. Restore Master MCoreOS Governance Repository
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" clone git@github.com:aminul-du/mcoreOS.git /home/mcoreai/mcoreOS

# 2. Restore WSL-devNet Network Namespace Repository
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" clone git@github.com:aminul-du/WSL-devNet.git /home/mcoreai/WSL-devNet

# 3. Restore Platform Engine Monorepo
sudo mkdir -p /srv/mcore && sudo chown -R mcoreai:mcoreai /srv/mcore
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" clone git@github.com:aminul-du/mcoreai.git /srv/mcore
```

#### Mode B: Offline Air-Gapped Restoration from Local Git Bundles
```bash
VAULT_PATH="/srv/mcore/backups/latest"

# 1. Cryptographically verify SHA-256 hashes
cd "$VAULT_PATH"
sha256sum -c *.sha256

# 2. Rebuild working repositories directly from bundles
git clone "$VAULT_PATH/mcoreOS_*.bundle" /home/mcoreai/mcoreOS
git clone "$VAULT_PATH/WSL-devNet_*.bundle" /home/mcoreai/WSL-devNet
git clone "$VAULT_PATH/mcore_*.bundle" /srv/mcore

# 3. Re-attach remote tracking
git -C /home/mcoreai/mcoreOS remote set-url origin git@github.com:aminul-du/mcoreOS.git
git -C /home/mcoreai/WSL-devNet remote set-url origin git@github.com:aminul-du/WSL-devNet.git
git -C /srv/mcore remote set-url origin git@github.com:aminul-du/mcoreai.git
```

---

### Step 3: Network Namespace & Route Re-initialization (Phase 0 Single-Click)
Deploy the isolated network namespace `mcore-ns`, setup VETH pair routing, and configure firewall rules:

```bash
cd /home/mcoreai/WSL-devNet
sudo ./setup.sh
```

**Verification Check:**
```bash
# Verify active namespace
sudo ip netns list | grep -q "mcore-ns" && echo "✅ Namespace Active"

# Verify namespace egress connectivity
sudo ip netns exec mcore-ns ping -c 2 8.8.8.8
```

---

### Step 4: Database & State Restoration
```bash
# 1. Restore PostgreSQL schemas and relational tables
gunzip < /srv/mcore/backups/latest/pg_dump_latest.sql.gz | sudo -u postgres psql

# 2. Verify Database Health
sudo -u postgres psql -c "\l" | grep -E 'mcore_aaa|mcoresec'
```

---

### Step 5: Systemd Microservice Activation
```bash
# Reload systemd manager configurations
sudo systemctl daemon-reload

# Restart sovereign edge microservices
sudo systemctl restart mcoresec-api mcoresec-mte shorborno-agent cloudflared

# Verify operational status across all units
for SVC in mcoresec-api mcoresec-mte shorborno-agent cloudflared; do
  systemctl is-active --quiet "$SVC" && echo "✅ $SVC: ACTIVE" || echo "❌ $SVC: FAILED"
done
```

---

## 4. Recovery Verification Checklist & Sign-Off Matrix

| Check Sequence | Recovery Gate | Target Verification Standard | Validation Command | Result |
|---|---|---|---|---|
| **Gate 1** | Git Lineage | DAG graph clean, zero missing commits | `git -C /home/mcoreai/mcoreOS fsck --full` | Verified |
| **Gate 2** | Network Stack | VETH pair transit responsive (`10.200.1.2`) | `ip netns exec mcore-ns ping -c 1 10.200.1.1` | Verified |
| **Gate 3** | App Stack | Ports 3000, 3001, 3002 bound in namespace | `ip netns exec mcore-ns netstat -tulpn` | Verified |
| **Gate 4** | WebRTC Edge | LiveKit SFU host ports 7880/7881 responsive | `curl -I http://localhost:7880/` | Verified |
| **Gate 5** | Public Ingress | Zero-trust tunnel routing traffic | `curl -I https://shorbornoai.com` | Verified |

---

## 5. Technology Choices Comparison

| Solution Domain | Selected Recovery Solution | Evaluated Alternative | Strategic Trade-off & Justification |
|---|---|---|---|
| **Node Provisioning** | Native Bare-Metal Scripting (`setup.sh`) | Ansible / Terraform Cloud | Eliminates agent dependencies and third-party SaaS downtime risk during emergency outages. |
| **Service Supervisor** | Native Linux Systemd Units | Docker Swarm / MicroK8s | Zero CPU/memory overhead; native crash auto-restarts (`Restart=always`) with sub-millisecond supervisor response. |
| **Network Engine** | Kernel VETH Pairs + Scoped NAT | Software Defined Overlay (VxLAN) | Sub-microsecond latency, native kernel throughput, zero encapsulation overhead. |
