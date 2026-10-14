#!/usr/bin/env bash
set -e

# Link agentic files directories from the repository into .kilo/
# Reads .kilo/agent-files.manifest for list of directory names.

SCRIPT_DIR="$(dirname "$0")"
MANIFEST="${SCRIPT_DIR}/agent-files.manifest"
LINK_BASE="${SCRIPT_DIR}"  # .kilo directory

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

while IFS= read -r dir || [[ -n "$dir" ]]; do
  # Skip empty lines and comments
  [[ -z "$dir" || "$dir" =~ ^[[:space:]]*# ]] && continue
  target="../$dir"  # relative to .kilo/
  link="$LINK_BASE/$dir"
  if [[ -e "$link" || -L "$link" ]]; then
    # Remove existing link or directory
    rm -rf "$link"
  fi
  ln -s "$target" "$link"
  echo "Linked $dir"
done < "$MANIFEST"