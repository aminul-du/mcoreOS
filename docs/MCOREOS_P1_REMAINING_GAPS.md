# MCOREOS P1 REMAINING GAPS & ACTION APPROVAL REGISTER
**Document ID:** `REG-MCOREOS-P1-GAPS-006`  
**Directive Version:** `1.0.0` | **Priority:** P1  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Host Target:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001`)  
**Date:** November 18, 2026  

---

## 1. Executive Summary & Governance Overview

In strict accordance with the **Autonomous Execution Policy** of Directive P1, all non-destructive audits, checksum attestations, and isolated restoration tests have been completed. 

Actions requiring new administrative authority, remote repository creation, service timer activation, or external uploads have been purposefully halted. This register catalogs every remaining gap, associated risk, proposed technical resolution, and explicit AIS approval requirement.

---

## 2. Action Approval Matrix (Pending AIS Authorization)

| Item # | Identified Gap / Required Action | Risk / Strategic Impact | Proposed Technical Resolution | AIS Approval Needed? | Status |
|---|---|---|---|---|---|
| **GAP-01** | **`shorborno-agent` Remote Repository Missing** | Local service running at `/srv/shorborno-agent` has no remote GitHub mirror; hardware failure could lose voice daemon unit definitions. | Provision private GitHub repository `git@github.com:aminul-du/shorborno-agent.git` and push local `main`. | **YES (Mandatory)** | ⏸️ Staged |
| **GAP-02** | **`shorbornoai` Remote Repository Empty** | WebRTC edge validation platform has local commits at `/srv/mcore/shorbornoBD-NativeBox` but remote HEAD is empty. | Push verified production edge WebRTC commit baseline to `git@github.com:aminul-du/shorbornoai.git`. | **YES (Mandatory)** | ⏸️ Staged |
| **GAP-03** | **Activation of Systemd Backup Timers** | Backups currently require manual CLI invocation (`mcore-git-backup.sh`). Automated nightly runs need timer activation. | Link unit files to `/etc/systemd/system/` and run `systemctl enable --now mcore-git-backup.timer`. | **YES (Mandatory)** | ⏸️ Staged |
| **GAP-04** | **Quarantine `sandbox/.env.production`** | Template file in `/srv/mcore` is tracked in Git, contrary to strict zero-credential tracking doctrine. | Add `sandbox/.env.production` to `/srv/mcore/.gitignore` and run `git rm --cached sandbox/.env.production`. | **YES (Mandatory)** | ⏸️ Staged |
| **GAP-05** | **Google Drive Cloud Mirror Activation** | Secondary disaster recovery mirror on Google Drive is designed and path verified, but zero uploads have been initiated. | Enable encrypted AES-256 upload of `.bundle` files to `MyDrive/AIS-DU-PMICS-PROJECT-SBOX/05_Evidence_and_Validation/backups/`. | **YES (Mandatory)** | ⏸️ Staged |

---

## 3. Technology Choices & Strategic Justifications

| Decision | Selected Path | Alternative Path | Strategic Rationale |
|---|---|---|---|
| **Approval Protocol** | Formal Markdown Register (This document) | Interactive terminal prompts | Guarantees non-repudiation, documented audit trail, and zero accidental destructive actions. |
| **Cloud Sync Strategy** | GPG-Encrypted Bundle Egress | Unencrypted Cloud Storage | Ensures cloud providers cannot inspect proprietary source code or configurations. |
| **Backup Trigger** | Systemd Timer (Staged) | User Shell Cron (`crontab -e`) | Systemd provides central observability via `journalctl -u mcore-git-backup` and system-level privilege bounding. |

---

## 4. Risk, Cost, & Impact Assessment Table

| Action Item | Financial Cost | Operational Downtime Risk | Security Risk if Unresolved | Security Risk if Executed |
|---|---|---|---|---|
| **GAP-01 (`shorborno-agent`)** | $0.00 | Zero | High (Loss of agent code on disk crash) | Zero (Private repo under `aminul-du`) |
| **GAP-02 (`shorbornoai`)** | $0.00 | Zero | Medium (Out-of-sync remote mirror) | Zero (Non-destructive fast-forward push) |
| **GAP-03 (Backup Timer)** | $0.00 | Zero | Low (Relying on manual backup runs) | Zero (Lightweight background oneshot service) |
| **GAP-04 (Secret Quarantine)** | $0.00 | Zero | Medium (Template confusion in Git history) | Zero (File remains on disk for local apps) |
| **GAP-05 (Google Drive Sync)**| $0.00 | Zero | Low (Backup redundancy remains 2-tier) | Zero (Client-side AES-256 encrypted) |

---

## 5. Escalation & Execution Protocol

Upon written confirmation or approval of any item above by Founder AIS (`MCORE-FDR-AIS-001`), the corresponding execution steps will be immediately and autonomously enacted:

1. **For GAP-01 & GAP-02:** Execute `git push origin main` over verified SSH channel.
2. **For GAP-03:** Execute `sudo systemctl daemon-reload && sudo systemctl enable --now mcore-git-backup.timer`.
3. **For GAP-04:** Execute `git -C /srv/mcore rm --cached sandbox/.env.production && git -C /srv/mcore commit -m "chore(security): untrack sandbox env template"`.
4. **For GAP-05:** Deploy the automated Google Colab / rclone encryption sync script.
