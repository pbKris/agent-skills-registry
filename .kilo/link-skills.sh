#!/usr/bin/env bash
set -e

# Link skills from the repository's skills directory into .kilo/skills/
# Reads .kilo/skills.manifest for list of skill names.

SCRIPT_DIR="$(dirname "$0")"
MANIFEST="${SCRIPT_DIR}/skills.manifest"
SKILLS_SOURCE="../skills"  # relative to .kilo/
LINK_DIR="${SCRIPT_DIR}/skills"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

mkdir -p "$LINK_DIR"

while IFS= read -r skill || [[ -n "$skill" ]]; do
  # Skip empty lines and comments
  [[ -z "$skill" || "$skill" =~ ^[[:space:]]*# ]] && continue
  target="${SKILLS_SOURCE}/${skill}"
  link="${LINK_DIR}/${skill}"
  if [[ -e "$target" ]]; then
    # Remove existing link or directory
    rm -rf "$link"
    ln -s "$target" "$link"
    echo "Linked $skill"
  else
    echo "Warning: skill source not found: $target" >&2
  fi
done < "$MANIFEST"