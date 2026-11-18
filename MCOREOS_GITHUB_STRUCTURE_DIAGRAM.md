# MCOREOS GITHUB STRUCTURE & TOPOLOGY DIAGRAMS
**Document ID:** `DOC-MCOREOS-GH-DIAG-005`  
**Version:** `1.1.0`  
**Classification:** Sovereign Autonomous Intelligence Infrastructure (SAII 2050 Baseline)  
**Priority:** P0  
**Authority:** Aminul Islam Shamim (AIS) | `MCORE-FDR-AIS-001`  
**Date:** November 18, 2026  

---

## 1. System Ecosystem & Repository Hierarchy Diagram

The following Mermaid architectural diagram visualizes the unified relationship between the verified GitHub account `aminul-du`, the four target roles, and the physical bare-metal host execution layers:

```mermaid
flowchart TB
    subgraph GITHUB_TIER["GitHub Infrastructure (Owner: aminul-du | AIS)"]
        direction TB
        MCOREOS_REPO["mcoreOS<br/>(Master OS, AAA, SmartNet, microLab)<br/>Target: MCoreOS-Deb / FullBack"]
        MCOREAI_REPO["mcoreai<br/>(SAII Monorepo, 18 Planes, Platform Engine)<br/>Target: MCoreOS-Deb / Core"]
        DEVNET_REPO["WSL-devNet<br/>(Ubuntu NetNS, Dynamic IP Offset)<br/>Target: MCoreOS-UbPro"]
        SBOX_REPO["mcore-sboxdrive & sboxdrive-Gdocs<br/>(Research Drive & Academic Sync)<br/>Target: MCoreOS-Sbox"]
        EDGE_REPOS["shorbornoai & NativeBox-ais001<br/>(Validation Edge & Control Plane)"]
    end

    subgraph BARE_METAL_HOST["Bare-Metal Host: Debian 13 (MCORE-FDR-AIS-001 / 113.11.1.161)"]
        direction TB
        ROOT_NS["Root Network Namespace (eth0)<br/>IP: 172.23.180.160/20 | Public: 113.11.1.161"]
        SYS_SERVICES["Bare-Metal Systemd Services<br/>• LiveKit SFU (Host Port 7880/7881)<br/>• shorborno-agent (Python 3.14)<br/>• cloudflared tunnel (ais001)<br/>• Qdrant & PostgreSQL (5432)"]
        
        VETH_BRIDGE["Transit Bridge: veth0 (10.200.1.1/24)<br/>iptables NAT Masquerade"]
    end

    subgraph ISOLATED_NS["Isolated Namespace: mcore-ns (Ubuntu / Target: MCoreOS-UbPro)"]
        VETH_NS["Isolated Interface: veth1 (10.200.1.2/24)<br/>Target IP: 172.23.180.161/32"]
        APPS["MCORE Isolated Apps (/srv/mcore/apps/)<br/>• academy-web (Port 3000)<br/>• ais-profile (Port 3001)<br/>• eduverse (Port 3002)"]
    end

    subgraph BACKUP_ENGINE["Disaster Recovery & Backup Engine (Target: MCoreOS-FullBack)"]
        BUNDLE_GEN["Git Bundle Generator (scripts/mcore-git-backup.sh)"]
        OFFLINE_STORE["Local Encrypted Vault (/srv/mcore/backups/)"]
    end

    %% Relationships
    MCOREOS_REPO <===>|Master Kernel & AAA| ROOT_NS
    MCOREAI_REPO <===>|Service Codebases| SYS_SERVICES
    DEVNET_REPO <===>|NetOps / DevSec Config| VETH_BRIDGE
    VETH_BRIDGE ===|VETH Tunnel| VETH_NS
    VETH_NS --> APPS
    
    ROOT_NS --> BUNDLE_GEN
    BUNDLE_GEN --> OFFLINE_STORE
    BUNDLE_GEN -.->|Pushed via SSH| GITHUB_TIER

    classDef gh fill:#1e293b,stroke:#3b82f6,color:#fff;
    classDef host fill:#0f172a,stroke:#10b981,color:#fff;
    classDef ns fill:#1e1b4b,stroke:#8b5cf6,color:#fff;
    classDef bk fill:#312e81,stroke:#f59e0b,color:#fff;

    class GITHUB_TIER,MCOREOS_REPO,MCOREAI_REPO,DEVNET_REPO,SBOX_REPO,EDGE_REPOS gh;
    class BARE_METAL_HOST,ROOT_NS,SYS_SERVICES,VETH_BRIDGE host;
    class ISOLATED_NS,VETH_NS,APPS ns;
    class BACKUP_ENGINE,BUNDLE_GEN,OFFLINE_STORE bk;
```

---

## 2. Backup Pipeline Data Flow Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Host as Bare-Metal Host (Debian 13)
    participant Engine as Backup Engine (scripts/mcore-git-backup.sh)
    participant LocalVault as Local Encrypted Vault (/srv/mcore/backups/)
    participant GitHub as Remote GitHub (aminul-du/*)

    Note over Host,GitHub: Phase 0 Cold-Boot & Scheduled Sync Execution
    Host->>Engine: Trigger Backup (Systemd Timer / CLI)
    Engine->>Engine: Run Secret Scan (Trivy / Gitleaks)
    alt Secret Detected
        Engine-->>Host: ABORT: Unencrypted credential staged
    else Safe Baseline Verified
        Engine->>Engine: Generate Git Bundle (.bundle)
        Engine->>LocalVault: Store Timestamped Bundle + SHA256 Checksum
        Engine->>GitHub: Push to origin/main via ED25519 SSH Key
        GitHub-->>Engine: Remote Confirmation (HEAD updated)
        Engine-->>Host: Status 200: Backup Attestation Complete
    end
```

---

## 3. Structural Analysis & Comparison Matrix

| Environment Tier | Primary Responsibility | Isolation Mechanism | Target Role Mapping | Resilience Level |
|---|---|---|---|---|
| **Debian 13 Root** | OS kernel, FreeRADIUS, LiveKit, Cloudflared | Bare-metal systemd unit boundaries | `MCoreOS-Deb` | High (Multi-process supervisor) |
| **Ubuntu `mcore-ns`** | Next.js micro-frontends, public edge applications | Linux Network Namespace (`iproute2`) | `MCoreOS-UbPro` | High (Zero host port conflict) |
| **Research Sandbox** | Academic data, experiment scripts, DU embeddings | Quarantined directories & separate git remotes | `MCoreOS-Sbox` | Isolated (No prod access) |
| **Central FullBack** | Disaster recovery ledgers, bundle archives | Offline Git bundle + SSH remote sync | `MCoreOS-FullBack` | Extreme (Lossless lineage) |

---

## 4. Cost, Risk, & Operational Trade-offs

| Strategy Choice | Cost | Trade-Off Advantage | Risk Factor | Strategic Mitigation |
|---|---|---|---|---|
| **Linux NetNS instead of Docker VM** | $0.00 | Instant startup (<10ms), zero memory overhead. | Requires root/sudo privileges for network setup. | Locked `/usr/local/bin/` wrapper script permissions. |
| **Native Git Bundles vs Cloud Snapshots** | $0.00 | Total cloud independence; portable across any machine. | Local NVMe disk failure could destroy local copy. | Bi-directional synchronization to remote GitHub repository. |
| **Direct SSH Keys vs Personal Access Tokens** | $0.00 | Immune to web phishing and token expiration churn. | Key exposure grants administrative push access. | Enforce passphrase encryption & file permissions `0600`. |
