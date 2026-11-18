#!/usr/bin/env bash
# ==============================================================================
# MCOREOS Hardened Automated Git Backup & Bundle Generator
# Document Reference: DOC-MCOREOS-GH-BKP-007 / REP-MCOREOS-P1-AUTO-004
# Authority: Aminul Islam Shamim (AIS) | MCORE-FDR-AIS-001
# ==============================================================================
set -euo pipefail

LOCK_FILE="/run/lock/mcore-backup.lock"
LOG_FILE="/var/log/mcore/mcore-backup.log"
BACKUP_ROOT="${MCORE_BACKUP_DIR:-/srv/mcore/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VAULT_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
LATEST_LINK="${BACKUP_ROOT}/latest"

# 1. Non-blocking POSIX Lock to Prevent Overlapping Runs
exec 200>"${LOCK_FILE}"
if ! flock -n 200; then
  echo "[$(date -u +%FT%TZ)] [WARN] Another MCoreOS backup process is currently active. Exiting cleanly."
  exit 0
fi

# Ensure logging destination exists
mkdir -p "$(dirname "${LOG_FILE}")"
mkdir -p "${VAULT_DIR}"

log() {
  local msg="[$(date -u +%FT%TZ)] $1"
  echo "$msg"
  echo "$msg" >> "${LOG_FILE}" 2>/dev/null || true
}

log "=========================================================="
log "📦 Starting MCOREOS Automated Backup Pipeline: ${TIMESTAMP}"
log "=========================================================="

REPOS=(
  "/home/mcoreai/mcoreOS"
  "/home/mcoreai/WSL-devNet"
  "/srv/mcore"
  "/srv/mcore/shorbornoBD-NativeBox"
)

ERRORS=0

# 2. Iterate and Bundle Repositories with Error Boundaries
for REPO in "${REPOS[@]}"; do
  if [ ! -d "${REPO}/.git" ]; then
    log "⚠️ Skipping ${REPO}: Not a valid Git repository."
    continue
  fi

  REPO_NAME=$(basename "${REPO}")
  log "🔍 Auditing & Bundling ${REPO_NAME}..."

  BUNDLE_PATH="${VAULT_DIR}/${REPO_NAME}_${TIMESTAMP}.bundle"

  if git -C "${REPO}" bundle create "${BUNDLE_PATH}" --all >/dev/null 2>&1; then
    sha256sum "${BUNDLE_PATH}" > "${BUNDLE_PATH}.sha256"
    log "  ✅ Bundle created: ${BUNDLE_PATH}"
  else
    log "  ❌ FAILED to bundle ${REPO_NAME}."
    ERRORS=$((ERRORS + 1))
  fi
done

# 3. Update Latest Pointer Symlink
rm -f "${LATEST_LINK}"
ln -s "${VAULT_DIR}" "${LATEST_LINK}"
log "🔗 Updated latest vault symlink to: ${VAULT_DIR}"

# 4. Synchronize Master Repositories to GitHub Remote via SSH
log "🚀 Synchronizing tracked changes to verified GitHub remotes..."
for REPO in "${REPOS[@]}"; do
  if [ -d "${REPO}/.git" ]; then
    REPO_NAME=$(basename "${REPO}")
    if git -C "${REPO}" -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" push origin main >/dev/null 2>&1; then
      log "  ✅ Pushed ${REPO_NAME} to remote main."
    else
      log "  ℹ️ Push up-to-date or skipped for ${REPO_NAME}."
    fi
  fi
done

# 5. Retention Management: Keep Last 7 Snapshot Directories
log "🧹 Enforcing retention policy (retaining last 7 snapshot archives)..."
find "${BACKUP_ROOT}" -maxdepth 1 -mindepth 1 -type d -name "202*" | sort -r | tail -n +8 | while read -r OLD_DIR; do
  log "  🗑️ Pruning expired backup directory: ${OLD_DIR}"
  rm -rf "${OLD_DIR}"
done

log "=========================================================="
if [ "${ERRORS}" -eq 0 ]; then
  log "✅ MCOREOS Backup Pipeline Completed Successfully (0 Errors)!"
else
  log "⚠️ MCOREOS Backup Pipeline Completed with ${ERRORS} Errors."
fi
log "=========================================================="

exit "${ERRORS}"
