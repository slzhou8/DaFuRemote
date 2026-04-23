#!/usr/bin/env bash

set -euo pipefail

NOTARY_PROFILE="${NOTARY_PROFILE:-DaFuRemoteNotary}"
APPLE_ID="${APPLE_ID:-}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"
APPLE_APP_SPECIFIC_PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:-}"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun not found. Please install Xcode command line tools first." >&2
  exit 1
fi

if [[ -z "${APPLE_ID}" || -z "${APPLE_TEAM_ID}" || -z "${APPLE_APP_SPECIFIC_PASSWORD}" ]]; then
  cat >&2 <<'EOF'
Missing required environment variables.

Set these before running:
  APPLE_ID=you@example.com
  APPLE_TEAM_ID=YOURTEAMID
  APPLE_APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx

Optional:
  NOTARY_PROFILE=DaFuRemoteNotary
EOF
  exit 1
fi

xcrun notarytool store-credentials "${NOTARY_PROFILE}" \
  --apple-id "${APPLE_ID}" \
  --team-id "${APPLE_TEAM_ID}" \
  --password "${APPLE_APP_SPECIFIC_PASSWORD}"

echo
echo "Stored notarization credentials in keychain profile: ${NOTARY_PROFILE}"
echo "Next step:"
echo "  NOTARY_PROFILE=${NOTARY_PROFILE} MACOS_CODESIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' ./scripts/macos_build_sign_notarize.sh"
