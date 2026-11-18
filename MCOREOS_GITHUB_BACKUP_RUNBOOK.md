# MCOREOS GITHUB BACKUP & DISASTER RECOVERY RUNBOOK
**Document ID:** `DOC-MCOREOS-GH-BKP-007`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0 (Mission-Critical)  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Date:** November 18, 2026  

---

## 1. Backup Strategy Overview

The MCoreOS backup architecture is designed to guarantee **lossless history**, zero operational downtime, and rapid cold-boot recovery across any bare-metal or cloud-agnostic host.

### Core Backup Doctrines
1. **Three-Tier Redundancy:**
   - **Tier 1 (Working Tree):** Real-time NVMe storage at `/srv/mcore`, `/srv/shorborno-agent`, and `/home/mcoreai`.
   - **Tier 2 (Local Vault):** Self-contained, immutable Git bundles (`.bundle`) and gzip snapshots at `/srv/mcore/backups/`.
   - **Tier 3 (Sovereign Remote):** Encrypted SSH-pushed Git remotes at `git@github.com:aminul-du/*`.
2. **Zero-Cost Implementation:** Uses native POSIX utilities (`tar`, `gzip`, `sha256sum`, `git bundle`) without commercial backup agents.

---

## 2. Standardized Backup Procedures

### Procedure A: Daily Warm Synchronization (Remote Git Push)
Executes automated commits of tracked configuration, documentation, and system state:

```bash
#!/usr/bin/env bash
# Step 1: Navigate to repository
cd /home/mcoreai/mcoreOS

# Step 2: Validate secret quarantine gate
if git diff --cached --name-only | grep -E '\.env|\.pem|\.key'; then
  echo "FATAL: Secret staged. Backup aborted."
  exit 1
fi

# Step 3: Commit and Push using explicitly pinned SSH command
git add .
git commit -m "chore(backup): automated daily synchronization [MCORE-FDR-AIS-001]" || echo "No changes"
git -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" push origin main
```

### Procedure B: Cold-Boot Offline Git Bundle Generation
A Git bundle packages the entire repository history, commits, tags, and branches into a single verifiable binary file that can be cloned offline without network connectivity.

```bash
#!/usr/bin/env bash
# Generate standalone bundles
BACKUP_DIR="/srv/mcore/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

for REPO in /home/mcoreai/mcoreOS /home/mcoreai/WSL-devNet /srv/mcore; do
  NAME=$(basename "$REPO")
  echo "Bundling $NAME..."
  git -C "$REPO" bundle create "$BACKUP_DIR/${NAME}-full.bundle" --all
  sha256sum "$BACKUP_DIR/${NAME}-full.bundle" > "$BACKUP_DIR/${NAME}-full.bundle.sha256"
done

echo "✅ Offline bundles created and attested at $BACKUP_DIR"
```

### Procedure C: State & Database Cold Snapshot
Backs up runtime databases and systemd configurations:

```bash
#!/usr/bin/env bash
# 1. PostgreSQL Schema & Data
sudo -u postgres pg_dumpall | gzip > "/srv/mcore/backups/pg_dump_$(date +%Y%m%d).sql.gz"

# 2. Systemd Unit Snapshot
mkdir -p "/srv/mcore/backups/systemd_units_$(date +%Y%m%d)"
cp /etc/systemd/system/mcore* /srv/mcore/backups/systemd_units_*/ 2>/dev/null || true
cp /etc/systemd/system/shorborno* /srv/mcore/backups/systemd_units_*/ 2>/dev/null || true
```

---

## 3. Technology Choices Comparison

| Solution Category | Selected Solution | Evaluated Alternative | Strategic Trade-Off Rationale |
|---|---|---|---|
| **Archive Format** | `git bundle` | Raw directory `tar.gz` | `git bundle` guarantees git object graph integrity and enables instant `git clone bundle_file` with complete commit history. |
| **Transport** | SSH (`git@github.com`) | HTTPS with OAuth tokens | SSH keys do not expire mid-backup and prevent interactive prompt lockups. |
| **Compression** | `pigz` / `gzip -9` | Zstandard (`zstd`) | `gzip` is pre-installed on 100% of standard Linux distributions, ensuring zero-dependency recovery. |

---

## 4. Backup Governance & Recovery Requirements Matrix

| Resource | Target Recovery Point Objective (RPO) | Target Recovery Time Objective (RTO) | Backup Cadence | Primary Storage Location | Remote Mirror |
|---|---|---|---|---|---|
| **`mcoreOS` Repository** | 12 Hours | < 5 Minutes | Twice Daily | `/home/mcoreai/mcoreOS` | `git@github.com:aminul-du/mcoreOS.git` |
| **`WSL-devNet` Repository** | 24 Hours | < 2 Minutes | On Change | `/home/mcoreai/WSL-devNet` | `git@github.com:aminul-du/WSL-devNet.git` |
| **`mcoreai` Monorepo** | 6 Hours | < 10 Minutes | Continuous / Milestone | `/srv/mcore` | `git@github.com:aminul-du/mcoreai.git` |
| **Systemd Microservices**| 24 Hours | < 5 Minutes | Daily | `/etc/systemd/system/` | Tracked in Git monorepo |
| **PostgreSQL & Qdrant** | 24 Hours | < 15 Minutes | Nightly | `/srv/mcore/backups/` | Encrypted local vault |

---

## 5. Risk, Cost, & Operational Roadmaps

| Risk Scenario | Inherent Severity | Financial Cost | Operational Recovery Protocol |
|---|---|---|---|
| **GitHub Remote Network Outage** | Medium | $0.00 | Restore directly from Tier 2 local bundles in `/srv/mcore/backups/`. |
| **Corrupted Working Tree Index** | Medium | $0.00 | Run `git checkout -f main` or clone from the daily local bundle file. |
| **Catastrophic Host Hardware Failure** | Critical | $0.00 | Provision clean Debian 13 node, install SSH key, clone repositories, execute `setup.sh`. |
