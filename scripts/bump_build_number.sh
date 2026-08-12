#!/usr/bin/env bash
# Auto-increments the build number (the +N after the version name) in
# pubspec.yaml. versionName (1.0.0) is left untouched -- that's a
# deliberate choice made when cutting an actual release, not something to
# automate. versionCode (+N) must strictly increase on every single Play
# Console upload, so this is the part worth never hand-editing.
#
# Build number = max(git commit count, current build number + 1). Commit
# count gives full traceability (this build <-> this commit) in the common
# case; the +1 fallback guards against re-uploading from the same commit
# (no new commit yet) still producing a higher number than last time.
set -euo pipefail
cd "$(dirname "$0")/.."

PUBSPEC="pubspec.yaml"
CURRENT_VERSION=$(grep '^version:' "$PUBSPEC" | sed 's/^version: *//')
CURRENT_NAME="${CURRENT_VERSION%%+*}"
CURRENT_BUILD="${CURRENT_VERSION##*+}"

GIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo 0)
NEXT_BUILD_FROM_GIT=$GIT_COUNT
NEXT_BUILD_FROM_CURRENT=$((CURRENT_BUILD + 1))
NEXT_BUILD=$NEXT_BUILD_FROM_GIT
if [ "$NEXT_BUILD_FROM_CURRENT" -gt "$NEXT_BUILD" ]; then
  NEXT_BUILD=$NEXT_BUILD_FROM_CURRENT
fi

NEW_VERSION="${CURRENT_NAME}+${NEXT_BUILD}"
sed -i.bak "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo "Bumped version: ${CURRENT_VERSION} -> ${NEW_VERSION}"
