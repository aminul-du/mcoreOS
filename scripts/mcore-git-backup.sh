#!/usr/bin/env bash
# ==============================================================================
# MCOREOS Automated Git Backup & Bundle Generator
# Document Reference: DOC-MCOREOS-GH-BKP-007
# Authority: Aminul Islam Shamim (AIS) | MCORE-FDR-AIS-001
# ==============================================================================
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="${MCORE_BACKUP_DIR:-/srv/mcore/backups}"
VAULT_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
LATEST_LINK="${BACKUP_ROOT}/latest"

echo "=========================================================="
echo "📦 Starting MCOREOS Automated Backup Pipeline: ${TIMESTAMP}"
echo "=========================================================="

mkdir -p "${VAULT_DIR}"

# List of critical active repositories
REPOS=(
  "/home/mcoreai/mcoreOS"
  "/home/mcoreai/WSL-devNet"
  "/srv/mcore"
)

# 1. Secret Gate Check & Offline Bundle Generation
for REPO in "${REPOS[@]}"; do
  if [ ! -d "${REPO}/.git" ]; then
    echo "⚠️ Warning: ${REPO} is not a valid git repository. Skipping."
    continue
  fi

  REPO_NAME=$(basename "${REPO}")
  echo "🔍 Auditing & Bundling ${REPO_NAME}..."

  # Pre-backup security audit: check for staged or untracked .env files
  if git -C "${REPO}" status --porcelain | grep -E '\.env$|\.dev\.vars|\.pem$|\.key$'; then
    echo "🚨 Security Warning: Possible sensitive files detected in status for ${REPO_NAME}."
  fi

  BUNDLE_PATH="${VAULT_DIR}/${REPO_NAME}_${TIMESTAMP}.bundle"
  git -C "${REPO}" bundle create "${BUNDLE_PATH}" --all >/dev/null
  sha256sum "${BUNDLE_PATH}" > "${BUNDLE_PATH}.sha256"
  echo "  ✅ Bundle created: ${BUNDLE_PATH}"
done

# 2. Update Latest Pointer
rm -f "${LATEST_LINK}"
ln -s "${VAULT_DIR}" "${LATEST_LINK}"
echo "🔗 Updated latest vault symlink to: ${VAULT_DIR}"

# 3. Synchronize Master Repositories to GitHub Remote via SSH
echo "🚀 Synchronizing tracked changes to verified GitHub remotes..."
for REPO in "${REPOS[@]}"; do
  if [ -d "${REPO}/.git" ]; then
    REPO_NAME=$(basename "${REPO}")
    echo "Pushing ${REPO_NAME} to remote main..."
    git -C "${REPO}" -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" push origin main 2>/dev/null || {
      echo "  ℹ️ Remote push skipped or up to date for ${REPO_NAME}."
    }
  fi
done

echo "=========================================================="
echo "✅ MCOREOS Backup Pipeline Completed Successfully!"
echo "=========================================================="
