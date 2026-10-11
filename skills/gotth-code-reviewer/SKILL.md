---
name: gotth-code-reviewer
description: Review code, diffs, PRs in GOTTH stack (Go, templ, Tailwind, HTMX, Alpine). Prioritized evidence-based findings report. 6-step process, mechanical checks, layer checklists, severity scale. Pairs with gotth-stack.
---

# GOTTH Code Reviewer

Review GOTTH code the way a senior maintainer would: find the problems that will hurt in production or confuse the next developer, explain why, and show the fix. Do not pad the review with taste-based nitpicks.

The rules being enforced live in `gotth-stack/references/gotth-rules.md` (rule IDs, default severities, guardrails, precedence, project overrides). Read it before reviewing, and read `gotth-stack/SKILL.md` for the reasoning behind the rules.

## 1. Review principles

- **Evidence over opinion.** Every finding cites a file and line (or a quoted snippet) and states what breaks. "This feels wrong" is not a finding.
- **Severity decides order.** A reviewer who buries an XSS hole under ten naming nits has failed. Lead with what matters.
- **Review what changed.** For a diff or PR, focus on changed lines and the code they interact with. Mention pre-existing problems only if the change makes them worse or depends on them, and label them "pre-existing".
- **Trace the loop, don't just read lines.** The most common GOTTH bugs sit between layers: an `hx-target` with no matching `id`, a handler returning a full page into a fragment target, a 422 that htmx silently drops. Read the template and its handler together, and follow trigger -> request -> response -> swap.
- **Respect the codebase.** If the repo has an established convention that differs from the skill's suggestions (folder layout, naming, helper functions), follow the repo unless it causes a real defect.
- **Say what is good.** One or two lines on what is done well helps the author keep it. Do not invent praise.

## 2. Process

1. **Scope and context.** Read the Project overrides in the rules file. Identify what is under review: pasted snippet, files, a diff (`git diff main...HEAD`), or the whole repo. Ask nothing if the scope is clear. If the user gave only a vague pointer, review the most recently changed files.
2. **Map the interactions.** For each `hx-*` element in scope, write down (mentally or in notes): trigger, method + URL, handler, response fragment, target, swap. Gaps in this chain are findings.
3. **Run the mechanical checks** from section 4 (grep commands) when you have shell access. They find the cheap, high-confidence issues quickly.
4. **Read for judgment issues** using the layer checklists in section 5.
5. **Verify before claiming.** If you can build or test, run `templ generate`, `go build ./...`, `go vet ./...`, `go test ./...`. Never report "this won't compile" or "this test fails" from guesswork.
6. **Write the report** in the format in section 7.

## 3. Rules being enforced

Source: `gotth-stack/references/gotth-rules.md`. Do not restate or reinterpret the rules from memory; use the file.

- **Cite rule IDs** in every finding (`Rule: HTMX-3`). It makes findings checkable and stops arguments about taste.
- **Start severity from the rule's default** (the `Sev` column), then raise or lower it with evidence from this code. Explain any change in one clause.
- **Read the Project overrides table first.** Behavior that matches a documented override or repo convention is not a finding.
- **Check deviation notes.** A documented, justified deviation is not a finding unless it creates a security risk (`SEC-*`). An undocumented deviation is a finding at the rule's default severity.
- **Guardrails apply to the code under review too.** New JSON endpoints, auth/CSRF changes, new dependencies, hand-edited generated files, and destructive migrations deserve explicit attention even when they look fine.
- **Report issues that no rule covers** only when you can name a concrete failure; label them "no rule ID" and keep them Minor unless the impact is clear.

## 4. Mechanical checks (run when a shell is available)

Run from the repo root. Hits are leads, not verdicts: open each one and confirm.

```bash
# Escaping bypasses
grep -rn "templ\.Raw\|templ\.SafeURL\|template\.HTML" --include=*.templ --include=*.go .

# JSON endpoints serving UI
grep -rn "json\.NewEncoder\|json\.Marshal" internal/handlers

# Client-side fetching or non-htmx HTTP in templates/JS
grep -rnE "fetch\(|axios|XMLHttpRequest|\\$\.ajax" --include=*.templ --include=*.js static/js

# Inline styles/scripts in components
grep -rn "<style" --include=*.templ .
grep -rnE "on(click|submit|change)=" --include=*.templ .

# HTMX requests: then check each for hx-target and hx-swap
grep -rnE "hx-(get|post|put|patch|delete)=" --include=*.templ .

# GET used for mutations
grep -rnE "hx-get=.*(delete|remove|create|update|toggle)" --include=*.templ .

# Dynamic Tailwind class construction (will not be generated)
grep -rnE 'class=\{[^}]*" ?\+|"(bg|text|border|ring)-" ?\+' --include=*.templ .

# Tailwind v4: config file, v3 directives and functions
ls tailwind.config.* postcss.config.* 2>/dev/null
grep -rnE "@tailwind |@config|theme\(|@layer utilities|corePlugins|safelist" --include=*.css --include=*.js --include=*.json . 2>/dev/null | grep -v node_modules

# Tailwind v4: removed or renamed v3 utilities and syntax (leads: confirm in context)
grep -rnE "(bg|text|border|divide|ring|placeholder)-opacity-|flex-(shrink|grow)(-|[\" ])|overflow-ellipsis|outline-none|bg-gradient-to-|-\[--[a-z]|[\" ]![a-z]" --include=*.templ .

# Tailwind v4: source detection problems (templ sources git-ignored?)
git check-ignore -v $(git ls-files --others --cached -- '*.templ') 2>/dev/null

# Tailwind v4: borders/rings without an explicit color (v4 defaults to currentColor)
grep -rnE "class=\"[^\"]*\b(border|divide-[xy]|ring)\b[^\"]*\"" --include=*.templ . | grep -vE "(border|divide|ring)-(\w+-)?(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|white|black|transparent|current|brand|ink)"

# Redirects that break HTMX
grep -rn "http\.Redirect" internal/handlers

# Generated files changed without their source
git diff --name-only | grep "_templ.go"

# Ignored render errors
grep -rnE "^\s*(\w+\.)?\w+\(.*\)\.Render\(" internal/handlers

# Architecture: layering violations (store/models importing views or handlers)
grep -rn "internal/views\|internal/handlers" internal/store internal/models

# Architecture: DB or store access inside components
grep -rn "sql\.\|store\.\|db\." --include=*.templ .

# Architecture: context and lifecycle smells
grep -rn "context\.Background()\|context\.TODO()" internal/handlers
grep -rn "func init()" --include=*.go .
grep -rn "http\.ListenAndServe(" --include=*.go .   # no timeouts / graceful shutdown

# Architecture: unstructured logging in request paths
grep -rn "fmt\.Print\|log\.Print" internal/handlers
```

Also confirm: `[x-cloak]` rule exists in `input.css` if `x-cloak` is used; `.templ` files are not git-ignored (Tailwind v4 skips ignored files) and `@source` covers any extra directories; an `htmx:beforeSwap` handler exists if any handler returns 4xx fragments.

## 5. Layer checklists

### 5.1 Go handlers

- Returns a fragment for HTMX requests and a full page for direct navigation, or is only ever used as a fragment endpoint. Boosted requests (`HX-Boosted`) get a full page.
- Status code is set **before** the first write; `Render` errors are checked and logged.
- Validation failures return 422 (or 400) with the re-rendered form, not a redirect and not 200 with an error banner that hides the problem from tests.
- HTMX requests that need navigation use `HX-Redirect` / `HX-Location`, not `http.Redirect`.
- Delete with `outerHTML` returns 200 + empty body (204 does not swap).
- State-changing handlers sit behind CSRF middleware and check authorization for the specific resource (look for IDOR: does it verify the item belongs to the user?).
- No DB calls or business logic inside `.templ` files; handlers prepare the view model.
- `r.ParseForm()` errors handled; input trimmed and validated server-side.
- Context passed to store calls (`r.Context()`), so cancelled requests stop work.
- Caching: responses that vary on `HX-Request` set `Vary: HX-Request`.

### 5.2 templ components

- Typed parameters; no `map[string]any`, no `interface{}` props.
- Stable unique `id` on every element that is targeted, swapped, or OOB-updated.
- IDs and URLs built with `fmt.Sprintf` / `strconv`, not raw concatenation of non-strings.
- No `templ.Raw` on user-influenced data; no `<script>` bodies built from user data (`templ.JSONScript` / `templ.JSONString` instead).
- Fragment returned by a handler is the same component the full page composes, so they cannot drift.
- Repeated markup extracted into components rather than copy-pasted.
- Forms have `action` and `method` so they work without JS; inputs have `<label>`s; buttons have `type`.

### 5.3 HTMX attributes

For every request element verify:

| Check | Typical failure |
|---|---|
| `hx-target` explicit and the target `id` exists in the DOM | Typo in id, target only exists on a different page |
| `hx-swap` explicit and consistent with what the handler returns | Handler returns a `<tr>` but swap is `innerHTML` on the `<table>` |
| Response root matches swap mode | `outerHTML` swap but response has no element with the target's id, or has two roots |
| Method matches intent | `hx-get` mutating data; `hx-post` for a pure read |
| Trigger is sane | Missing `delay:` on `input` triggers; `every Ns` polling never stopped |
| Error path exists | 4xx fragments never swap; no `htmx:responseError` fallback |
| Indicator present | No `.htmx-request` styling on slow actions; double-submit possible |
| History | Filterable/paged views missing `hx-push-url`; boosted forms breaking back button |
| OOB | `hx-swap-oob` element's id missing from the page; OOB markup rendered in the initial page too |
| Table rows | Returning `<tr>` inside a non-table context (browsers drop it when parsed outside `<tbody>`) |
| `hx-confirm` | Missing on destructive actions |

### 5.4 Alpine.js

- No `fetch`, `$fetch`, or manual XHR. Flag as **Major**.
- No server data duplicated into `x-data` and then edited as if authoritative.
- No `Alpine.store` holding domain data; cross-component communication goes through `HX-Trigger` events or the DOM.
- `x-cloak` used with its CSS defined.
- Component stays small. More than ~15 lines of logic suggests moving work to the server or to native `<details>`/`<dialog>`/CSS.
- Alpine element is not the swap target of an HTMX request unless losing its state is intended.

### 5.5 Tailwind v4

The project is Tailwind v4, CSS-first, with **no config file**. Review against rules `TW-1` to `TW-10`.

- **No `tailwind.config.js`** (or `.ts`/`.cjs`) and no `@config` unless the Project overrides record an exception. Config lives in the CSS entry file (`@theme`, `@utility`, `@custom-variant`). Creating a config file is a guardrail event: **Major**.
- **v3 syntax in CSS:** `@tailwind base/components/utilities`, `theme(...)`, `@layer utilities` used to define custom utilities, `corePlugins`, `safelist`. Replacement: `@import "tailwindcss"`, `var(--color-*)`, `@utility`, `@source inline()`.
- **v3 utility names or syntax in `.templ`:** removed or renamed utilities (`bg-opacity-*`, `flex-shrink-*`, `overflow-ellipsis`, `outline-none` used for focus styling, bare `shadow`/`rounded`/`blur`/`ring` or `-sm` variants carried over from v3 with their old look), `bg-gradient-to-*`, `bg-[--var]`, `!flex` (important prefix), stacked variants in v3 order. When code was ported from v3 or legacy CSS, check that `shadow-sm`, `rounded-sm`, and `ring` still look as intended.
- **Changed defaults:** `border-*`/`divide-*` and `ring-*` without an explicit color, buttons assumed to have `cursor: pointer`, reliance on v3 placeholder color, native `<dialog>` without the margin reset, essential actions that only appear on `hover:`.
- **Source detection:** classes are complete literal strings (TW-2); `.templ` files and folders are not git-ignored; extra directories use `@source`; legacy or vendored folders that contain class-like tokens are excluded with `@source not`.
- **Tokens:** repeated values are `@theme` tokens, not arbitrary values (`w-[347px]`); custom CSS reads tokens via `var(--...)`.
- **Entry file hygiene:** custom CSS lives only in `@layer base`, `@layer components`, or `@utility`. Any unlayered CSS that is meant to be overridden by utilities is a bug, because unlayered styles beat layered ones in the cascade.
- **Pipeline:** no Sass/Less/Stylus, no PostCSS/Autoprefixer left over from v3, no hand-edited `output.css`.
- **Browser support:** if the product states support for browsers older than Safari 16.4 / Chrome 111 / Firefox 128, flag it as **Major** (v4 cannot serve them).
- **Accessibility:** focus-visible styles with an explicit ring color, accessible names on icon buttons, `aria-live` on OOB message regions.

### 5.6 Security (always check, even if not asked)

- XSS: escaping bypasses, user data in `<script>`, `href` built from unvalidated input.
- CSRF token wired through `hx-headers` or equivalent and validated server-side.
- AuthN/AuthZ enforced per handler, including fragment endpoints that are "only called by the UI". Anyone can call them with curl.
- No secrets, internal errors, or stack traces rendered into fragments.
- Mutations are not reachable via GET.

### 5.7 Tests

- Handler tests send `HX-Request: true` and assert: status, relevant `HX-*` headers, fragment contains expected markup, and does **not** contain `<html`.
- Validation path (422) and empty state covered.
- Escaping test with hostile input (`<script>alert(1)</script>`).
- Missing tests are a finding only for new behavior, scaled to risk. Do not demand tests for trivial markup.

### 5.8 Architecture (application level)

Scale the depth to the scope. For a small diff, flag architecture only when the change introduces or worsens the problem. For a whole-repo or large-PR review, check everything below. Architecture findings are usually **Major** or **Minor**; they become **Blocker** only when they cause data corruption, import cycles, or a security gap.

**Dependency direction and layering**
- Dependencies point one way: `handlers -> store/service -> models`. `views` depend on `models` or view models only. `store` and `models` never import `views` or `handlers`.
- No import cycles; no package named `utils`/`common` that everything depends on and that depends on everything.
- Handlers stay thin: parse, validate, call store/service, pick the fragment. Business rules longer than a few lines, or reused by several handlers, belong in a service/domain layer. Do not demand a service layer for plain CRUD.
- Views receive ready-made data. A component that calls the store per row is both a layering violation and an N+1 query.

**Persistence boundaries**
- Handlers depend on small interfaces defined where they are consumed, not on `*sql.DB` or a concrete ORM type directly.
- Multi-step writes run in a transaction. Missing transaction around related writes is a **Major** (Blocker if it can corrupt data).
- `context.Context` flows from `r.Context()` into every store call; no `context.Background()` inside request paths.

**Routing and middleware**
- Routes are grouped per resource and registered in one place; no handler registers itself via `init()`.
- Middleware order is deliberate: recover -> request ID -> logging -> CSRF -> auth. Auth and CSRF are applied to route groups, not sprinkled per handler where one can be forgotten.
- Static assets are served with cache headers (and fingerprinted names or a version query when they change).

**Error handling**
- One central helper maps errors to status code plus an error fragment (toast or inline message). Handlers do not each invent their own.
- Use sentinel or typed errors with `errors.Is/As` to tell "not found", "invalid", and "internal" apart. Do not leak internal error text into HTML.
- Log an error once, at the boundary where it is handled, not at every layer it passes through.

**Configuration and lifecycle**
- Config loaded once at startup (env or file), validated, and passed explicitly. No package-level mutable globals, no config reads inside handlers.
- `http.Server` has timeouts (`ReadHeaderTimeout` at minimum) and graceful shutdown on SIGTERM.
- No side-effect work in `init()` beyond registering static things.

**Observability**
- Structured logging (`log/slog`) with a request ID; no `fmt.Println` in request paths.
- Logs never contain secrets, tokens, or full form bodies.
- Health endpoint exists if the app is deployed behind a load balancer or orchestrator.

**Performance and scalability (HTMX-specific)**
- Lists are paginated or limited; no unbounded `SELECT *` rendered into a table.
- N+1 queries when rendering lists: look for store calls inside loops or inside components.
- Polling (`every Ns`) uses sensible intervals, stops when no longer needed, and does not hit expensive queries.
- Rapid triggers (search input, double clicks) are controlled with `delay:`, `hx-sync`, or disabling during `.htmx-request`, so older responses cannot overwrite newer ones.
- Small updates return small fragments plus OOB patches, not a re-rendered full page.
- Fragment contracts stay stable: element `id`s and swap modes that other templates or handlers depend on are not changed casually; shared components are not coupled to a single handler.

**Restraint**
- Do not push abstraction for its own sake (repositories for every table, DI frameworks, generic base handlers). Flag over-engineering when it adds indirection with no concrete benefit in this codebase.

## 6. Severity scale

Per-rule default severities are in the rules file. The scale below defines what each level means.

| Level | Meaning | Examples |
|---|---|---|
| **Blocker** | Security hole, data loss, crash, or feature does not work | `templ.Raw` on user input; missing authorization on delete; handler returns full page into a fragment target; CSRF absent on mutations |
| **Major** | Breaks a core rule or will cause bugs soon | JSON endpoint for UI; Alpine `fetch`; 422 never swapped; 302 on HTMX request; missing `hx-target` with ambiguous inheritance; dynamic Tailwind classes; N+1 queries in list rendering; related writes without a transaction; `store` importing `views` |
| **Minor** | Works but is fragile, inconsistent, or hard to maintain | Missing indicator; no `hx-confirm` on delete; ignored `Render` error; loose typing; duplicated markup |
| **Nit** | Style or preference | Class ordering, naming, comment wording |

Calibration: if you hesitate between two levels, choose the lower one and explain the uncertainty. Over-escalating destroys trust in the review.

## 7. Output format

Use this structure. Omit empty sections. Keep the whole report proportional to the change: a 20-line diff does not need 15 findings.

````markdown
## Review summary
**Verdict:** Approve | Approve with comments | Request changes | Block
**Scope:** <files/diff reviewed>  **Verified:** <commands run and results, or "read-only review, nothing executed">

One short paragraph: what the change does and the overall quality.

## Blockers
### 1. <short title>: `path/to/file.templ:42`
**Rule:** `HTMX-3` (default severity Major; raised/lowered because ...)
**Problem:** what is wrong, concretely.
**Why it matters:** the failure scenario (what the user or attacker sees).
**Fix:**
```templ
// minimal corrected code
```

## Major
...same format...

## Minor
- `path:line` [`RULE-ID`]: issue. Fix: one line.

## Nits
- one line each, optional

## What looks good
- one or two items
````

Verdict rules: any Blocker -> **Block** or **Request changes**; Majors only -> **Request changes**; Minors only -> **Approve with comments**; nothing -> **Approve**.

## 8. Worked example

Input under review:

```templ
templ Row(item models.Item) {
    <tr>
        <td>{ item.Name }</td>
        <td>
            <button hx-get={ "/items/" + item.ID + "/delete" }>Delete</button>
        </td>
    </tr>
}
```

Good findings (condensed):

- **Blocker: mutation via GET** (`hx-get=".../delete"`). Link prefetchers, crawlers, and CSRF make GET deletion unsafe. Fix: `hx-delete`, plus CSRF token via `hx-headers` on `<body>`.
- **Major: no `hx-target`/`hx-swap`.** The response will replace the button's inner content, not the row. Fix: give the `<tr>` an `id`, use `hx-target="#item-<id>" hx-swap="outerHTML"`, and have the handler return `200` with an empty body.
- **Major: `"/items/" + item.ID` does not compile if `ID` is an int.** Use `fmt.Sprintf("/items/%d", item.ID)`.
- **Minor: no `hx-confirm`, no `type="button"`, no loading state.**

Note what the review did *not* do: it did not comment on class names, comment style, or hypothetical future features.

## 9. Do not flag (common false positives)

- `templ.Raw` on a constant string or output of a vetted sanitizer, when a comment explains it.
- Full-page responses from routes designed for direct navigation.
- `hx-swap` omitted when the repo deliberately relies on `innerHTML` default **and** consistently does so (mention as a Nit at most).
- Inherited `hx-target` on a form that swaps itself (explicitly allowed in the rules).
- Small Alpine state (open/closed, active tab, copy-to-clipboard feedback).
- Third-party JSON endpoints under `/api/` that the user explicitly requested.
- Handlers calling the store directly in small or CRUD-only apps (a service layer would be over-engineering).
- Missing observability or graceful shutdown in a prototype the user labels as a spike, unless it is headed to production (mention once as a Minor).
- Generated `*_templ.go` files appearing in the diff alongside their `.templ` source changes (only flag them if hand-edited or out of sync).

## 10. Style of feedback

- Be direct and specific. Prefer "`hx-target` is missing, so the response replaces the button's content" over "consider adding a target".
- Explain impact in terms of user-visible behavior or attacker capability.
- Give the smallest fix that works, as code the author can paste. Offer larger refactors as suggestions, clearly separated from required changes.
- If you cannot verify something (e.g. you cannot see the handler for a template), say so and state what you assumed. Never present an assumption as a finding.
- When the user's goal is debugging ("why doesn't my swap work?"), skip the full report. Trace the loop, name the most likely cause first, and give the fix. Offer the full review afterwards.