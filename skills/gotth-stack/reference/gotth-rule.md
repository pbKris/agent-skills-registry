# GOTTH Rules (shared reference)

Single source of truth for the `gotth-stack` (builder) and `gotth-code-reviewer` (reviewer) skills. Both skills point here instead of repeating rules, so update rules in this file only.

Contents: 1. Precedence · 2. Project overrides · 3. Guardrails · 4. Ask vs assume · 5. Rule catalog (Do / Don't) · 6. Deviation notes

---

## 1. Precedence when instructions conflict

1. **The user's explicit request in the current conversation.**
2. **Project overrides** (section 2) and established repo conventions.
3. **These rules and the two skills.**
4. **Your own defaults.**

If you deviate from level 3 because of levels 1 or 2, say so in one line (section 6). Never silently ignore a rule, and never silently apply one that contradicts what the user asked for.

Security rules (SEC-*) are the exception: if a request conflicts with them, explain the risk and ask for confirmation before proceeding.

---

## 2. Project overrides (fill in per repo)

Agents must not guess these. Read this table first; if a value is blank, inspect the repo (`go.mod`, `package.json`, `Makefile`, existing handlers) and state what you found. Only ask the user if the repo does not answer it.

| Item | Value |
|---|---|
| Go module path | `github.com/<org>/<repo>` |
| Router | chi / echo / net/http (ServeMux) |
| Tailwind | **v4, CSS-first, no config file** (pin the exact 4.x version) |
| Tailwind CLI | standalone binary / `@tailwindcss/cli` (npm) |
| CSS entry file | `static/css/input.css` |
| Browser support | Must stay within Tailwind v4's floor: Safari 16.4+, Chrome 111+, Firefox 128+ |
| htmx / Alpine versions (vendored) | e.g. htmx 2.x, Alpine 3.x |
| ID type (`string`, `int64`, `uuid`) | |
| Database layer | database/sql / sqlc / pgx / GORM |
| Auth strategy | session cookie / JWT / external IdP |
| CSRF mechanism | library or middleware name, header name |
| Logging | `log/slog` / zerolog / zap |
| Build entrypoint | `make dev` / `air` / other |
| Test conventions | table tests / goquery / testify |
| Exceptions to the rules | list, with reason |

---

## 3. Guardrails

### 3.1 Stop and ask before you...

- Add a **JSON endpoint** that serves the UI, or any `/api/...` route.
- Change **authentication, authorization, session, or CSRF** behavior.
- Add a **new dependency**, JS framework, or build tool (React, Vue, another CSS tool, a second bundler).
- Create a `tailwind.config.js`, load a JS config with `@config`, add PostCSS/Autoprefixer, or change the Tailwind major version.
- Run **migrations, destructive SQL, or `rm`/force-push style commands**, or change data in a non-local environment.
- **Rename or delete** public routes, element `id`s, or components that other templates depend on.
- Touch **more files than the task needs** (broad refactors, mass reformatting, moving packages).
- Use `templ.Raw` or `templ.SafeURL` on anything that could be user-influenced.
- Disable a check (lint rule, test, CSRF on a route) to make something pass.

### 3.2 Never do, even if it looks convenient

- Edit `*_templ.go` or `output.css` by hand.
- Build HTML with string concatenation or `fmt.Sprintf` in Go handlers.
- Put secrets, tokens, or internal error text into HTML, logs, or examples.
- Trigger a mutation with a GET request.
- Invent APIs: do not use templ, htmx, Alpine, or Tailwind features you cannot verify exist in the repo's pinned versions. Check the version, the docs, or existing usage first.
- Claim something was tested, built, or verified when it was not. State exactly what you ran.

### 3.3 Always do

- Read the existing handler, component, and layout before changing them.
- State each non-obvious interaction as **trigger -> request -> fragment -> target/swap**.
- Run `templ fmt`, `templ generate`, `go build ./...`, `go vet ./...`, `go test ./...` when a shell is available, and report results honestly.
- Keep the change as small as the task allows; mention follow-ups separately instead of folding them in.

---

## 4. Ask vs assume

| Situation | Action |
|---|---|
| Repo answers it (naming, folder, router, ID type) | Follow the repo. Do not ask. |
| Cosmetic choice (class order, variable names) | Pick the repo convention. Do not ask. |
| Two reasonable designs with different user-visible behavior (inline edit vs modal, push-url or not) | Choose the simpler one, state the assumption in one line, offer the alternative. |
| Ambiguity that changes data, security, or public routes | **Ask first**, one focused question. |
| Missing context you can obtain (read a file, run a command) | Obtain it. Do not ask. |
| Requirement conflicts with a rule | Explain the conflict briefly, follow precedence (section 1). |

Ask at most one question at a time, and make it answerable in a sentence.

---

## 5. Rule catalog

Each rule has an ID so reviewers can cite it (`Rule: HTMX-2`) and builders can self-check. **Sev** is the default severity the reviewer assigns; adjust with evidence.

### 5.1 Architecture and layering (ARCH)

| ID | Do | Don't | Sev |
|---|---|---|---|
| ARCH-1 | Return HTML fragments for UI endpoints | Return JSON to feed the UI | Major |
| ARCH-2 | Keep handlers thin: parse, validate, call store/service, choose fragment | Put business logic or SQL in handlers or templates | Major |
| ARCH-3 | Dependencies flow `handlers -> store/service -> models`; `views` depend on models/view models | Import views or handlers from store/models; create import cycles | Major |
| ARCH-4 | Use one component for both the fragment response and the full page | Maintain two copies of the same markup | Minor |
| ARCH-5 | Wrap related writes in a transaction; pass `r.Context()` to the store | Use `context.Background()` in request paths; leave multi-step writes unguarded | Major |
| ARCH-6 | Centralize error-to-response mapping and log errors once at the boundary | Leak internal error text to HTML; log the same error at every layer | Minor |
| ARCH-7 | Load config once, pass explicitly, set server timeouts, shut down gracefully | Read env in handlers; use mutable globals; rely on `init()` side effects | Minor |

### 5.2 templ (TEMPL)

| ID | Do | Don't | Sev |
|---|---|---|---|
| TEMPL-1 | Write all markup in `.templ` with typed parameters | Build HTML in Go strings; pass `map[string]any` | Major |
| TEMPL-2 | Edit `.templ` and run `templ generate` | Edit `*_templ.go` | Major |
| TEMPL-3 | Give targeted/swapped elements stable, unique `id`s | Rely on positional selectors or duplicate ids | Major |
| TEMPL-4 | Build ids and URLs with `fmt.Sprintf` / `strconv` | Concatenate non-string IDs onto strings | Minor |
| TEMPL-5 | Use `templ.KV` or complete literal class strings for conditional classes | Construct class names from fragments | Major |
| TEMPL-6 | Make forms work without JS (`action`, `method`, labels, button `type`) | Rely only on JS-driven submission | Minor |
| TEMPL-7 | Fetch data in the handler, pass a view model | Call the store from a component (also causes N+1) | Major |

### 5.3 HTMX (HTMX)

| ID | Do | Don't | Sev |
|---|---|---|---|
| HTMX-1 | Set explicit `hx-target` and `hx-swap` on every request element | Depend on inherited or default targets outside tight form wrappers | Major |
| HTMX-2 | Use non-GET methods for mutations and `hx-confirm` for destructive actions | Mutate with `hx-get` | Blocker/Major |
| HTMX-3 | Return `422`/`400` with the re-rendered form and opt in to swapping via `htmx:beforeSwap` | Return 4xx fragments with no swap opt-in (silently dropped) | Major |
| HTMX-4 | Use `HX-Redirect` / `HX-Location` for navigation from HTMX requests | Use `http.Redirect` (302) in HTMX responses | Major |
| HTMX-5 | Return `200` with an empty body for `outerHTML` deletes | Return `204` and expect a swap | Major |
| HTMX-6 | Show loading state with `.htmx-request` and Tailwind variants | Toggle spinners with JS | Minor |
| HTMX-7 | Use `delay:`, `hx-sync`, or disable-on-request for rapid triggers | Let stale responses overwrite newer ones | Minor |
| HTMX-8 | Use `hx-swap-oob` only for ids that exist in the page | Send OOB fragments with no matching element | Major |
| HTMX-9 | Return a full page to boosted requests (`HX-Boosted`) | Return a bare fragment to boosted navigation | Major |
| HTMX-10 | Use `HX-Trigger` events for cross-component communication | Share domain state through Alpine stores | Minor |

### 5.4 Alpine (ALP)

| ID | Do | Don't | Sev |
|---|---|---|---|
| ALP-1 | Use Alpine for local visual state: dropdowns, modals, tabs, masks | Call `fetch`/XHR or re-implement requests in Alpine | Major |
| ALP-2 | Keep `x-data` small and literal; pass server values only for display or initial UI state | Treat Alpine data as authoritative or send it back as truth | Major |
| ALP-3 | Define `[x-cloak]{display:none!important}` in `input.css` under `@layer base` when using `x-cloak` | Use `x-cloak` without the CSS | Minor |
| ALP-4 | Prefer `<details>`, `<dialog>`, or CSS (`peer`, `group`, `:has`) when they suffice | Write long Alpine logic for simple toggles | Nit/Minor |
| ALP-5 | Keep Alpine elements outside swap targets when state must survive | Swap an element and expect its Alpine state to persist | Minor |

### 5.5 Tailwind v4 (TW)

| ID | Do | Don't | Sev |
|---|---|---|---|
| TW-1 | Use standard utilities; keep custom CSS in the CSS entry file only: `@layer base`, `@layer components`, `@utility`, `@custom-variant` | Add `<style>` blocks in `.templ`, new component CSS files, or `@layer utilities` for things that should behave like utilities | Minor |
| TW-2 | Write complete class strings; map values to literals in Go | Build `"bg-" + color + "-500"` | Major |
| TW-3 | Rely on v4 automatic source detection; keep `.templ` files and folders out of `.gitignore`; add outside directories with `@source`, exclude with `@source not`, safelist with `@source inline()` | Look for a `content` option, or debug "missing styles" without checking source detection first | Major |
| TW-4 | Configure in CSS: `@import "tailwindcss"`, `@theme`, `@utility`, `@custom-variant`; use `var(--color-*)` in custom CSS | Create `tailwind.config.js`; use `@tailwind base/components/utilities`, `theme()`, `corePlugins`, or `safelist` | Major |
| TW-5 | Add focus-visible styles, accessible names on icon buttons, `aria-live` for OOB messages | Ship interactive elements with no keyboard or screen-reader support | Minor |
| TW-6 | Leave `output.css` to the build | Hand-edit it or commit conflicting manual changes | Minor |
| TW-7 | Use v4 names: `shadow-xs`, `rounded-xs`, `outline-hidden`, `ring-3`, `bg-black/50`, `shrink-*`, `bg-linear-to-r`, `bg-(--var)`, `flex!` | Carry over v3 names or syntax (`shadow-sm` meaning v3 "small", `outline-none` for focus rings, `bg-opacity-*`, `flex-shrink-*`, `bg-[--var]`, `!flex`) | Major |
| TW-8 | Name the color on `border-*`, `divide-*`, and `ring-*`; restore v3 defaults in `@layer base` only if the design truly needs them | Rely on v3 defaults (gray-200 borders, 3px blue ring); v4 uses `currentColor` and 1px | Minor |
| TW-9 | Write plain CSS | Run Sass, Less, or Stylus through Tailwind v4 | Major |
| TW-10 | Treat `hover:` as an enhancement (v4 applies it only on hover-capable devices) | Hide essential actions behind hover | Minor |

### 5.6 Security (SEC)

| ID | Do | Don't | Sev |
|---|---|---|---|
| SEC-1 | Rely on templ's contextual escaping | Use `templ.Raw` / unvalidated `templ.SafeURL` on user data; build `<script>` content from user data | Blocker |
| SEC-2 | Protect every state-changing request with CSRF (token via `hx-headers` on `<body>`, validated in middleware) | Add per-button tokens inconsistently or skip validation | Blocker |
| SEC-3 | Check authentication and per-resource authorization in every handler, including "UI-only" fragment endpoints | Hide buttons and call it authorization; trust IDs from the client | Blocker |
| SEC-4 | Validate and trim input server-side | Rely on client-side or Alpine validation | Major |
| SEC-5 | Return generic error messages to users and log details server-side | Render stack traces, SQL errors, or secrets in fragments | Major |
| SEC-6 | Vendor and pin htmx/Alpine; set a sensible CSP | Load unpinned scripts from CDNs; use inline `on*=` handlers | Minor |

### 5.7 Go and testing (GO)

| ID | Do | Don't | Sev |
|---|---|---|---|
| GO-1 | Set the status code before the first write; check and log `Render` errors | Write status after the body; ignore `Render` errors | Minor |
| GO-2 | Detect HTMX with `HX-Request`; add `Vary: HX-Request` when caching | Serve cached full pages to HTMX requests or the reverse | Minor |
| GO-3 | Test handlers with `HX-Request: true`: status, headers, fragment content, no `<html` | Test only the happy path | Minor |
| GO-4 | Test validation (422), empty state, and escaping with hostile input | Skip tests for new behavior | Minor |
| GO-5 | Use structured logging with a request ID | `fmt.Println` in request paths; log secrets or form bodies | Minor |

---

## 6. Deviation notes

When you deviate from a rule on purpose (because of precedence level 1 or 2), add one line in your reply:

```
Deviation: <RULE-ID> not followed: <reason>, per <user request | repo convention in path/to/file>.
```

Reviewers: a documented deviation is not a finding unless it creates a security risk (SEC-*) or contradicts the repo's own overrides. Undocumented deviations are findings at the rule's default severity.