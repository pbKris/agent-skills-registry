# Agent Skills Registry

A central repository for sharing and distributing Kilo skills via the `skills.urls` configuration. This repo allows teams to share skills without manual symlinking or copying.

## Overview

This repository serves as a central source for agent skills that can be consumed by Kilo through the `skills.urls` configuration in `kilo.jsonc`. Skills are automatically fetched, namespaced, and cached by Kilo under `~/.cache/kilo/skills/<skill-name>/`.

## Skills Included

This registry contains the following skills (listed by priority, lowest to highest):

1. **git-rule** - Enforce industry-standard naming for branch, commit, and tag with developer initial `pbk`. Includes interview workflow, naming conventions (branch type/scope-desc-pbk, commit Conventional Commits, annotated tags vN-baseline-context-pbk), and integration with Matt Pocock skills (`/grill-with-docs`, `/to-spec`, `/to-tickets`, `/tdd`, `/code-review`, `/retro`). **Use when user types `/git-rule` or says "cek git rule", "buat branch baru", or "mau commit"**. Remote skills are untrusted - inline ``!`command``` in SKILL.md is **not** executed. This differs from `~/.kilo/skills/` which is trusted.

2. **skills-urls-agent-skills-registry** - Set up and maintain a remote agent-skills-registry repo consumable by Kilo via `skills.urls` in kilo.jsonc. Documents the `index.json` manifest shape (`name`, `description`, `files`), repo structure (`skills/index.json` with skill folders containing `SKILL.md`), URL rules (folder not file, trailing `/`, name must match folder), and per-mode folders (`skills-code`, `skills-plan`). **Use when user wants central shared skills source, publish skills from registry, or structure index.json manifest**. Also explains that remote URLs have the lowest discovery priority.

3. **gotth-code-reviewer** - Review code, diffs, and pull requests in GOTTH stack projects and produce prioritized evidence-based findings. **Use when user asks to review, audit, critique, or says "is this right?" or "why doesn't my swap work?"**.

4. **gotth-html-converter** - Convert existing UI design (HTML/CSS/JS like jQuery) into working GOTTH application with pixel-faithful visuals and behavior. **Use when user wants to convert HTML/design to templ/Go/HTMX or replace jQuery with HTMX/Alpine**.

5. **gotth-stack** - Provide architecture rules, patterns, and checklists for building web UI with GOTTH stack (Go, templ, Tailwind, HTMX, Alpine). **Use when user works on Go web app rendering HTML server-side or mentions templ, HTMX, Alpine, or Tailwind**.

## Repository Structure

```
agent-skills-registry/
├── .git/                     # Git repository (initialized with conventional commits)
├── README.md                 # This file
├── skills/
│   ├── index.json            # Manifest - valid JSON with skills array
│   ├── git-rule/
│   │   ├── SKILL.md          # Git workflow rules for pbk
│   │   └── git-convention-note.md
│   ├── skills-urls-agent-skills-registry/
│   │   ├── SKILL.md          # How to set up this registry
│   │   └── skills-urls-agent-skills-registry-note.md
│   ├── gotth-code-reviewer/
│   │   └── SKILL.md          # GOTTH code reviewer
│   ├── gotth-html-converter/
│   │   └── SKILL.md          # GOTTH HTML converter
│   └── gotth-stack/
│       ├── SKILL.md          # GOTTH stack builder
│       └── gotth-skills-rules-note.md
└── scripts/
    └── index-json-generator.sh  # Script to regenerate index.json (now escapes JSON special chars)
```

## Usage

To use skills from this registry in your Kilo configuration:

1. Add the registry URL to your `kilo.jsonc` (typically in `~/.config/kilo/kilo.jsonc`):

```jsonc
{
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/your-username/agent-skills-registry/main/skills"
    ]
  }
}
```

2. Restart Kilo or reload configuration
3. Verify skills are loaded by asking: "What skills do you have available?"
4. Use skills by referencing them in your prompts or agent configurations

## How It Works

When Kilo encounters a `skills.urls` configuration:

1. **Fetches** the remote `index.json` manifest from the URL path (not the file itself)
2. **Downloads** and namespaces each listed skill into its own cache subfolder under `~/.cache/kilo/skills/<skill-name>/`
3. **Makes skills** available for use in agent configurations and prompts

**Priority order** (highest to lowest):
1. Local paths via `skills.paths` in kilo.jsonc
2. Bundled skills in the repo
3. **Remote URLs via `skills.urls`** (lowest priority, untrusted)

## Notes

- **Remote = untrusted**: inline ``!`command``` in SKILL.md is **not** executed for security
- This differs from local skills in `~/.kilo/skills/`, which are trusted
- Remote URLs have the **lowest** priority in skill discovery (local paths and bundled skills win)
- The `index.json` manifest must be at the URL-specified path (not at the root URL)
- Files are downloaded from `{url}/{skill-name}/{file}` paths
- Skills are **automatically re-fetched** when a skill's version changes in the manifest
- **JSON validity is critical**: the `index.json` must be valid JSON - the generator script now properly escapes special characters (quotes, backslashes) in description fields

## Contributing

To add new skills to this registry:

1. Create a new directory under `skills/` with your skill name
2. Add a `SKILL.md` file following the Kilo skill format (YAML frontmatter with `name` and `description`)
3. Run `bash scripts/index-json-generator.sh` to regenerate the `index.json` manifest
4. Commit changes following the git-rule conventions in this repo (conventional commits)
5. Push to main branch and create a version bump if desired (annotated tag: `vN-baseline-context-pbk`)

## License

See individual skill files for license information. The git-rule skill is licensed under MIT - pbk.

---

*This README was generated/updated as part of the agent-skills-registry setup.*