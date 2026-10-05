#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install it and authenticate with 'gh auth login'." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run 'gh auth login' and retry." >&2
  exit 1
fi

if error=$(gh api --silent user/following/jephersonRD 2>&1); then
  echo "GitHub follow check passed."
elif [[ "$error" == *"(HTTP 404)"* ]]; then
  echo "Follow jephersonRD on GitHub with the account authenticated in gh, then retry." >&2
  exit 1
else
  printf 'Unable to verify the GitHub follow status:\n%s\n' "$error" >&2
  exit 1
fi
