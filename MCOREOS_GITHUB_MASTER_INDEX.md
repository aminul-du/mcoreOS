# MCOREOS GITHUB MASTER INDEX
**Document ID:** `DOC-MCOREOS-GH-INDEX-001`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0 (Mission-Critical)  
**Owner & Final Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Verified GitHub Account:** `aminul-du` (`https://github.com/aminul-du`)  
**Host Target:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001`)  
**Date of Ratification:** November 18, 2026  

---

## 1. Executive Directive & Scope
This Master Index governs the architecture, ownership, backup strategy, security policies, and operational runbooks for the entire **MCoreOS GitHub Ecosystem**. Operating under the **Existing Infrastructure First** doctrine, all assets are cataloged, safeguarded, and synchronized to prevent fragmentation, redundant repository creation, and unauthorized privilege escalation.

### Governing Principles
1. **AIS Decides:** Aminul Islam Shamim (AIS) is the sole Founder, Owner, and Final Authority. No repository transfers, visibility changes, or deletions may occur without explicit written authorization.
2. **Existing Infrastructure First:** Verified existing repositories under `aminul-du` take absolute precedence over theoretical structures.
3. **Zero-Cost & Non-Destructive Operations:** Exclusively utilize bare-metal rsync/bundle routines, native GitHub features, and open-source runtimes. Never destroy commit history or active services.
4. **Absolute Privacy:** Repositories containing proprietary architectures, security policies, and system models must remain strictly private or policy-gated.

---

## 2. Master Documentation Catalog

| Document Reference | File Name | Purpose & Primary Contents | Status |
|---|---|---|---|
| **DOC-01** | `MCOREOS_GITHUB_MASTER_INDEX.md` | Master index, governing doctrines, and navigation catalog across all assets. | ✅ Ratified |
| **DOC-02** | `MCOREOS_GITHUB_OWNERSHIP_AUDIT.md` | Ownership verification, GitHub account audit (`aminul-du`), and team access matrix. | ✅ Ratified |
| **DOC-03** | `MCOREOS_GITHUB_ARCHITECTURE.md` | System architecture, multi-node topology, and 18 SAII Plane mappings. | ✅ Ratified |
| **DOC-04** | `MCOREOS_GITHUB_REPOSITORY_MATRIX.csv` | Comprehensive inventory of all 44+ repositories, branches, visibility, and roles. | ✅ Ratified |
| **DOC-05** | `MCOREOS_GITHUB_STRUCTURE_DIAGRAM.md` | Mermaid topology diagrams, data flows, and backup pipeline visualizations. | ✅ Ratified |
| **DOC-06** | `MCOREOS_GITHUB_SECURITY_POLICY.md` | DevSecOps hygiene, secret quarantine, branch protection, and vulnerability governance. | ✅ Ratified |
| **DOC-07** | `MCOREOS_GITHUB_BACKUP_RUNBOOK.md` | Step-by-step cold-boot, warm sync, and disaster recovery backup runbooks. | ✅ Ratified |
| **DOC-08** | `MCOREOS_GITHUB_VERIFICATION_REPORT.md` | Empirical proof, commit hashes, connectivity checks, and zero-loss audit findings. | ✅ Ratified |
| **DOC-09** | `MCOREOS_GITHUB_RECOVERY_GUIDE.md` | Emergency bare-metal restoration runbook from Git bundles and snapshots. | ✅ Ratified |

---

## 3. Target Role to Verified Existing Repository Mapping

The Master Directive defines four core operational targets. In accordance with Section 2 ("Do not create another MCoreOS organization or duplicate repositories"), these roles map directly to verified existing infrastructure:

| Proposed Target Role | Intended Responsibility | Mapped Existing Repository | Repository URL | Status & Operational Scope |
|---|---|---|---|---|
| **`MCoreOS-Deb`** | Debian 13 Environment Backup & Kernel | `mcoreOS` & `mcoreai` | `git@github.com:aminul-du/mcoreOS.git`<br>`git@github.com:aminul-du/mcoreai.git` | **Active / Production:** Houses Debian 13 kernel configs, trixie-slim containers, AAA platform, and systemd units. |
| **`MCoreOS-UbPro`** | Ubuntu Pro / Isolated NetNS Backup | `WSL-devNet` | `git@github.com:aminul-du/WSL-devNet.git` | **Active / Production:** Houses `mcore-ns` network namespace, dynamic IP routing (`WSL_IP + 1`), and NetOps scripts. |
| **`MCoreOS-Sbox`** | Isolated Sandbox & Research Drive | `mcore-sboxdrive` & `sboxdrive-Gdocs` | `git@github.com:aminul-du/mcore-sboxdrive.git`<br>`git@github.com:aminul-du/sboxdrive-Gdocs.git` | **Active / Research:** Dedicated storage and academic synchronization for `AIS-DU-PMICS-PROJECT-SBOX`. |
| **`MCoreOS-FullBack`** | Central Backup Index & Disaster Recovery | `mcoreOS` (Master Docs) & `mcoreai` | `git@github.com:aminul-du/mcoreOS.git`<br>`git@github.com:aminul-du/mcoreai.git` | **Active / Master:** Serves as the central coordination anchor, disaster recovery runbook host, and backup ledger. |

---

## 4. Ecosystem Technology Choices

| Technology Domain | Selected Solution | Strategic Justification | Alternative Evaluated & Rejected |
|---|---|---|---|
| **Version Control** | Git + GitHub (`aminul-du`) | Industry standard, immutable commit lineage, SSH key authentication. | Self-hosted GitLab (unnecessary compute & maintenance overhead). |
| **Network Isolation** | Linux Kernel NetNS (`iproute2`) | Native zero-cost kernel isolation, sub-millisecond route resolution. | Full Virtual Machines (prohibitive memory footprint on bare-metal). |
| **Backup Serialization** | `git bundle` + AES-256 tarballs | Self-contained, offline portable, lossless commit history preservation. | Cloud-native snapshot lock-in (violates cloud-agnostic sovereignty). |
| **Access Control** | ED25519 Hardware-bound SSH Keys | Post-quantum resilient asymmetric cryptography, zero password reliance. | HTTPS token caching (susceptible to token sprawl and memory scraping). |

---

## 5. Maintenance & Escalation Protocol
- **Scheduled Maintenance:** Bi-weekly Git bundle generation and integrity attestation.
- **Critical Incidents:** Any remote repository unavailability or unauthorized branch creation triggers an immediate P0 freeze.
- **Escalation Path:** All escalations route directly to Founder AIS (`aminul@aminul-du.com`).
