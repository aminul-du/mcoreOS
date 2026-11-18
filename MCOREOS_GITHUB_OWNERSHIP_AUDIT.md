# MCOREOS GITHUB OWNERSHIP & ACCESS AUDIT
**Document ID:** `DOC-MCOREOS-GH-OWNER-002`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0  
**Auditor / Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Host Target:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001`)  
**Audit Date:** November 18, 2026  

---

## 1. Executive Ownership Attestation

In accordance with Section 2 of the Master Directive, an exhaustive discovery audit was performed to establish verified GitHub account ownership, organization associations, and cryptographic access parameters.

### Verified Identity Assertion
```text
Entity Name:        Meticulous Core Ltd (MCORE)
Founder & Owner:    Aminul Islam Shamim (AIS)
Founder ID:         MCORE-FDR-AIS-001
Official Email:     aminul@aminul-du.com
GitHub Username:    aminul-du
GitHub Profile:     https://github.com/aminul-du
Primary SSH Key:    id_ed25519 (SHA256: Asymmetric Elliptic Curve Key)
Host Environment:   Debian GNU/Linux 13 (Trixie) 6.18.58.1-microsoft-standard-WSL2
```

**Ownership Rule Verification:**  
All existing repositories reside directly under the verified GitHub personal account `aminul-du`. The audit confirmed that **zero third-party organizations** or rogue administrative namespaces exist for MCoreOS assets. Creating a new organization or migrating repositories without explicit AIS authorization is strictly prohibited.

---

## 2. Authentication & Cryptographic Access Matrix

Cryptographic access to the GitHub infrastructure is audited and strictly enforced via public key authentication.

| Identity / Key File | Algorithm & Bits | Target Host | Scope / Access Level | Verified Status |
|---|---|---|---|---|
| `~/.ssh/id_ed25519` | ED25519 (256-bit ECC) | `github.com` | Full Read/Write (`git@github.com:aminul-du/*`) | ✅ Verified (`ssh -T git@github.com` authenticated as `aminul-du`) |
| `~/.ssh/id_ed25519_mcore_new` | ED25519 (256-bit ECC) | Internal Compute / EC2 | Inter-node sovereign transport | ✅ Verified Active |
| `~/.ssh/id_ec2_final` | RSA (4096-bit) | AWS Infrastructure | Secondary Disaster Recovery egress | ✅ Verified Standby |
| `~/.ssh/authorized_keys` | ED25519 | Local Debian Node | Host administrative ingress | ✅ Verified Protected (`chmod 600`) |

### Critical Security Finding: Git SSH Command Resolution
- **Finding:** System environment variables `GIT_CONFIG_KEY_3=core.sshCommand` with empty string overrides caused silent fork failures in automated subshells.
- **Remediation Applied:** Enforced explicit configuration parameter `-c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new"` across all automated sync scripts, guaranteeing non-interactive deterministic execution.

---

## 3. Organization & Team Access Audit

| Entity Type | Entity Identifier | Status on GitHub | Governance Action |
|---|---|---|---|
| **Primary Account** | `aminul-du` | Active (Owner: AIS) | Primary Sovereign Anchor. Retain all repositories here. |
| **Organizations** | None (Queried `/users/aminul-du/orgs`: empty `[]`) | None Active | **Doctrine Upheld:** No duplicate or secondary organizations created. |
| **Collaborators** | None | Restricted | Single-authority model. Default policy: **DENY ALL** external collaborators. |
| **Teams** | N/A | N/A | No team abstraction enabled; single-tenant owner model prevents permission drift. |

---

## 4. Repository Ownership & Boundary Audit

A total of 44 public repositories and active local development trees were audited. Every repository was evaluated against the verified owner identity:

| Repository Name | Remote URL | Verified Owner | Aligned with AIS Sovereign Boundary? |
|---|---|---|---|
| `mcoreOS` | `git@github.com:aminul-du/mcoreOS.git` | `aminul-du` | ✅ Yes (Master OS & Edge Fabric) |
| `mcoreai` | `git@github.com:aminul-du/mcoreai.git` | `aminul-du` | ✅ Yes (SAII 2050 Monorepo & Platform Engine) |
| `WSL-devNet` | `git@github.com:aminul-du/WSL-devNet.git` | `aminul-du` | ✅ Yes (Ubuntu Network Namespace Engine) |
| `NativeBox-ais001` | `git@github.com:aminul-du/NativeBox-ais001.git` | `aminul-du` | ✅ Yes (Operational Control Plane) |
| `shorbornoai` | `git@github.com:aminul-du/shorbornoai.git` | `aminul-du` | ✅ Yes (WebRTC Validation Platform) |
| `shorborno-agent` | `git@github.com:aminul-du/shorborno-agent.git` | `aminul-du` | ⚠️ Local Active (Remote Creation Pending Approval) |
| `mcore-sboxdrive` | `git@github.com:aminul-du/mcore-sboxdrive.git` | `aminul-du` | ✅ Yes (Research Sandbox Drive) |
| `sboxdrive-Gdocs` | `git@github.com:aminul-du/sboxdrive-Gdocs.git` | `aminul-du` | ✅ Yes (Research Document Sync) |
| `MCoreNetproof360`| `git@github.com:aminul-du/MCoreNetproof360.git`| `aminul-du` | ✅ Yes (Network Proof Engine) |
| `mcore-unified-library`| `git@github.com:aminul-du/mcore-unified-library.git`| `aminul-du` | ✅ Yes (Shared Types & Utilities) |

**Conclusion:** All active assets reside under verified owner `aminul-du`. Zero unauthorized repositories or rogue ownership footprints were discovered.
