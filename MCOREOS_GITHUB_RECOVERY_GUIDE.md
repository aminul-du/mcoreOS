# MCOREOS GITHUB DISASTER RECOVERY & RESTORATION GUIDE
**Document ID:** `DOC-MCOREOS-GH-RECOV-009`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0 (Operational Recovery)  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Host Target:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001`)  
**Date:** November 18, 2026  

---

## 1. Disaster Recovery Overview & Objectives

This Recovery Guide details the exact procedures to reconstruct the entire MCoreOS bare-metal, network namespace, and service ecosystem from zero state.

### Key Recovery Metrics
- **Target RTO (Recovery Time Objective):** < 15 minutes for complete core microservice restoration.
- **Target RPO (Recovery Point Objective):** < 6 hours of committed state.
- **Cost Target:** **$0.00** (Zero commercial recovery tools or cloud fees required).

---

## 2. Disaster Recovery Scenarios & Execution Runbooks

### Scenario 1: Clean Bare-Metal Rebuild from GitHub Remote (Online)
Used when restoring onto a newly installed Debian 13 node with active internet connectivity.

```bash
# Step 1: Install prerequisite system packages
sudo apt update && sudo apt install -y git curl ufw iptables iproute2 pnpm

# Step 2: Restore ED25519 SSH Credentials
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# Place id_ed25519 into ~/.ssh/ and enforce permissions
chmod 600 ~/.ssh/id_ed25519

# Step 3: Clone Master Repositories
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" clone git@github.com:aminul-du/mcoreOS.git /home/mcoreai/mcoreOS
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" clone git@github.com:aminul-du/WSL-devNet.git /home/mcoreai/WSL-devNet
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" clone git@github.com:aminul-du/mcoreai.git /srv/mcore

# Step 4: Re-initialize Network Namespace (Phase 0 Single-Click)
cd /home/mcoreai/WSL-devNet
sudo ./setup.sh

# Step 5: Reload and start Systemd services
sudo systemctl daemon-reload
sudo systemctl restart mcoresec-api mcoresec-mte shorborno-agent
```

### Scenario 2: Air-Gapped / Offline Recovery from Local Git Bundles
Used when internet connectivity or GitHub access is disrupted, restoring directly from immutable `.bundle` archives.

```bash
# Step 1: Locate offline vault
VAULT_DIR="/srv/mcore/backups/latest"

# Step 2: Verify Checksum Integrity
sha256sum -c "$VAULT_DIR/mcoreOS-full.bundle.sha256"

# Step 3: Clone directly from the bundle
git clone "$VAULT_DIR/mcoreOS-full.bundle" /home/mcoreai/mcoreOS
git clone "$VAULT_DIR/WSL-devNet-full.bundle" /home/mcoreai/WSL-devNet

# Step 4: Re-attach remote tracking
cd /home/mcoreai/mcoreOS
git remote set-url origin git@github.com:aminul-du/mcoreOS.git
```

### Scenario 3: Database & Vector State Restoration
Used to restore PostgreSQL databases and Qdrant vector memory.

```bash
# Step 1: Restore PostgreSQL relational tables
gunzip < /srv/mcore/backups/pg_dump_latest.sql.gz | sudo -u postgres psql

# Step 2: Validate Database Connectivity
sudo -u postgres psql -c "SELECT datname FROM pg_database WHERE datname='mcore_aaa';"

# Step 3: Restore Qdrant snapshot vectors
curl -X POST "http://localhost:6333/collections/knowledge/snapshots/upload" \
     -H "Content-Type: multipart/form-data" \
     -F "snapshot=@/srv/mcore/backups/qdrant_knowledge_latest.snapshot"
```

---

## 3. Technology Choices Comparison

| Solution Component | Selected Method | Evaluated Alternative | Technical Justification |
|---|---|---|---|
| **System Packaging** | Git Repositories + Native Systemd | Docker Compose / Helm / K8s | Eliminates nested virtualization overhead on bare-metal; guarantees direct kernel integration. |
| **Database Restore** | Standard SQL dump (`pg_dumpall`) | Block-level file copy | SQL dumps are version-agnostic and allow partial schema restoration across different minor PostgreSQL releases. |
| **Routing Bootstrap** | Single-Click `setup.sh` orchestrator | Manual `ip netns` commands | Eliminates human keystroke error under high-stress disaster recovery conditions. |

---

## 4. Recovery Requirements Matrix

| Recovery Domain | Target Metric | Tool / Command Used | Verification Check |
|---|---|---|---|
| **Git Lineage** | 100% Lossless | `git clone` / `git bundle` | `git fsck --full` returns exit 0 |
| **Namespace Networking** | < 10 seconds | `/usr/local/bin/mcore-netops.sh` | `ip netns exec mcore-ns ping -c 1 8.8.8.8` |
| **Systemd Microservices**| < 30 seconds | `systemctl restart` | `systemctl is-active --quiet <service>` |
| **WebRTC Edge** | < 15 seconds | `docker start livekit` | `curl -I http://localhost:7880/` returns 200/404 |

---

## 5. Recovery Risks & Mitigation Table

| Risk During Recovery | Probability | Severity | Mitigation Procedure |
|---|---|---|---|
| **SSH Host Key Mismatch** | Medium | High | Use `-o StrictHostKeyChecking=accept-new` to seamlessly record verified host signatures. |
| **Stale IP Offset in Namespace**| High | Medium | `mcore-netops.sh` dynamically checks active `eth0` IP and calculates `+1` offset in real-time. |
| **Database Lock on Restore** | Low | High | Stop microservice daemons before executing `psql` schema restoration. |
| **Partial Git Bundle Transfer** | Low | Critical | Every bundle generation creates a `.sha256` attestation that must be verified before restore. |
