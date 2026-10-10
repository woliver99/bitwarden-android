#!/usr/bin/env bash
set -euo pipefail

# Default to latest *-bwpm tag or v2026.9.1-bwpm
DEFAULT_TAG=$(git tag -l 'v*-bwpm' --sort=-v:refname | head -n 1)
TARGET_TAG="${1:-${DEFAULT_TAG:-v2026.9.1-bwpm}}"
PR_BRANCH="${2:-fix/autofill-save-org-policy}"

echo "=================================================="
echo "Target Tag: $TARGET_TAG"
echo "PR Branch:  $PR_BRANCH"
echo "=================================================="

# Fetch latest tags from upstream if available
if git remote | grep -q '^upstream$'; then
    echo "Fetching tags from upstream..."
    git fetch upstream --tags --quiet || true
fi

# Switch to PR branch and rebase
echo "Rebasing $PR_BRANCH onto $TARGET_TAG..."
git checkout "$PR_BRANCH"
git rebase "$TARGET_TAG"

# Rebase personal-build onto PR branch
echo "Rebasing personal-build onto $PR_BRANCH..."
git checkout personal-build
git rebase "$PR_BRANCH"

echo ""
echo "Rebase successful! Proceeding to build..."
echo "=================================================="

# Run build script with any remaining arguments
./build.sh "${3:-}"
