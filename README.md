# Agent Skills Registry

A curated collection of specialized AI skills for software engineering tasks. Each skill provides domain-specific guidance, conventions, and best practices for common development workflows.

## Structure

```
├── .kilo/              - Kilo configuration and skill references
├── skills/             - Root skill directories (symlinked to .kilo/skills)
├── .kilo/skills/       - Active skill symlinks
├── agents/             - Agent configurations and setups
├── rules/              - System rules and policies
├── rules-code/         - Rules for specific Mode Code (Kilo native)
├── rules-system-designer/ - Rules for specific Mode/Agent System designer (custom mode)
├── scripts/            - Utility scripts for skill management
├── skills-plan/        - Skill for specific Mode Plan (Kilo native)
├── skills/             - Skill for All Mode / General (Kilo native)
├── scripts/            - Generated and utility scripts
├── SUBMODULE-CATALOG.md - Submodule catalog reference
├── docs/               - Notes in repo
├── .github/            - GitHub Actions and workflows
```

## Available Skills

| Skill | Description | Owner |
|-------|-------------|-------|
| `git-convention` | Git workflow rules: branch naming, commit messages, tag conventions with developer initial enforcement | `pbk` |
| `change-manifest` | Skill manifest and version management | `pbk` |
| `go` | Go language skill with references and best practices | `pbk` |
| `gotth-html-converter` | HTML conversion utilities | - |
| `gotth-stack` | Stack-related development guides | - |
| `gotth-code-reviewer` | Code review automation | - |

## How to Use

Each skill can be invoked via `/<skill-name>` in the CLI. Skills typically follow this protocol:

1. **Interview** - Ask about the task, scope, and requirements
2. **Inspect** - Check workspace status, git history, and conventions
3. **Decision** - Propose solutions following the skill's conventions
4. **Execute** - After user confirmation, perform the work
5. **Guardrails** - Ensure best practices are followed

See individual skill `SKILL.md` files in `.kilo/skills/` or `skills/<name>/` for detailed workflows.

## Installation

```bash
# Clone the registry
git clone <repository-url>

# Skills are auto-discovered via .kilo/skills symlinks
# Or install individually:
mkdir -p .claude/skills/
ln -s path/to/skill/SKILL.md .claude/skills/<name>/SKILL.md
```

## License

MIT - pbkris