# Agent Skills Registry

A curated collection of specialized AI skills for software engineering tasks. Each skill provides domain-specific guidance, conventions, and best practices for common development workflows.

## Structure

```
├── .kilo/              - Kilo configuration (manifest and linking script)
├── agents/             - Agent configurations and setups
├── rules-code/         - Rules for specific Mode Code (Kilo native)
├── rules-system-designer/ - Rules for specific Mode/Agent System designer (custom mode)
├── skills/             - Root skill directories (each skill as subdirectory)
├── skills-plan/        - Skill for specific Mode Plan (Kilo native)
├── scripts/            - Utility scripts for skill management
├── docs/               - Notes in repo
├── .github/            - GitHub Actions and workflows
└── SUBMODULE-CATALOG.md - Submodule catalog reference (optional)
```

## Using as a Git Submodule

To make this registry available as a source of agentic files (skills, agents, rules, etc.) in another Kilo-powered project:

1. Add the registry as a submodule under `.kilo/vendor/` (or any preferred path):
    ```bash
    git submodule add <repository-url> .kilo/vendor/pbk
    ```

2. Run the linking script to create symlinks in `.kilo/` that point to the submodule contents:
    ```bash
    .kilo/vendor/pbk/.kilo/link-agent-files.sh
    ```
    This will create the following symlinks inside `.kilo/`:
    - `agents` → `../vendor/pbk/agents`
    - `rules-code` → `../vendor/pbk/rules-code`
    - `rules-system-designer` → `../vendor/pbk/rules-system-designer`
    - `skills-plan` → `../vendor/pbk/skills-plan`
    - `skills` → `../vendor/pbk/skills`

    (All paths are relative, so they remain valid even if the submodule path changes. Replace `pbk` with your own registry name as needed.)

3. After linking, Kilo will automatically load skills, agents, and rules from the submodule.

## Available Skills

| Skill | Description | Owner |
|-------|-------------|-------|
| `git-convention` | Git workflow rules: branch naming, commit messages, tag conventions with developer initial enforcement | `pbk` |
| `change-manifest` | Skill manifest and version management | `pbk` |
| `go` | Go language skill with references and best practices | `pbk` |
| `gotth-html-converter` | HTML conversion utilities | - |
| `gotth-stack` | Stack-related development guides | - |
| `gotth-code-reviewer` | Code review automation | - |

## How to Use Skills

Each skill can be invoked via `/<skill-name>` in the CLI. Skills typically follow this protocol:

1. **Interview** - Ask about the task, scope, and requirements
2. **Inspect** - Check workspace status, git history, and conventions
3. **Decision** - Propose solutions following the skill's conventions
4. **Execute** - After user confirmation, perform the work
5. **Guardrails** - Ensure best practices are followed

See individual skill `SKILL.md` files in `skills/<name>/` for detailed workflows.

## License

MIT - pbkris