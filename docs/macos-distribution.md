# macOS Distribution

This repository can build an unsigned macOS app out of the box, but distributing it to other Macs smoothly requires:

- a `Developer ID Application` certificate in your keychain
- notarization credentials for `notarytool`

## 1. Required Apple-side setup

- Create or download a `Developer ID Application` certificate in Apple Developer and install it into Keychain Access.
- Export the certificate together with its private key if you want to reuse it on another machine.
- Create an Apple ID app-specific password.
- Note your Apple `Team ID`.

Official references:

- https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates/
- https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
- https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool

## 2. Local checks

You should see a `Developer ID Application` identity here:

```bash
security find-identity -v -p codesigning
```

If you only see `Apple Development`, that is not enough for public distribution.

## 3. Store notarization credentials

Recommended once per machine:

```bash
export APPLE_ID="you@example.com"
export APPLE_TEAM_ID="YOURTEAMID"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export NOTARY_PROFILE="DaFuRemoteNotary"

./scripts/macos_store_notary_credentials.sh
```

This stores the credentials in your login keychain so the app-specific password does not need to be repeated for every build.

## 4. Build, sign, and notarize

```bash
export NOTARY_PROFILE="DaFuRemoteNotary"
export MACOS_CODESIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)'

./scripts/macos_build_sign_notarize.sh --flutter --hwcodec --unix-file-copy-paste --screencapturekit
```

The script will:

- build the macOS release app
- sign the `.app`
- create a DMG
- sign the DMG
- notarize the DMG with `notarytool`
- staple the notarization ticket

If you already built the app and only want to sign/notarize it:

```bash
SKIP_BUILD=1 \
NOTARY_PROFILE="DaFuRemoteNotary" \
MACOS_CODESIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
./scripts/macos_build_sign_notarize.sh
```

## 5. Output

The notarized installer will be created in the repository root:

```bash
DaFuRemote-<version>-macos-<arch>.dmg
```

## 6. Bundle identifier

The macOS bundle identifier is aligned to:

```text
cn.xiaole888.yc.dafuremote
```

Relevant files:

- `flutter/macos/Runner/Configs/AppInfo.xcconfig`
- `flutter/macos/Runner.xcodeproj/project.pbxproj`
- `Cargo.toml`
