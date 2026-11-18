# mCoreOS — Sovereign Modular Edge Microserver OS & Master Ecosystem

**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0 (Production / Mission-Critical)  
**Founder & Final Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Verified Owner:** `aminul-du` (`git@github.com:aminul-du/mcoreOS.git`)  
**Operating Environment:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001`)  

---

## 🏛️ Master Governance & Documentation Catalog

In accordance with the **MCOREOS GITHUB BACKUP & ORGANIZATION MASTER DIRECTIVE (v1.1.0)**, this repository serves as the **Master Coordination and Disaster Recovery Anchor** for the entire MCoreOS GitHub ecosystem.

All operational documentation is ratified and maintained under the **Master Documentation Catalog**:

| Document Reference | Specification File | Description |
|---|---|---|
| **DOC-01** | [MCOREOS_GITHUB_MASTER_INDEX.md](MCOREOS_GITHUB_MASTER_INDEX.md) | Central navigation index, governing doctrines, and target role mapping. |
| **DOC-02** | [MCOREOS_GITHUB_OWNERSHIP_AUDIT.md](MCOREOS_GITHUB_OWNERSHIP_AUDIT.md) | Cryptographic ownership audit confirming account `aminul-du` and access controls. |
| **DOC-03** | [MCOREOS_GITHUB_ARCHITECTURE.md](MCOREOS_GITHUB_ARCHITECTURE.md) | SAII 18-plane architecture mapping, node topologies, and tech comparisons. |
| **DOC-04** | [MCOREOS_GITHUB_REPOSITORY_MATRIX.csv](MCOREOS_GITHUB_REPOSITORY_MATRIX.csv) | Full inventory of 44+ repositories, branches, visibility, and scopes. |
| **DOC-05** | [MCOREOS_GITHUB_STRUCTURE_DIAGRAM.md](MCOREOS_GITHUB_STRUCTURE_DIAGRAM.md) | Mermaid system topology, network isolation, and backup pipeline diagrams. |
| **DOC-06** | [MCOREOS_GITHUB_SECURITY_POLICY.md](MCOREOS_GITHUB_SECURITY_POLICY.md) | Secret quarantine gates, vulnerability scanning, and non-destructive policies. |
| **DOC-07** | [MCOREOS_GITHUB_BACKUP_RUNBOOK.md](MCOREOS_GITHUB_BACKUP_RUNBOOK.md) | Automated warm sync, offline Git bundles, and cold-boot disaster recovery runbooks. |
| **DOC-08** | [MCOREOS_GITHUB_VERIFICATION_REPORT.md](MCOREOS_GITHUB_VERIFICATION_REPORT.md) | Empirical verification proofs, remote HEAD hashes, and audit findings. |
| **DOC-09** | [MCOREOS_GITHUB_RECOVERY_GUIDE.md](MCOREOS_GITHUB_RECOVERY_GUIDE.md) | Emergency bare-metal restoration runbook from zero to active node. |

---

## 🎯 Target Role to Existing Repository Mapping

| Proposed Target Role | Intended Responsibility | Mapped Existing Infrastructure |
|---|---|---|
| **`MCoreOS-Deb`** | Debian 13 environment backup & kernel | `mcoreOS` & `mcoreai` |
| **`MCoreOS-UbPro`** | Ubuntu Pro / Isolated NetNS backup | `WSL-devNet` |
| **`MCoreOS-Sbox`** | Isolated sandbox & experimental drive | `mcore-sboxdrive` & `sboxdrive-Gdocs` |
| **`MCoreOS-FullBack`** | Central backup index & disaster recovery | `mcoreOS` (Master Docs) & `mcoreai` |

---

## 🧩 Core System Modules

1. **`mcoreos/`** — Kernel configuration fragments (`mcore.fragment`) and host `nftables` policies.
2. **`smartnet/`** — Multi-domain IP/VRF Failure Domain matrix (`FD-00` to `FD-15`) and site routing intents.
3. **`microLab/`** — Edge sandbox orchestration and Linux VRF network provisioning scripts.
4. **`mcore-aaa-platform/`** — Hotspot & RADIUS AAA Billing Platform (FreeRADIUS + PostgreSQL + MikroTik).
5. **`scripts/`** — Automated Git bundling, backup synchronization (`mcore-git-backup.sh`), and disaster recovery utilities.

---

## 🚀 Quick Start: Automated Backup Generation

Generate offline Git bundles and synchronize changes to verified GitHub remotes:

```bash
sudo ./scripts/mcore-git-backup.sh
```

---
> **Governing Principle:** AIS decides. MCore engineers. AI assists. Security protects. Trust verifies.  
> **Repository Strategy:** Lossless history, existing infrastructure first, zero-cost sovereignty.
