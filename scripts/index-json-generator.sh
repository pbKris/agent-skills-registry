#!/bin/bash
json_escape() {
  # Escape backslashes first, then double quotes
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}
cd skills
echo '{ "skills": [' > index.json
first=1
for d in */; do
  name=$(basename "$d")
  desc=$(grep -m1 "description:" "$d/SKILL.md" 2>/dev/null | sed 's/description: //')
  [ $first -eq 1 ] && first=0 || echo "," >> index.json
  first=0
  escaped_desc=$(json_escape "$desc")
  echo " {\"name\": \"$name\", \"description\": \"$escaped_desc\", \"files\": [\"SKILL.md\"]}" >> index.json
done
echo '] }' >> index.json