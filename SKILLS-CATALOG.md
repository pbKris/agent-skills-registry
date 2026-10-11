# Skills Catalog

Complete catalog of all skills available in this registry.

---

## git-convention

**Purpose**: Enforce industry-standard naming for branch, commit, and tag with developer initial `pbk`.

**Trigger**: User types `/git-convention` or says "cek git rule", "buat branch baru", "mau commit".

**Features**:
- Interview workflow (grill) before creating branch
- Branch naming: `<type>/<scope>-<desc>-pbk` (or `<type>/<ticket>-<scope>-<desc>-pbk`)
- Commit messages: Conventional Commits format `<type>(<scope>): <subject>`
- Tag conventions: Annotated tags `vN-baseline-<context>-pbk`
- Workspace & git health checks before operations
- Baseline tags for milestones

**Integration**: Universal naming conventions compatible with any skill/tool workflow.

**Install**:
```bash
mkdir -p .claude/skills/git-convention/
cp git-convention.md .claude/skills/git-convention/SKILL.md
```
Or: `npx skills@latest add pbk/git-convention`

---

## gotth-code-reviewer

**Purpose**: Review code, diffs, and pull requests in GOTTH stack projects and produce prioritized evidence-based findings.

**Trigger**: User asks to review, audit, critique, or says "is this right?" or "why doesn't my swap work?".

**Features**:
- 6-step review process (scope, map interactions, mechanical checks, layer checklists, verify, report)
- Mechanical grep checks for common issues
- Layer checklists: Go handlers, templ, HTMX, Alpine, Tailwind v4, Security, Tests, Architecture
- Severity scale: Blocker, Major, Minor, Nit
- Standardized output format with verdict
- Debugging mode for "why doesn't this work?" questions

**Pairs with**: gotth-stack (rules), gotth-html-converter (conversion review)

---

## gotth-html-converter

**Purpose**: Convert existing UI design (static HTML, CSS, and JavaScript such as jQuery) into a working GOTTH application with pixel-faithful visuals and working behavior.

**Trigger**: User wants to convert, migrate, port, slice, templatize, or "turn this HTML/design into templ/Go/HTMX", replace jQuery with HTMX/Alpine, move CSS to Tailwind.

**Workflow (7 phases)**:
1. **Inventory** - Audit pages, components, JS behaviors
2. **Tokens & base styles** - Extract design tokens to Tailwind `@theme`
3. **Components** - Convert atoms → molecules → organisms → layouts
4. **Behavior** - Convert JS: Alpine for UI, HTMX for data, vendor islands for complex widgets
5. **Pages & handlers** - Assemble with stub data, connect store later
6. **Verify** - Visual regression (Playwright) + behavior checks
7. **Clean up** - Remove dead code, replace exceptions, code review

**References**: CSS conversion, jQuery→GOTTH mapping, visual regression (Playwright)

**Pairs with**: gotth-stack, gotth-code-reviewer

---

## gotth-stack

**Purpose**: Architecture rules, patterns, and checklists for building web UI with the GOTTH stack (Go, templ, Tailwind CSS v4 CSS-first, HTMX, Alpine.js).

**Trigger**: User works on Go web app rendering HTML server-side, or mentions templ, HTMX, Alpine, Tailwind.

**Core principles**:
- Server owns state, renders HTML; browser stays thin
- Every UI interaction: trigger → hx-* request → Go handler → templ fragment → htmx swap
- No JSON for UI, no `fetch()` in Alpine, no inline styles, no `templ.Raw` on user data

**Key areas**:
- Go handlers (fragments, 422 validation, HX-Redirect, 200 empty body for delete)
- templ components (typed params, stable IDs, fmt.Sprintf for URLs, OOB updates)
- HTMX orchestration (explicit hx-target/hx-swap, proper triggers, indicators, error handling)
- Alpine boundary (local visual state only, no fetch/XHR, x-cloak CSS)
- Tailwind v4 (CSS-first, @theme/@utility/@custom-variant, no config file)
- Security (CSRF via hx-headers, authZ in handlers, no GET mutations)
- Testing (httptest with HX-Request, validation path, escaping)

**Pairs with**: gotth-code-reviewer, gotth-html-converter

---

## skills-urls-agent-skills-registry

**Purpose**: Set up and maintain a remote agent-skills-registry repo consumable by Kilo via `skills.urls` in kilo.jsonc.

**Use when**: User wants central shared skills source, publish skills from registry, or structure `index.json` manifest.

**Documentation covers**:
- `index.json` manifest shape (`name`, `description`, `files`, optional `version`)
- Repo structure (`skills/index.json` with skill folders containing `SKILL.md`)
- URL rules (folder not file, trailing `/`, name must match folder)
- Per-mode folders (`skills-code`, `skills-plan`)
- Generator script for `index.json`
- Verification via "What skills do you have available?"

**Key points**:
- Remote skills are untrusted - inline ``!`command``` not executed
- Remote URLs have lowest discovery priority
- Kilo auto re-fetches when skill version changes

---

## Adding New Skills

To add a new skill to this registry:

1. Create directory: `skills/<skill-name>/`
2. Add `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Include any reference files in `references/` subdirectory
4. Run generator: `python scripts/index-json-generator.py`
5. Update this catalog (SKILLS.md)
6. Commit following git-convention: `chore: add <skill-name> skill`
7. Tag if milestone: `vN-baseline-<context>-pbk`

---

*Last updated: 11 Oct 2026 - Auto-generated from index.json and skill files*