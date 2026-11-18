# MCOREOS GITHUB SECURITY & SECRET GOVERNANCE POLICY
**Document ID:** `DOC-MCOREOS-GH-SEC-006`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0 (Non-Negotiable)  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Date:** November 18, 2026  

---

## 1. Core Security Mandates & Directives

In accordance with Section 6 of the Master Directive, the following security constraints are permanently binding on all human operators, automated scripts, sub-agents, and CI pipelines:

1. **Default Visibility Rule:** All repositories containing core platform logic, systemd configurations, or operational credentials must remain **Private** unless AIS explicitly authorizes public release in writing.
2. **Zero Credential Exposure:** Never expose, commit, or log API keys, database passwords, session tokens, private SSH keys, or cloud certificates.
3. **Non-Destructive Integrity:** Never execute `git push --force`, delete remote repositories, overwrite production branches, or rewrite public Git history.
4. **Zero-Cost Strategy:** Never provision paid subscriptions, cloud upgrades, or proprietary security SAAS tools. All controls must run locally and natively on bare-metal.
5. **No Credential Solicitations:** AI agents and scripts must never request passwords, private keys, or credentials in chat interactions.

---

## 2. Secret Quarantine & Pre-Commit Protection

### Automated Pre-Commit Safety Gate
Every Git repository in the MCoreOS ecosystem must enforce the automated pre-commit / pre-push safety gate:

```bash
#!/usr/bin/env bash
# /usr/local/bin/mcore-git-safety-gate.sh
set -e

# Hard safety gate: abort if any secret or private key pattern is detected
SECRET_PATTERN='\.env($|\.)|\.dev\.vars|\.pem$|\.key$|id_rsa|id_ed25519|credentials\.json'

if git diff --cached --name-only | grep -E "$SECRET_PATTERN"; then
  echo "🚨 CRITICAL SECURITY ALERT: Secret or key file detected in staging area!"
  git diff --cached --name-only | grep -E "$SECRET_PATTERN"
  echo "Commit aborted by MCORE DevSecOps Policy. Quarantine secrets immediately."
  exit 1
fi
```

### Discovery Audit Security Finding: `mcore-aaa-platform/.env`
- **Finding:** A `.env` file was tracked in `mcore-aaa-platform/.env` containing default local strings (`changeme_radius_pass`, `changeme_nas_secret`).
- **Risk Assessment:** Low immediate severity (placeholder values), but violates strict DevSecOps standard hygiene.
- **Remediation Action:**
  1. Ensure `.env` is added to root and subfolder `.gitignore` files.
  2. Maintain sanitized `.env.example` with structural placeholders.
  3. Untrack `.env` cleanly from the Git index (`git rm --cached mcore-aaa-platform/.env`) while preserving the file locally for runtime operation.
  4. Never force-push or rewrite remote history; record remediation in commit history.

---

## 3. Vulnerability & Secret Scanning Matrix

| Tool | Deployment Mode | Scan Frequency | Scope | Action on Detection |
|---|---|---|---|---|
| **Gitleaks** | Local binary / Hook | Pre-commit / Pre-push | All staged git blobs and commit messages | Immediate abort of commit; developer quarantined. |
| **Trivy (v0.69.3)**| Local binary (`/home/mcoreai/`) | Nightly via systemd timer | Filesystem, container images, npm/pnpm manifests | High/Critical CVEs trigger P0 triage alert. |
| **Git FSMonitor** | Native Git Hook | Continuous | File modification tracking across monorepo | Prevents stealth script injection. |
| **SSH-Audit** | Local Python utility | Monthly | `~/.ssh/` keys, host algorithms, `authorized_keys` | Weak ciphers deprecated immediately. |

---

## 4. Technology Choices Comparison

| Security Category | Selected Technology | Alternative Evaluated | Strategic Evaluation & Trade-off Rationale |
|---|---|---|---|
| **Secret Storage** | Local File Quarantine + Systemd `LoadCredential` | HashiCorp Vault | HashiCorp Vault introduces heavy JVM/Go runtime dependencies and high maintenance overhead; systemd credentials require $0 and zero extra processes. |
| **Vulnerability Scanner**| Trivy (Aqua Security) | Snyk CLI (Commercial) | Snyk requires cloud accounts, phone-home telemetry, and paid enterprise tiers. Trivy runs completely air-gapped on bare-metal. |
| **Static Code Analysis** | Python AST & Ripgrep regex | SonarQube Server | Ripgrep and local AST linters run in milliseconds with zero server footprint. |

---

## 5. Security Risk & Cost Governance Table

| Threat Vector | Inherent Risk | Residual Risk | Financial Cost | Enforced Mitigation |
|---|---|---|---|---|
| **Accidental Secret Commit** | High | Low | $0.00 | Hard pre-commit hook regex blocking all `.env`, `.pem`, and key patterns. |
| **Unauthorized Collaborator Access**| High | Negligible | $0.00 | Single-user owner model (`aminul-du`); zero organization invites enabled. |
| **MITM Egress Attacks** | Medium | Negligible | $0.00 | SSH Host Key verification pinned in `~/.ssh/known_hosts`. StrictHostKeyChecking enforced. |
| **Dependency Supply-Chain Poison** | High | Medium | $0.00 | Dependency lockfiles (`pnpm-lock.yaml`, `Cargo.lock`) pinned and audited via Trivy. |
