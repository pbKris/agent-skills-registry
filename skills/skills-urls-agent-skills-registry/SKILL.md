---
name: skills-urls-agent-skills-registry
description: Set up and maintain a remote agent-skills-registry repo consumable by Kilo via `skills.urls` in kilo.jsonc. Use when the user wants a central shared skills source without symlinking or copying skills into every project, wants to publish skills from a registry repo over agents skills on Github, wants to structure an `index.json` manifest, wants per-mode skill folders (skills-code, skills-plan), or asks how Kilo fetches and namespaces remote skills. Also use when explaining that remote skills are untrusted (inline ``!`command``` in SKILL.md is not executed) and that remote URLs have the lowest discovery priority.
---

# Skills URLs Agent Skills Registry

Central-source alternative to `ln -s` / `cp -R`: declare remote skill directories in `kilo.jsonc` and Kilo fetches, namespaces, and caches them under `~/.cache/kilo/skills/<plugin-name>/`.

## How Kilo loads remote skills

In `kilo.jsonc`:

```jsonc
{
  "skills": {
    "paths": ["/path/to/shared/skills", "~/my-skills"],
    "urls": ["https://example.com/.well-known/skills/"]
  }
}
```

- `skills.paths` accepts absolute paths (local, trusted).
- `skills.urls` accepts URLs to remote skill directories that serve an `index.json` manifest.

The remote server must serve `index.json` at the URL path with this shape:

```json
{
  "skills": [
    { "name": "skill-name", "files": ["SKILL.md", "references/file.md"] }
  ]
}
```

Docs now require `name`, `description`, and `files` fields. Files are downloaded from `{url}/{skill-name}/{file}` paths.

Flow: point `skills.urls` at the parent folder containing `index.json` → Kilo fetches the manifest → downloads and namespaces each listed skill into its own cache subfolder.

Priority: remote URLs are the **lowest** discovery priority (local paths and bundled skills win).

Trust: remote = untrusted, so inline ``!`command` `` in a remote `SKILL.md` is **not** executed. This differs from `~/.kilo/skills/`, which is trusted.

## Repo structure Kilo understands

Prefer `raw.githubusercontent.com`:

```
agent-skills-registry/
└── skills/
    ├── index.json
    ├── my-frontend/
    │ └── SKILL.md          # name: my-frontend
    ├── api-design/
    │ └── SKILL.md
    └── typescript-patterns/
        ├── SKILL.md
        └── references/
            └── patterns.md
```

Minimal valid `index.json`:

```json
{
  "skills": [
    {
      "name": "my-frontend",
      "description": "Frontend design guidelines",
      "files": ["SKILL.md"]
    },
    {
      "name": "typescript-patterns",
      "description": "TS patterns for Code mode",
      "version": "1.0.1",
      "files": ["SKILL.md", "references/patterns.md"]
    }
  ]
}
```

`version` is optional but important: Kilo re-fetches automatically when a skill's version changes.

## Config on the consumer side

Global config `~/.config/kilo/kilo.jsonc` (trusted):

```jsonc
{
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills"
    ]
  }
}
```

Real community examples:
- `"urls": ["https://raw.githubusercontent.com/xhighhongo41/agent-skills/main/skills"]`
- `{ "skills": { "urls": ["https://raw.githubusercontent.com/vivantel/kms/master/plugins/kms/skills"] } }`

**URL rules:**
- Point at the folder containing `index.json`, never at the `index.json` file itself.
- Docs use a trailing `/`.
- Files are fetched from `{url}/{skill-name}/{file}`, so the skill folder name must match `name` exactly.

## Per-mode skill folders (`skills-code`, `skills-plan`)

Native `skills.urls` does not support mode-specific filtering. Mode-specific is only documented for local paths via the `skills-{mode-slug}` directory naming pattern.

Two options:

**Option A — generic:** keep all skills generic but note `Use in code mode only` in `description`. The LLM picks based on description, not folder.

**Option B — separate registries per mode:**

```
skills/       index.json   # generic
skills-code/  index.json
skills-plan/  index.json
```

```jsonc
{
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills",
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills-code",
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills-plan"
    ]
  }
}
```

Kilo merges all three. For true mode filtering you still need a local script symlinking into `~/.kilo/skills-code/`, but for team distribution `urls` is sufficient.

## Generating `index.json`

Avoid hand-editing:

```bash
#!/bin/bash
cd skills
echo '{ "skills": [' > index.json
first=1
for d in */; do
  name=$(basename $d)
  desc=$(grep -m1 "description:" $d/SKILL.md | sed 's/description: //')
  [ $first -eq 0 ] && echo "," >> index.json
  first=0
  echo " {\"name\": \"$name\", \"description\": \"$desc\", \"files\": [\"SKILL.md\"]}" >> index.json
done
echo '] }' >> index.json
```

Push to `main`, bump `version` on changed entries, and Kilo auto re-fetches the cache.

## Verification

Open Kilo and ask `What skills do you have available?` — this is the documented way to confirm skills loaded.