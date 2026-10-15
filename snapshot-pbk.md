# Repo Structure Snapshot — agent-skills-registry
**Date:** 2026-10-14  
**URL:** https://github.com/pbKris/agent-skills-registry  
**Commit:** `1127004` (chore(repo-structure): restructure repo for production)
**Branch:** `main` (synced with `origin/main`)  
**Tag baseline:** `v0-baseline-start-pbk`

---

## Directory Tree

```
.
├── .gitignore
├── .kilo/
│   └── kilo.jsonc
├── .vscode/
│   └── settings.json
├── agents/
│   ├── docs/
│   │   └── system-designer-note.md
│   └── system-designer.md
├── docs/
│   └── propagasi-cdn-note.md
├── rules-code/
│   ├── code-philosophy.md
│   └── docs/
│       └── code-philosophy-note.md
├── rules-system-designer/
│   ├── design-philosophy.md
│   └── docs/
│       └── design-philosophy-note.md
├── skills-ask/
│   └── docs/
│       ├── analisa-skills-ask-vs-skills-system-designer.md
│       └── skills-ask-note.md
├── skills-code/
│   └── docs/
│       └── skills-code-note.md
├── skills-debug/
│   └── docs/
│       └── skills-debug-note.md
├── skills-plan/
│   └── create-plan/
│       └── SKILL.md
├── skills-system-designer/
│   └── docs/
│       └── skills-system-designer-note.md
└── skills/
    ├── git-convention/
    │   ├── SKILL.md
    │   ├── docs/
    │   │   └── git-convention-note.md
    │   └── references/
    │       └── submodule-vendor.md
    ├── go/
    │   ├── SKILL.md
    │   ├── index-go.md
    │   └── references/
    │       ├── 01-core-principles.md
    │       ├── 02-package-organization.md
    │       ├── 03-interface-design.md
    │       ├── 04-concurrency.md
    │       ├── 05-error-handling.md
    │       ├── 06-testing.md
    │       ├── 07-generics.md
    │       ├── 08-stdlib-modern.md
    │       ├── 09-http-server.md
    │       └── 10-syntax-modern.md
    ├── gotth-code-reviewer/
    │   └── SKILL.md
    ├── gotth-html-converter/
    │   ├── SKILL.md
    │   └── references/
    │       ├── css-conversion.md
    │       ├── jquery-to-gotth.md
    │       ├── note.md
    │       ├── source-stack-profile.md
    │       └── visual-regression.md
    └── gotth-stack/
        ├── SKILL.md
        ├── gotth-stack-skills-rules-note.md
        └── references/
            └── gotth-rules.md
```

---

## Git Status
- Working tree: **clean**
- Local `main` = `origin/main`
- No pending commits or untracked files