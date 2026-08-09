#!/usr/bin/env bash
##
# Load this repo's GitHub Actions secrets from the files on THIS machine, so that
# .github/workflows/release-android.yml can build and upload the app.
#
# Run it once per new app, from the repo root, on a machine that can already build
# and release by hand. That last part is the whole idea: if `fastlane internal`
# works here, every file CI needs is already on this disk.
#
#   bash scripts/bootstrap_ci_secrets.sh
#
# It reads, and never writes, these:
#   assets/config.json                     the dart-defines
#   android/key.properties                 the keystore path and its two passwords
#   the keystore named by storeFile        the upload key
#   android/app/google-services.json       only if the app uses Firebase natively
#   the Play service-account key           found, or given with PLAY_KEY=/path.json
#
# Nothing is printed. A secret that reaches a terminal reaches the scrollback, the
# session log, and whatever is watching the screen.
##
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Setting Actions secrets on $repo"

fail() { echo "  ERROR: $*" >&2; exit 1; }

# --- the dart-defines -------------------------------------------------------
[ -f assets/config.json ] || fail "assets/config.json is missing. Build once by hand first."
python3 -c "import json,sys; json.load(open('assets/config.json'))" \
    || fail "assets/config.json is not valid JSON"
base64 -w0 assets/config.json | gh secret set CONFIG_JSON_BASE64 --repo "$repo"
echo "  CONFIG_JSON_BASE64"

# --- signing ----------------------------------------------------------------
[ -f android/key.properties ] || fail "android/key.properties is missing"

# storeFile is resolved the way Gradle resolves it: relative to android/app.
store_file=$(grep '^storeFile=' android/key.properties | cut -d= -f2-)
case "$store_file" in
  /*) keystore="$store_file" ;;
  *)  keystore="android/app/$store_file" ;;
esac
[ -f "$keystore" ] || fail "keystore not found at $keystore (storeFile=$store_file)"

base64 -w0 "$keystore" | gh secret set ANDROID_KEYSTORE_BASE64 --repo "$repo"
grep '^storePassword=' android/key.properties | cut -d= -f2- | tr -d '\n' \
    | gh secret set ANDROID_KEYSTORE_PASSWORD --repo "$repo"
grep '^keyPassword=' android/key.properties | cut -d= -f2- | tr -d '\n' \
    | gh secret set ANDROID_KEY_PASSWORD --repo "$repo"
echo "  ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_PASSWORD"

# The workflow writes keyAlias=upload. Catch a different alias here rather than in
# a build that fails 15 minutes in with a signing error.
alias_name=$(grep '^keyAlias=' android/key.properties | cut -d= -f2- | tr -d '\n')
if [ "$alias_name" != "upload" ]; then
    echo "  WARNING: keyAlias is '$alias_name', but the workflow writes 'upload'."
    echo "           Edit the key.properties heredoc in release-android.yml to match."
fi

# --- Firebase, only if this app uses it natively ----------------------------
if [ -f android/app/google-services.json ]; then
    base64 -w0 android/app/google-services.json \
        | gh secret set GOOGLE_SERVICES_JSON_BASE64 --repo "$repo"
    echo "  GOOGLE_SERVICES_JSON_BASE64"
fi

# --- the Play key -----------------------------------------------------------
# Every app needs a service account with access to ITS OWN package. Do not assume
# the shared key reaches a new one: Vault Messages needed its own, and the shared
# key answered 403 for it.
play_key="${PLAY_KEY:-}"
if [ -z "$play_key" ]; then
    for candidate in \
        "$GOOGLE_PLAY_JSON_KEY_PATH" \
        "keys/fastlane-key.json" \
        "$HOME/Dev/keys/fastlane_key.json" \
        "$HOME/keys/flutter/fastlane_key.json"
    do
        [ -n "${candidate:-}" ] && [ -f "$candidate" ] && play_key="$candidate" && break
    done
fi
[ -n "$play_key" ] || fail "no Play key found. Re-run with PLAY_KEY=/path/to/key.json"
python3 -c "import json,sys; json.load(open('$play_key'))" || fail "$play_key is not valid JSON"
gh secret set PLAY_SERVICE_ACCOUNT_JSON --repo "$repo" < "$play_key"
echo "  PLAY_SERVICE_ACCOUNT_JSON (from $play_key)"

echo
echo "Done. Push to main, or run: gh workflow run release-android.yml"
echo "Check that the Play key reaches this package BEFORE trusting the first build —"
echo "an upload that 403s wastes a full build."
