# MCOREOS P1 BACKUP AUTOMATION & GOVERNANCE PLAN
**Document ID:** `REP-MCOREOS-P1-AUTO-004`  
**Directive Version:** `1.0.0` | **Priority:** P1  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Date:** November 18, 2026  

---

## 1. Executive Summary & Design Objective

In accordance with Tasks 7, 8, and 9 of Directive P1, this plan defines the production-grade automation architecture for the MCoreOS backup ecosystem. It audits the existing script, details robust error-handling enhancements, formulates a deterministic retention lifecycle, and specifies systemd service/timer units. 

**Mandatory Directive Constraint:** In strict adherence to Task 8, **no systemd timers are activated** in this phase; unit configurations are staged and documented awaiting explicit AIS approval.

---

## 2. Backup Script Audit (`scripts/mcore-git-backup.sh`)

An exhaustive architectural audit of the active backup script was performed:

| Architectural Component | Current State | Identified Vulnerability / Gap | Hardened Production Recommendation |
|---|---|---|---|
| **Error Handling** | `set -euo pipefail` | Script terminates abruptly if a single bundle encounters an uncommitted lock. | Implement `trap` handler with exit code logging and per-repository error boundaries. |
| **Partial Failure Resilience**| Sequential loop | If one repository fails, subsequent repositories are skipped entirely. | Wrap repository bundling in discrete try-catch functions (`continue-on-error` with alert). |
| **Execution Locking** | None | Overlapping backup jobs could corrupt active `.bundle` outputs. | Enforce POSIX file locking via `flock -n /run/lock/mcore-backup.lock`. |
| **Logging & Telemetry** | `stdout` only | Execution logs are lost when running non-interactively via cron/systemd. | Redirect dual-stream to `/var/log/mcore/mcore-backup.log` with ISO-8601 timestamps. |
| **Lifecycle Retention** | Accumulative | Unbounded bundle creation will eventually consume disk space over years. | Implement automated pruning: retain 7 daily, 4 weekly, and 3 monthly snapshots. |

---

## 3. Automated Lifecycle & Retention Policy

To preserve storage efficiency while ensuring long-term auditability, the following retention matrix is codified:

| Snapshot Tier | Retention Period | Target Count | Pruning Frequency | Selection Criteria |
|---|---|---|---|---|
| **Tier A (Daily)** | 7 Days | 7 Bundles | Nightly at 03:30 UTC | Every nightly snapshot within last 7 calendar days. |
| **Tier B (Weekly)** | 30 Days | 4 Bundles | Sunday at 04:00 UTC | Sunday snapshot retained as weekly baseline for 4 weeks. |
| **Tier C (Monthly)** | 90 Days | 3 Bundles | 1st of month | 1st day of month snapshot retained for quarterly compliance. |
| **Tier D (Cold Archive)**| > 90 Days | Off-site Only | Manual AIS Review | Archived to encrypted cold storage before local purge. |

---

## 4. Google Drive Sovereign Secondary Path Identification

Under Task 9, an analysis of existing authorized cloud storage endpoints was conducted:

### Verified Google Drive Path
```text
Root Drive Location:  /content/drive/MyDrive/AIS-DU-PMICS-PROJECT-SBOX/
Designated Path:      MyDrive/AIS-DU-PMICS-PROJECT-SBOX/05_Evidence_and_Validation/backups/
Auth Provider:        Google Cloud ADC (~/.config/gcloud/application_default_credentials.json)
Transit Protocol:     Colab Native Bridge / rclone encrypted transport
Status:               IDENTIFIED ONLY (Zero uploads initiated; awaiting AIS authorization)
```

### Safety & Sovereignty Directives
- **Zero-Cloud Spending:** Exclusively utilizes existing allocated academic Drive space.
- **Client-Side Encryption:** Bundles must be encrypted with AES-256 (`gpg --symmetric`) prior to cloud ingress.
- **Upload Hold Enforced:** No files will be transmitted until AIS explicitly authorizes the destination and content manifest.

---

## 5. Systemd Unit Architecture (Staged / Inactive)

### A. Service Unit: `/etc/systemd/system/mcore-git-backup.service`
```ini
[Unit]
Description=MCoreOS Automated Git Bundle & Remote Sync Engine
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/aminul-du/mcoreOS

[Service]
Type=oneshot
User=mcoreai
Group=mcoreai
Environment="MCORE_BACKUP_DIR=/srv/mcore/backups"
ExecStart=/usr/bin/flock -n /run/lock/mcore-backup.lock /home/mcoreai/mcoreOS/scripts/mcore-git-backup.sh
StandardOutput=append:/var/log/mcore/mcore-backup.log
StandardError=append:/var/log/mcore/mcore-backup.log
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

### B. Timer Unit: `/etc/systemd/system/mcore-git-backup.timer`
```ini
[Unit]
Description=Nightly Trigger for MCoreOS Automated Git Backup
Requires=mcore-git-backup.service

[Timer]
OnCalendar=*-*-* 03:00:00 UTC
RandomizedDelaySec=300
Persistent=true

[Install]
WantedBy=timers.target
```

*Note: In compliance with Directive Section 8, the timer is NOT enabled or started. It remains staged awaiting explicit AIS approval.*

---

## 6. Technology Choices Comparison

| Solution Domain | Selected Solution | Alternative Evaluated | Strategic Evaluation & Justification |
|---|---|---|---|
| **Scheduler** | Systemd Timers | Traditional `crond` | Systemd timers provide integrated journal logging, missed-run execution (`Persistent=true`), and failure notifications. |
| **Concurrency Control**| `flock` (File Lock) | PID file checking | Kernel-level file descriptors automatically unlock if a process crashes, preventing stale lock deadlocks. |
| **Secondary Destination**| Google Drive Academic Path | AWS S3 Standard | Leverages established DU academic project footprint (`AIS-DU-PMICS`); zero cloud billing overhead. |

---

## 7. Risks, Costs, & Roadmaps

| Risk Factor | Inherent Risk | Residual Risk | Financial Cost | Enforced Mitigation |
|---|---|---|---|---|
| **Timer Overlap During Large Pushes**| Medium | Zero | $0.00 | `flock -n` immediately exits with exit code 0 if a previous backup is still active. |
| **Google Drive Token Expiry** | Low | Low | $0.00 | OAuth refresh tokens handled via ADC; failure to sync to Drive triggers alert without failing local vault. |
| **Unplanned Cloud Billing** | High | Zero | $0.00 | Pinned strictly to existing Google Drive free/academic allocation. |
