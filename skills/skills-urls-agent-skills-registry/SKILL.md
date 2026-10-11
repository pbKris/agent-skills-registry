---
name: skills-urls-agent-skills-registry
description: Set up remote agent-skills-registry for Kilo via skills.urls. Central shared skills source, index.json manifest, per-mode folders. Remote skills untrusted (no inline command exec), lowest discovery priority.
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

- `skills.paths` accepts absolute, `~/`, or relative paths. Trusted only if declared in global `~/.config/kilo/kilo.jsonc`, not in project `.kilo/kilo.jsonc`.
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

Native `skills.urls` does not support mode-specific filtering. Mode-specific folders only work for local `skills.paths` / `~/.kilo/skills-{mode-slug}/`. For remote, use generic skills with "Use in code mode only" in `description`.

Two options:

**Option A — generic:** keep all skills generic but note `Use in code mode only` in `description`. The LLM picks based on description, not folder.

**Option B — separate registries per mode:**

```
skills/       index.json   # generic
skills-code/  index.json
skills-plan/  index.json
```

```jsonc
// ~/.config/kilo/kilo.jsonc - global biar trusted
{
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/pbKris/agent-skills-registry/main/skills/"
    ]
  }
}
```

Kilo merges all three. For true mode filtering you still need a local script symlinking into `~/.kilo/skills-code/`, but for team distribution `urls` is sufficient.

## Generating `index.json`

Never hand-edit `index.json` — descriptions with `"` will break JSON.

Use the generator in `scripts/` (JSON-safe):

```bash
#!/usr/bin/env python3
import json, glob, os, re

root = "skills"
skills = []

for d in sorted(glob.glob(f"{root}/*/")):
    name = os.path.basename(os.path.normpath(d))
    skill_md = os.path.join(d, "SKILL.md")
    if not os.path.exists(skill_md):
        continue
    
    text = open(skill_md, encoding="utf-8").read()
    # ambil description dari frontmatter
    m = re.search(r'^description:\s*(.+)$', text, re.MULTILINE)
    desc = m.group(1).strip() if m else ""
    # potong biar ideal 120-250 char, Kilo max 1024
    desc = desc[:350]

    # list semua file yang mau di-publish (SKILL.md wajib)
    files = ["SKILL.md"]
    # kalau ada references/, assets/, scripts/ tambahin otomatis
    for extra in glob.glob(f"{d}/references/*"):
        if os.path.isfile(extra):
            files.append(os.path.relpath(extra, d))

    skills.append({
        "name": name,
        "description": desc,
        "files": files,
        "version": "1.0.0"
    })

with open(f"{root}/index.json", "w", encoding="utf-8") as out:
    json.dump({"skills": skills}, out, indent=2, ensure_ascii=False)
    out.write("\n")

print(f"Generated {root}/index.json with {len(skills)} skills")
```

Kilo re-fetches automatically whenever a skill's version changes — see plugins/kms/skills/index.json, and get automatic re-fetch whenever index.json's per-skill version bumps.

Push to `main`, bump `version` on changed entries, and Kilo auto re-fetches the cache. Kilo fetches each listed file from {url}/{skill-name}/{file}, atomically replaces its local cache when a skill's version string 

## Verification

Open Kilo and ask `What skills do you have available?` — this is the documented way to confirm skills loaded.