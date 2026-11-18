# MCOREOS P1 SECRET HYGIENE & CREDENTIAL AUDIT REPORT
**Document ID:** `REP-MCOREOS-P1-SEC-003`  
**Directive Version:** `1.0.0` | **Priority:** P1  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Host Target:** Debian GNU/Linux 13 (Trixie) Bare-Metal Node (`MCORE-FDR-AIS-001`)  
**Audit Standard:** Zero-Exposure Safe Analysis (RFC 2828 / NIST SP 800-115)  
**Date:** November 18, 2026  

---

## 1. Executive Summary & Verification Attestation

In strict compliance with Task 5 of Directive P1, a comprehensive scan was executed across all Git repositories, commit histories, working trees, and configuration files. In accordance with Core Safety Rules, **no credentials or raw secret strings are reproduced in this report**.

```text
[SECRET AUDIT VERDICT: ZERO ACTIVE LEAKS IN PUBLIC TRACKING]
Public Credential Leaks:       0 Active Production Secrets Exposed
Private Key Exposure in Git:   0 (ED25519 & RSA Keys Strictly Guarded)
Tracked .env in mcoreOS:       REMEDIATED (mcore-aaa-platform/.env untracked)
Tracked .env in WSL-devNet:    0 Found (Clean)
Tracked .env in shorborno:     0 Found (Clean)
Tracked .env in srv/mcore:     1 Template File Audited (sandbox/.env.production)
Pre-Commit Hook Status:        Hard Regex Gate ACTIVE
```

---

## 2. Repository-by-Repository Secret Audit Matrix

| Repository / Path | Tracked `.env` Files | Tracked Private Keys | Commit Log Anomaly Scan | Pre-Commit Regex Gate | DevSecOps Status |
|---|---|---|---|---|---|
| **`/home/mcoreai/mcoreOS`** | 0 Tracked (`.gitignore` enforced) | 0 Keys Tracked | Clean (Latest: `07df8e1`) | Enforced | ✅ **Hardened** |
| **`/home/mcoreai/WSL-devNet`** | 0 Tracked | 0 Keys Tracked | Clean (Latest: `5d09c10`) | Enforced | ✅ **Hardened** |
| **`/srv/mcore`** | 1 Tracked (`sandbox/.env.production`) | 0 Keys Tracked | Clean (Latest: `6b1eb23`) | Enforced | ⚠️ **Action Proposed** |
| **`/srv/shorborno-agent`** | 0 Tracked | 0 Keys Tracked | Clean (Latest: `0e12587`) | Systemd Sandbox | ✅ **Hardened** |

---

## 3. Detailed Security Findings & Remediation Proposals

### Finding A: `mcoreOS` AAA Platform Secret Hygiene (Remediated)
- **Status:** Complete.
- **Details:** The repository previously tracked `mcore-aaa-platform/.env` containing default docker network placeholders.
- **Action Taken:** Executed non-destructive untracking (`git rm --cached mcore-aaa-platform/.env`). Preserved local runtime configuration file while guaranteeing that future commits and Git bundles remain clean.

### Finding B: `sandbox/.env.production` in `/srv/mcore` (Analysis & Recommendation)
- **Status:** Requires AIS Approval for Untracking.
- **Details:** Analysis confirmed that `sandbox/.env.production` contains structural template strings (`use-strong-password-here`, `run: openssl rand -base64 32`) and a local mock tunnel prefix. No active production database credentials or private keys are exposed.
- **Recommended Action:** In accordance with non-destructive policy, request AIS approval to add `sandbox/.env.production` to `/srv/mcore/.gitignore` and untrack it from the Git index (`git rm --cached sandbox/.env.production`) without altering working tree functionality.

---

## 4. SSH Key Management & Host File Permissions

The host's `~/.ssh` directory was audited for file permissions and algorithm compliance:

| Key Identifier | Purpose | File Permission | Encryption Standard | Compliance Verdict |
|---|---|---|---|---|
| `~/.ssh/id_ed25519` | GitHub Remote Egress | `0600` (`-rw-------`) | ED25519 (256-bit ECC) | ✅ Pass (Strict Least Privilege) |
| `~/.ssh/id_ed25519.pub`| Public Key Registry | `0644` (`-rw-r--r--`) | ED25519 Public | ✅ Pass |
| `~/.ssh/authorized_keys` | Host Access Control | `0600` (`-rw-------`) | Pinned Authorized Keys | ✅ Pass (Locked down) |
| `~/.ssh/known_hosts` | Remote Fingerprint Cache | `0600` (`-rw-------`) | Pinned GitHub Keys | ✅ Pass (Prevents MITM) |

---

## 5. Technology Choices Comparison

| Solution Category | Selected Solution | Evaluated Alternative | Strategic Justification |
|---|---|---|---|
| **Secret Scanning Engine** | Native Regex + AST Static Parser | Cloud SaaS (GitGuardian / Snyk) | Eliminates third-party telemetry, protects proprietary codebases, and costs $0.00. |
| **Credential Injection** | Systemd `EnvironmentFile` + `LoadCredential` | Plain `.env` files in root | Systemd credentials are held in private kernel IPC namespaces inaccessible to unprivileged users. |
| **Key Algorithm** | ED25519 | RSA 2048/4096 | ED25519 offers superior collision resistance, smaller signature size, and immunity to timing attacks. |

---

## 6. Risks, Costs, & Roadmaps

| Identified Risk | Severity | Probability | Financial Cost | Mitigation Architecture |
|---|---|---|---|---|
| **Accidental Secret Commit** | High | Low | $0.00 | Hard pre-commit hook regex blocking all `.env`, `.pem`, and private key extensions. |
| **History Leak in Old Commits** | Medium | Low | $0.00 | Quarantine verified; no live credentials exist in historical DAG commits. |
| **Third-Party SaaS Data Breach** | Critical | Zero | $0.00 | Complete avoidance of cloud secret stores; local air-gapped sovereignty enforced. |
