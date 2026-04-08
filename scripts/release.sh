#!/bin/bash
#
# Flutter release script
# Bumps version in pubspec.yaml and runs commit-and-tag-version
#
# Handles Flutter's version+build_number format (e.g., 1.4.0+8)
#
# Usage:
#   ./scripts/release.sh patch|minor|major
#   ./scripts/release.sh patch --dry-run
#   ./scripts/release.sh patch --first-release
#   ./scripts/release.sh patch --reset-build   # resets build number to 1

set -e

BUMP_TYPE="${1:-patch}"
DRY_RUN=""
FIRST_RELEASE=""
RESET_BUILD=false

# Parse additional flags
for arg in "${@:2}"; do
  case $arg in
    --dry-run)
      DRY_RUN="--dry-run"
      ;;
    --first-release)
      FIRST_RELEASE="--first-release"
      ;;
    --reset-build)
      RESET_BUILD=true
      ;;
  esac
done

echo "🚀 Starting Flutter release (bump: $BUMP_TYPE)..."

# Step 1: Parse and bump version in pubspec.yaml
echo "📝 Bumping version in pubspec.yaml..."

CURRENT_LINE=$(grep '^version:' pubspec.yaml)
CURRENT_FULL_VERSION=$(echo "$CURRENT_LINE" | awk '{print $2}' | tr -d "'\"")
CURRENT_VERSION=$(echo "$CURRENT_FULL_VERSION" | cut -d'+' -f1)
CURRENT_BUILD=$(echo "$CURRENT_FULL_VERSION" | cut -d'+' -f2)

# Parse version parts
MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
PATCH=$(echo "$CURRENT_VERSION" | cut -d. -f3)

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "❌ Invalid bump type: $BUMP_TYPE (use patch, minor, or major)"
    exit 1
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

if [ "$RESET_BUILD" = true ]; then
  NEW_BUILD=1
else
  NEW_BUILD=$((CURRENT_BUILD + 1))
fi

if [ -z "$DRY_RUN" ]; then
  sed -i "s/^version:.*/version: ${NEW_VERSION}+${NEW_BUILD}/" pubspec.yaml
fi

echo "✅ New version: ${NEW_VERSION}+${NEW_BUILD} (was ${CURRENT_VERSION}+${CURRENT_BUILD})"

# Step 2: Stage pubspec.yaml and run commit-and-tag-version
echo "🏷️  Running commit-and-tag-version..."

if [ -z "$DRY_RUN" ]; then
  # Stage the version bump so --commit-all includes it
  git add pubspec.yaml
fi

npx commit-and-tag-version \
  --release-as "$NEW_VERSION" \
  --commit-all \
  $DRY_RUN \
  $FIRST_RELEASE

if [ -z "$DRY_RUN" ]; then
  echo "✨ Release ${NEW_VERSION}+${NEW_BUILD} complete!"
else
  echo "🔍 Dry run complete — no changes were made"
fi
