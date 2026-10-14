# Git Submodule Registry

A central repository for sharing and distributing Git submodules. This repo allows teams to share submodules without manual symlinking or copying.

## Overview

This repository serves as a central source for Git submodules that can be consumed by projects through standard Git submodule mechanisms. Submodules are fetched and managed using standard Git commands.

## Submodules Included

See the [Submodule Catalog](SUBMODULE-CATALOG.md) for the complete list of available submodules. Currently includes:

| Submodule | Description |
|-----------|-------------|
| **git-convention** | Enforce industry-standard naming for branch, commit, and tag with developer initial `pbk`. Universal conventions for branch `<type>/<scope>-<desc>-pbk`, commit Conventional Commits, annotated tags `vN-baseline-context-pbk`. **Submodule vendor support** (`references/submodule-vendor.md`). |
| **submodule-manager** | Set up and maintain a remote submodule registry. Documents manifest, repo structure, and usage guidelines. |
| **go-standard** | Go language standard library references and best practices for modern Go development. |
| **gotth-stack** | Provide architecture rules, patterns, and checklists for building web UI with GOTTH stack (Go, templ, Tailwind, HTMX, Alpine). |

> **Note**: Remote submodules are **untrusted** - inline shell commands in documentation are **not** executed for security. This differs from local submodules in `~/projects/submodules/` which are trusted.

## Repository Structure

```
git-submodule-registry/
├── .git/                     # Git repository (initialized with conventional commits)
├── README.md                 # This file
├── SUBMODULE-CATALOG.md      # Detailed submodules catalog
├── submodules/
│   ├── index.json            # Manifest - valid JSON with submodules array
│   ├── git-convention/
│   │   ├── documentation/    # Submodule documentation
│   │   └── .gitmodules       # Optional: nested submodule configuration
│   ├── submodule-manager/
│   │   ├── documentation/    # How to set up this registry
│   │   └── .gitmodules
│   ├── go-standard/
│   │   ├── documentation/    # Go standard library references
│   │   └── .gitmodules
│   └── gotth-stack/
│       ├── documentation/    # GOTTH stack architecture rules
│       └── .gitmodules
└── scripts/
    └── index-json-generator.py  # Python script to regenerate index.json
```

## Usage

To use submodules from this registry in your project:

1. Add the submodule to your project's `.gitmodules` file (typically in your project root):

   ```ini
   [submodule "submodules/git-convention"]
       path = vendor/git-convention
       url = https://raw.githubusercontent.com/your-username/git-submodule-registry/main/submodules/git-convention
   ```

2. Initialize and update submodules:

   ```bash
   git submodule init
   git submodule update
   ```

3. Verify submodules are loaded by checking the `vendor/` directory.
4. Use submodules by referencing them in your project (e.g., import Go packages, use documentation).

## How It Works

When a project references a submodule from this registry:

1. **Fetches** the submodule from the specified URL using standard Git submodule commands
2. **Places** the submodule content into the specified `path` (e.g., `vendor/git-convention`)
3. **Makes submodule** available for use in the project

**Note**: This registry provides a centralized location to discover and reference Git submodules, but the actual submodule management is handled by standard Git commands.

## Contributing

To add new submodules to this registry:

1. Create a new directory under `submodules/` with your submodule name
2. Add the submodule content (documentation, code, etc.) and an optional `.gitmodules` file if it has nested submodules
3. Run `python scripts/index-json-generator.py` to regenerate the `index.json` manifest
4. Commit changes following the git-convention in this repo (conventional commits)
5. Push to main branch and create a version bump if desired (annotated tag: `vN-baseline-context-pbk`)

## License

See individual submodule directories for license information. The git-convention submodule is licensed under MIT - pbk.

---

*This README was generated/updated as part of the git-submodule-registry setup. Last updated: 14 Oct 2026 (git-convention v1.1.0: submodule vendor support)*