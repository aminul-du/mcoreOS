# MCOREOS GITHUB ECOSYSTEM ARCHITECTURE
**Document ID:** `DOC-MCOREOS-GH-ARCH-003`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Date:** November 18, 2026  

---

## 1. Architectural Overview & System Model

The MCoreOS ecosystem operates as a **Sovereign Autonomous Intelligence Infrastructure (SAII)** across three execution tiers:
1. **Host Bare-Metal Tier (Debian 13 Trixie):** Kernel configuration, hardware-bound systemd services, LiveKit SFU, and local database instances (PostgreSQL, Qdrant).
2. **Virtual / Isolated Network Namespace Tier (`mcore-ns` / Ubuntu):** Dynamic transit routing via VETH pairs, application sandboxing (Next.js Academy, Profile, EduVerse), isolated IP offset (`TARGET_IP`).
3. **Global Edge & Sovereign Ingress Tier:** Cloudflare QUIC zero-trust tunnels (`ais001`), Cloudflare Workers, and DNS routing resolving to `local.mcore.dev` and `shorbornoai.com`.

---

## 2. 18 SAII Architectural Planes Mapping to GitHub Repositories

Every architectural plane defined in the SAII 2050 Baseline maps directly to specific GitHub repositories to ensure separation of concerns and non-destructive backups:

| # | SAII Architecture Plane | Core Responsibilities | Authoritative GitHub Repository |
|---|---|---|---|
| **1** | **Data Plane** | Vector storage (Qdrant), relational data (PostgreSQL), Redis cache | `aminul-du/mcoreai` (`services/`) |
| **2** | **Control Plane** | Microservice lifecycle, systemd unit definitions, NativeBox delivery | `aminul-du/NativeBox-ais001` & `mcoreOS` |
| **3** | **Security Plane** | Hardened nftables, secret quarantine, Trivy/Gitleaks scanning | `aminul-du/mcoreOS` & `mcoreai` (`security/`) |
| **4** | **Identity Plane** | Agent URI schemes (`agent://voice`, `agent://security`), RBAC | `aminul-du/mcoreai` (`identity/`) |
| **5** | **Intelligence Plane** | LLM orchestrations (Gemini, Vertex AI, Ollama), prompt templates | `aminul-du/mcoreai` (`ai/`) |
| **6** | **Memory Plane** | Episodic/working memory buffers, session persistence | `aminul-du/mcoreai` (`memory/`) |
| **7** | **Knowledge Plane** | Research vectors, university embeddings (`AIS-DU-PMICS`) | `aminul-du/mcore-sboxdrive` & `mcore-unified-library` |
| **8** | **Observability Plane** | Structured audit logs, system telemetry, live-tail logs | `aminul-du/mcoreai` (`observability/`) |
| **9** | **Governance Plane** | 9-Gate validation (G0-G8), architectural attestations | `aminul-du/mcoreai` (`governance/`) |
| **10**| **Verification Plane**| Evidence generators, SBOMs, compliance proofs | `aminul-du/mcoreai` & `mcoreOS` (`evidence/`) |
| **11**| **Trust Plane** | Trust scoring, decision confidence engines | `aminul-du/mcoreai` (`trust-engine/`) |
| **12**| **Safety Plane** | Autonomous kill-switch, human override, recursion bounds | `aminul-du/mcoreai` (`services/safety-plane/`) |
| **13**| **Ethics Plane** | Alignment guards, non-repudiation, policy enforcement | `aminul-du/mcoreai` (`constitution/`) |
| **14**| **Sovereignty Plane** | Data residency policies, local compute preservation | `aminul-du/mcoreOS` (`mcoreos/kernel/`) |
| **15**| **Simulation Plane**| Edge sandboxes, microLab VRF failure domains (`FD-00` to `FD-15`)| `aminul-du/mcoreOS` (`microLab/`, `smartnet/`) |
| **16**| **Evolution Plane** | Zero-downtime upgrades, dynamic route offset algorithms | `aminul-du/WSL-devNet` |
| **17**| **Deployment Plane** | Single-click bootstrap installers, container definitions | `aminul-du/WSL-devNet` (`setup.sh`) & `NativeBox-ais001` |
| **18**| **Operations Plane** | Bare-metal systemd unit sync, cold-boot restore scripts | `aminul-du/mcoreOS` & `mcoreai` |

---

## 3. Technology Choices Comparison

| Component | Selected Technology | Alternative Evaluated | Strategic Evaluation & Trade-off Rationale |
|---|---|---|---|
| **Host OS** | Debian 13 (Trixie) | Ubuntu Server 24.04 | Debian offers absolute bare-metal stability, zero bloat, and pure open-source licensing. |
| **Network Isolation** | `ip netns` (Kernel Namespaces) | Docker Bridge / K8s CNI | Linux namespaces require zero persistent memory/CPU overhead and allow direct host port offset routing. |
| **Packet Filtering** | `nftables` & `iptables` NAT | Commercial Cloud WAF | Native kernel tables provide sub-microsecond latency, zero cloud cost, and local rule transparency. |
| **Tunnel Ingress** | Cloudflare QUIC (`cloudflared`) | Public IPv4 Port Forwarding | Shields bare-metal IP (`113.11.1.161`) from DDoS attacks while maintaining a $0.00/month operational budget. |
| **Backup Medium** | Git Remote Bundles + Local Encrypted Archives | AWS S3 / GCP Cloud Storage | Protects data sovereignty, prevents egress costs, and guarantees recovery even during internet outages. |

---

## 4. Multi-Phase Implementation Roadmap

| Phase | Milestone | Deliverables | Timeline / Status |
|---|---|---|---|
| **Phase 0** | **Local Ecosystem Audit & Standardization** | • Map all 44+ repositories to 18 Planes<br>• Eliminate duplicate scripts<br>• Publish 9 Master Documents to `mcoreOS` | ✅ **Completed** |
| **Phase 1** | **Automated Local Cold-Boot Snapshot** | • Install automated `scripts/mcore-git-backup.sh`<br>• Implement cron/systemd timer for nightly Git bundles | ⏳ In Progress |
| **Phase 2** | **Zero-Trust Network Hardening** | • Enforce strict IP table rules between `eth0` and `veth0`<br>• Isolate sandbox credentials into protected vault | 📅 Q1 2027 |
| **Phase 3** | **Federated Multi-Cloud Mirroring** | • Standby automated mirror to secondary encrypted cold storage without vendor lock-in | 📅 Q2 2027 |

---

## 5. Architectural Risk & Cost Analysis

| Identified Risk | Severity | Probability | Estimated Financial Cost | Mitigation Architecture |
|---|---|---|---|---|
| **Git Credential Interception** | High | Low | $0.00 | Enforce ED25519 asymmetric keys exclusively; disable password/token caches. |
| **Dynamic IP Subnet Drift** | Medium | High | $0.00 | Dynamic offset calculation (`PREFIX.(LAST_OCTET+1)`) in `mcore-netops.sh` recalculates upon every boot. |
| **Local Disk Failure on Node** | Critical | Low | $0.00 (Self-contained) | Distributed Git mirror between bare-metal NVMe, local backup volume, and GitHub remote. |
| **Cloudflare Tunnel Disruption** | Medium | Low | $0.00 | Native fallback route preserves direct LAN access on `172.23.180.161` for continuous local ops. |
