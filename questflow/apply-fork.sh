#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

git submodule update --init api front

for component in api front; do
  if [[ -n "$(git -C "$component" status --porcelain)" ]]; then
    echo "The $component submodule must be clean before applying the fork patch." >&2
    exit 1
  fi
  git -C "$component" apply --check "$root_dir/questflow/patches/$component.patch"
done

for component in api front; do
  git -C "$component" apply "$root_dir/questflow/patches/$component.patch"
done

echo "Questflow patches applied to the pinned Lago submodules."
