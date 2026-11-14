#!/usr/bin/env bash
# Prefer the current git branch of the caller repository.
# Fall back to PAX_TAG when the branch cannot be determined.
# Usage: tag.sh [repo-dir]
# repo-dir defaults to the current directory, which is the submodule checkout in Actions.
set -eu

root="${1:-.}"

branch=$(git -C "$root" branch --show-current 2>/dev/null || true)
branch=$(printf '%s' "$branch" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Actions checks out a detached commit, so git has no current branch.
if [ -z "$branch" ]; then
  if [ -n "${GITHUB_HEAD_REF:-}" ]; then
    branch=$(printf '%s' "$GITHUB_HEAD_REF" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  elif [ -n "${GITHUB_REF_NAME:-}" ] && [ "${GITHUB_REF:-}" != "${GITHUB_REF#refs/heads/}" ]; then
    branch=$(printf '%s' "$GITHUB_REF_NAME" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  fi
fi

if [ -n "$branch" ]; then
  tag=$branch
else
  tag=$(printf '%s' "${PAX_TAG:-}" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [ -z "$tag" ]; then
    echo "PAX_TAG is not set and the current git branch could not be determined." >&2
    exit 1
  fi
fi

export PAX_TAG="$tag"

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "PAX_TAG=$tag" >> "$GITHUB_ENV"
fi

echo "PAX_TAG: $tag"
