# CHANGELOG: MCoreOS

All notable changes to the MCoreOS ecosystem, operating system layers, SmartNet VRF fabric, AAA platform, and disaster recovery infrastructure are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), adhering to Semantic Versioning and the SAII 2050 Baseline.

---

## [1.1.0] - 2026-11-18

### Added
- **Master Documentation Infrastructure (Directive v1.1.0):**
  - `MCOREOS_GITHUB_MASTER_INDEX.md`: Master catalog linking all governance and recovery docs.
  - `MCOREOS_GITHUB_OWNERSHIP_AUDIT.md`: Cryptographic ownership audit confirming account `aminul-du` and authority `MCORE-FDR-AIS-001`.
  - `MCOREOS_GITHUB_ARCHITECTURE.md`: SAII 18-plane architecture mapping to repository ecosystem.
  - `MCOREOS_GITHUB_REPOSITORY_MATRIX.csv`: Complete inventory of all 44+ repositories, branches, visibility, and target roles.
  - `MCOREOS_GITHUB_STRUCTURE_DIAGRAM.md`: Detailed Mermaid system topology and backup pipeline flowcharts.
  - `MCOREOS_GITHUB_SECURITY_POLICY.md`: Zero-credential exposure policy, pre-commit safety gates, and Trivy scanning standards.
  - `MCOREOS_GITHUB_BACKUP_RUNBOOK.md`: Automated warm sync, offline Git bundles, and cold-boot disaster recovery runbooks.
  - `MCOREOS_GITHUB_VERIFICATION_REPORT.md`: Empirical verification report confirming zero-loss DAG integrity.
  - `MCOREOS_GITHUB_RECOVERY_GUIDE.md`: Step-by-step restoration guide from zero state to running node.
- **Directory Standardization:**
  - Initialized `docs/`, `architecture/`, `inventory/`, `configs/`, `scripts/`, `recovery/`, `security/`, and `evidence/`.
  - Added automated offline bundle backup script `scripts/mcore-git-backup.sh`.

### Changed
- Refactored `README.md` to introduce the Master Governance Index and target role mappings (`MCoreOS-Deb`, `MCoreOS-UbPro`, `MCoreOS-Sbox`, `MCoreOS-FullBack`).
- Enforced strict SSH transport with `-c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new"` across all automated git hooks.

### Security
- Untracked `mcore-aaa-platform/.env` from git index to eliminate credentials from public tracking while maintaining local `.env` runtime configuration.
- Enforced hard pre-commit regex gate against secrets, keys, and tokens.

---

## [1.0.0] - 2026-11-13
### Added
- Initialized `mCoreOS` with `microLab`, `smartnet`, and `mcore-aaa-platform`.
- FreeRADIUS Debian trixie-slim container configurations with monthly `radacct` partitioning.
- SmartNet multi-domain failure domain matrix (`FD-00` to `FD-15`).
- GitHub Actions CI workflows for independent module path filtering.
