#!/bin/bash
#
# Flutter release script
# Integrates `dart pub bump` with `commit-and-tag-version`
#
# Usage:
#   ./scripts/release.sh patch|minor|major
#   ./scripts/release.sh patch --dry-run
#   ./scripts/release.sh patch --first-release

set -e

BUMP_TYPE="${1:-patch}"
DRY_RUN=""
FIRST_RELEASE=""

# Parse additional flags
for arg in "${@:2}"; do
  case $arg in
    --dry-run)
      DRY_RUN="--dry-run"
      ;;
    --first-release)
      FIRST_RELEASE="--first-release"
      ;;
  esac
done

echo "🚀 Starting Flutter release (bump: $BUMP_TYPE)..."

# Step 1: Bump version in pubspec.yaml
echo "📝 Bumping version in pubspec.yaml..."
fvm dart pub bump $BUMP_TYPE

# Read the new version
NEW_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | tr -d "'\"" | cut -d'+' -f1)
echo "✅ New version: $NEW_VERSION"

# Step 2: Run commit-and-tag-version with the new version
echo "🏷️  Running commit-and-tag-version..."
npx commit-and-tag-version \
  --release-as "$NEW_VERSION" \
  --skip.bump \
  $DRY_RUN \
  $FIRST_RELEASE

echo "✨ Release $NEW_VERSION complete!"
