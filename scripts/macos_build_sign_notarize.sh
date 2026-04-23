#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

usage() {
  cat <<'EOF'
Build, sign, package, and notarize the macOS release build for DaFu Remote.

Usage:
  ./scripts/macos_build_sign_notarize.sh [build.py args...]

Environment:
  MACOS_CODESIGN_IDENTITY        Required. Must be a Developer ID Application identity.
  NOTARY_PROFILE                 Recommended. Keychain profile created by notarytool store-credentials.
  APPLE_ID                       Optional fallback if NOTARY_PROFILE is unset.
  APPLE_TEAM_ID                  Optional fallback if NOTARY_PROFILE is unset.
  APPLE_APP_SPECIFIC_PASSWORD    Optional fallback if NOTARY_PROFILE is unset.
  SKIP_BUILD=1                   Skip the build step and sign the existing .app bundle.
  VERSION                        Optional override for the output DMG version.

Examples:
  NOTARY_PROFILE=DaFuRemoteNotary \
  MACOS_CODESIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
  ./scripts/macos_build_sign_notarize.sh --flutter --hwcodec --unix-file-copy-paste --screencapturekit
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

MACOS_CODESIGN_IDENTITY="${MACOS_CODESIGN_IDENTITY:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"
APPLE_ID="${APPLE_ID:-}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"
APPLE_APP_SPECIFIC_PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:-}"
SKIP_BUILD="${SKIP_BUILD:-0}"
VERSION="${VERSION:-$(python3 - <<'PY'
from pathlib import Path
for line in Path("Cargo.toml").read_text(encoding="utf-8").splitlines():
    if line.startswith("version"):
        print(line.split("=", 1)[1].strip().strip('"'))
        break
PY
)}"

if [[ -z "${MACOS_CODESIGN_IDENTITY}" ]]; then
  echo "MACOS_CODESIGN_IDENTITY is required." >&2
  exit 1
fi

if [[ "${MACOS_CODESIGN_IDENTITY}" != Developer\ ID\ Application:* ]]; then
  echo "MACOS_CODESIGN_IDENTITY must be a 'Developer ID Application: ...' identity for distribution." >&2
  exit 1
fi

if ! security find-identity -v -p codesigning | grep -F "${MACOS_CODESIGN_IDENTITY}" >/dev/null 2>&1; then
  echo "Developer ID identity not found in keychain: ${MACOS_CODESIGN_IDENTITY}" >&2
  echo "Run 'security find-identity -v -p codesigning' to inspect available signing identities." >&2
  exit 1
fi

if [[ -z "${NOTARY_PROFILE}" ]]; then
  if [[ -z "${APPLE_ID}" || -z "${APPLE_TEAM_ID}" || -z "${APPLE_APP_SPECIFIC_PASSWORD}" ]]; then
    echo "Provide NOTARY_PROFILE, or set APPLE_ID + APPLE_TEAM_ID + APPLE_APP_SPECIFIC_PASSWORD." >&2
    exit 1
  fi
fi

for cmd in python3 xcrun codesign create-dmg; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Required tool not found: ${cmd}" >&2
    exit 1
  fi
done

if [[ "${SKIP_BUILD}" != "1" ]]; then
  python3 ./build.py "$@"
fi

APP_DIR="${ROOT_DIR}/flutter/build/macos/Build/Products/Release"
APP_PATH=""
if [[ -d "${APP_DIR}/DaFu Remote.app" ]]; then
  APP_PATH="${APP_DIR}/DaFu Remote.app"
else
  first_app="$(find "${APP_DIR}" -maxdepth 1 -type d -name '*.app' | head -n 1 || true)"
  APP_PATH="${first_app}"
fi

if [[ -z "${APP_PATH}" || ! -d "${APP_PATH}" ]]; then
  echo "No macOS .app bundle found under ${APP_DIR}" >&2
  exit 1
fi

arch="$(uname -m)"
DMG_NAME="DaFuRemote-${VERSION}-macos-${arch}.dmg"
DMG_PATH="${ROOT_DIR}/${DMG_NAME}"
APP_NAME="$(basename "${APP_PATH}")"

rm -f "${DMG_PATH}"

echo "Signing app bundle: ${APP_PATH}"
codesign --force --options runtime --deep --strict -s "${MACOS_CODESIGN_IDENTITY}" "${APP_PATH}" -vvv
codesign --verify --deep --strict --verbose=2 "${APP_PATH}"

echo "Creating DMG: ${DMG_PATH}"
create-dmg \
  --volname "DaFu Remote Installer" \
  --icon "${APP_NAME}" 200 190 \
  --hide-extension "${APP_NAME}" \
  --window-size 800 400 \
  --app-drop-link 600 185 \
  "${DMG_PATH}" \
  "${APP_PATH}"

echo "Signing DMG: ${DMG_PATH}"
codesign --force --options runtime --deep --strict -s "${MACOS_CODESIGN_IDENTITY}" "${DMG_PATH}" -vvv
codesign --verify --deep --strict --verbose=2 "${DMG_PATH}"

echo "Submitting for notarization..."
if [[ -n "${NOTARY_PROFILE}" ]]; then
  xcrun notarytool submit "${DMG_PATH}" --keychain-profile "${NOTARY_PROFILE}" --wait
else
  xcrun notarytool submit "${DMG_PATH}" \
    --apple-id "${APPLE_ID}" \
    --team-id "${APPLE_TEAM_ID}" \
    --password "${APPLE_APP_SPECIFIC_PASSWORD}" \
    --wait
fi

echo "Stapling notarization ticket..."
xcrun stapler staple "${DMG_PATH}"

echo "Verifying Gatekeeper assessment..."
spctl -a -t open --context context:primary-signature -v "${DMG_PATH}"

echo
echo "Done."
echo "Notarized artifact: ${DMG_PATH}"
