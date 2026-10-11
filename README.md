# Agent Skills Registry

A central repository for sharing and distributing Kilo skills via the `skills.urls` configuration. This repo allows teams to share skills without manual symlinking or copying.

## Overview

This repository serves as a central source for agent skills that can be consumed by Kilo through the `skills.urls` configuration in `kilo.jsonc`. Skills are automatically fetched, namespaced, and cached by Kilo.

## Skills Included

This registry currently contains the following skills:

1. **git-rule** - Enforce industry-standard naming for branch, commit, and tag with developer initial `pbk`. Includes interview workflow, naming conventions, and integration with Matt Pocock skills.

2. **skills-urls-agent-skills-registry** - Set up and maintain a remote agent-skills-registry repo consumable by Kilo via `skills.urls` in kilo.jsonc. Documentation for creating and using this very registry.

3. **gotth-code-reviewer** - Review code, diffs, and pull requests in GOTTH stack projects and produce prioritized evidence-based findings.

4. **gotth-html-converter** - Convert existing UI design (HTML/CSS/JS like jQuery) into working GOTTH application with pixel-faithful visuals and behavior.

5. **gotth-stack** - Provide architecture rules, patterns, and checklists for building web UI with GOTTH stack (Go, templ, Tailwind, HTMX, Alpine).

## Repository Structure

```
agent-skills-registry/
└── skills/
    ├── index.json                    # Manifest file listing all skills
    ├── git-rule/
    │   └── SKILL.md                  # Git workflow rules for pbk
    ├── skills-urls-agent-skills-registry/
    │   └── SKILL.md                  # How to set up this registry
    ├── gotth-code-reviewer/
    │   └── SKILL.md                  # GOTTH code reviewer
    ├── gotth-html-converter/
    │   └── SKILL.md                  # GOTTH HTML converter
    └── gotth-stack/
        └── SKILL.md                  # GOTTH stack builder
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

1. Fetches the remote `index.json` manifest from the URL
2. Downloads and namespaces each listed skill into its own cache subfolder under `~/.cache/kilo/skills/<skill-name>/`
3. Makes skills available for use in agent configurations and prompts

## Notes

- Remote skills are **untrusted** - inline ``!`command``` in SKILL.md files are **not** executed for security
- This differs from local skills in `~/.kilo/skills/` which are trusted
- Remote URLs have the **lowest** priority in skill discovery (local paths and bundled skills win)
- The `index.json` manifest must be at the URL path specified (not the file itself)
- Files are downloaded from `{url}/{skill-name}/{file}` paths
- Skills are automatically re-fetched when their version changes in the manifest

## Contributing

To add new skills to this registry:

1. Create a new directory under `skills/` with your skill name
2. Add a `SKILL.md` file following the Kilo skill format (YAML frontmatter with name/description)
3. Update the `skills/index.json` manifest (can be regenerated using the script in the skills-urls note)
4. Commit changes following the git-rule conventions in this repo
5. Push to main branch and create a version bump if desired

## License

See individual skill files for license information. The git-rule skill is licensed under MIT - pbk.

---

*This README was generated as part of the agent-skills-registry setup.*