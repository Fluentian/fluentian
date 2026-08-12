#!/usr/bin/env bash
# Bumps the build number, then produces a release build.
# Usage: scripts/build_release.sh [appbundle|apk]   (default: appbundle)
set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-appbundle}"

./scripts/bump_build_number.sh
flutter build "$TARGET" --release

echo ""
echo "Done. Current version:"
grep '^version:' pubspec.yaml
