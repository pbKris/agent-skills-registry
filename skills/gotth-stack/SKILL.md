---
name: gotth-stack
description: Architecture rules, patterns, checklists for GOTTH stack (Go, templ, Tailwind v4, HTMX, Alpine). Server-rendered HTML, hypermedia, no SPA APIs. Use for handlers, components, forms, modals, live validation, infinite scroll.
---

# GOTTH Stack Skill

Go + templ + Tailwind + HTMX + Alpine. The server owns state and renders HTML. The browser stays thin.

Read this whole file before generating code. Rules come with their reasons so you can make good calls in cases not listed here.

Also read `references/gotth-rules.md` (the shared rule catalog) in these cases:
- At the start of work in a repo you have not seen before: fill in its **Project overrides** table instead of guessing module path, Tailwind version, ID type, router, or CSRF mechanism.
- Before anything on its **Guardrails** list (JSON endpoints, auth/CSRF changes, new dependencies, destructive commands, renaming public routes or ids).
- When unsure whether to ask the user or proceed (**Ask vs assume**), or when a request conflicts with a rule (**Precedence**).

Rules there carry IDs (e.g. `HTMX-3`, `SEC-2`). Use them when you explain a deviation.

## 1. Mental model

Every UI interaction is a loop:

```
user event -> hx-* request -> Go handler -> templ fragment (HTML) -> htmx swaps it into the DOM
```

Why this matters: the server is the single source of truth. When you add client-side state that mirrors server data, you create two truths that drift apart. Every rule below exists to keep one truth.

| Layer | Owns | Never owns |
|---|---|---|
| Go handler | Validation, persistence, auth, choosing which fragment to return | Building HTML with strings |
| templ | All markup, escaping, composition | Business logic, DB calls |
| Tailwind | All styling and CSS-driven state (hover, transitions, htmx-request) | Custom CSS files beyond `input.css` base layers |
| HTMX | Requests, swaps, history, triggers | Client-side data transforms |
| Alpine | Ephemeral, purely visual state (open/closed, active tab) | Data fetching, server data, cross-component state |

## 2. Hard rules

1. **No JSON for UI.** Handlers return HTML fragments. Add JSON endpoints only when the user explicitly asks for a public or third-party API, and place them under a separate `/api/...` route group.
2. **All HTML lives in `.templ` files.** Never build markup with `fmt.Sprintf`, string concatenation, or `html/template` in handlers. templ gives compile-time checking and contextual auto-escaping, which is what makes XSS hard to introduce.
3. **Never edit `*_templ.go`.** They are generated. Edit the `.templ` source and run `templ generate`.
4. **Never use `templ.Raw` or `@templ.Raw(...)` with user-controlled data.** It bypasses escaping. If trusted HTML is truly required (e.g. sanitized markdown), sanitize it first and leave a comment explaining why.
5. **No `fetch()`, `XMLHttpRequest`, or axios in Alpine or inline scripts.** Use `hx-*`.
6. **No inline `<style>` blocks in `.templ` files.** Use Tailwind utilities. Global base rules go in `input.css` under `@layer base`.
7. **Pass typed structs to components**, not `map[string]any` or loose strings. If a component needs five arguments, define a `ViewModel` struct.

## 3. Project layout

Follow the existing layout if the repo already has one. For new projects use:

```
cmd/server/main.go            # wiring: router, middleware, server start
internal/
  handlers/                   # HTTP handlers (one file per resource)
  models/                     # domain types
  store/                      # DB access
  views/
    layouts/base.templ        # <html>, <head>, scripts, body
    pages/                    # full pages (compose layout + components)
    components/               # reusable fragments (rows, forms, toasts)
static/
  css/input.css  css/output.css   # input.css is the ONLY Tailwind config (v4 CSS-first); no tailwind.config.js
  js/htmx.min.js  js/alpine.min.js  js/app.js
```

Vendor htmx and Alpine into `static/js` and pin their versions. Avoid unpinned CDN tags: they make builds non-reproducible and break offline development.

## 4. Go handlers

### Return fragments, not pages

```go
func (h *Items) Create(w http.ResponseWriter, r *http.Request) {
    if err := r.ParseForm(); err != nil {
        http.Error(w, "bad request", http.StatusBadRequest)
        return
    }

    form := components.ItemFormData{Name: strings.TrimSpace(r.FormValue("name"))}
    if form.Name == "" {
        form.Errors = map[string]string{"name": "Name is required"}
        w.WriteHeader(http.StatusUnprocessableEntity) // see section 6 on 422
        _ = components.ItemForm(form).Render(r.Context(), w)
        return
    }

    item, err := h.store.Create(r.Context(), form.Name)
    if err != nil {
        h.serverError(w, r, err)
        return
    }

    // Primary response: the new row.
    // Secondary: an out-of-band counter update (see section 5).
    w.Header().Set("HX-Trigger", `{"item:created": {"id": "`+item.ID+`"}}`)
    _ = components.ItemRow(item).Render(r.Context(), w)
    _ = components.ItemCount(h.store.Count(r.Context()), true).Render(r.Context(), w)
}
```

Notes:
- Check the `Render` error. A failed render mid-stream cannot be recovered, but it must be logged.
- Set the status code **before** the first write.
- For static components with no data fetching, `templ.Handler(pages.About())` is enough. Use `templ.WithStatus(...)` to set a non-200 code.

### Full page vs fragment

Routes that users can open directly (bookmarks, refresh, `hx-push-url`) must work without HTMX. Detect the request type and render accordingly:

```go
func isHTMX(r *http.Request) bool { return r.Header.Get("HX-Request") == "true" }

func (h *Items) List(w http.ResponseWriter, r *http.Request) {
    items := h.store.List(r.Context(), r.URL.Query().Get("q"))
    if isHTMX(r) && !isBoosted(r) {
        _ = components.ItemTable(items).Render(r.Context(), w)
        return
    }
    _ = pages.ItemsPage(items).Render(r.Context(), w)
}

func isBoosted(r *http.Request) bool { return r.Header.Get("HX-Boosted") == "true" }
```

Boosted navigation expects a full page (htmx extracts `<body>`), so only return a bare fragment when the request is HTMX and not boosted. Add `Vary: HX-Request` when caching responses that differ by this header.

### Redirects

A plain `302` makes the browser's XHR follow the redirect and htmx then swaps the whole target page into your fragment target, which looks broken. For HTMX requests respond with `HX-Redirect: /path` (full page load) or `HX-Location: /path` (boosted-style navigation), status 200.

### Delete returns 200 with an empty body

htmx does not swap on `204`. To remove a row with `hx-swap="outerHTML"`, return `200` and an empty body.

## 5. templ components

### Shape of a good component

```templ
package components

import (
    "fmt"

    "github.com/<org>/<repo>/internal/models" // use the real module path from go.mod
)

templ ItemRow(item models.Item) {
    <tr
        id={ fmt.Sprintf("item-%d", item.ID) }
        class="transition-colors duration-200 hover:bg-slate-50"
    >
        <td class="px-6 py-4 text-sm font-medium text-slate-900">{ item.Name }</td>
        <td class="px-6 py-4 text-right text-sm">
            <button
                type="button"
                hx-delete={ fmt.Sprintf("/items/%d", item.ID) }
                hx-target={ fmt.Sprintf("#item-%d", item.ID) }
                hx-swap="outerHTML swap:150ms"
                hx-confirm="Delete this item?"
                class="font-medium text-red-600 hover:text-red-900"
            >
                Delete
            </button>
        </td>
    </tr>
}
```

Guidelines:
- Give every swappable element a **stable, unique `id`**. Targets and OOB swaps depend on it.
- Use `fmt.Sprintf` (or `strconv`) for IDs and URLs. Never concatenate a non-string ID onto a string; it will not compile for ints and is easy to get wrong.
- Conditional classes: `class={ "px-2 py-1", templ.KV("bg-red-50 text-red-700", item.Overdue) }`.
- Dynamic URLs in `href`/`action` go through `templ.URL(...)` or `templ.SafeURL(...)` only when the value is validated; templ sanitizes `javascript:` URLs by default.
- Split components when you reuse them in more than one handler response, not before. A fragment returned by a handler should be one component that the full page also composes, so the two never drift.
- Use `{ children... }` for layout wrappers (`@Layout("Title") { ... }`).

### Out-of-band (OOB) updates

Use OOB to patch a second region from one response (counters, flash messages, sidebar badges):

```templ
templ ItemCount(n int, oob bool) {
    <span
        id="item-count"
        if oob {
            hx-swap-oob="true"
        }
        class="rounded-full bg-slate-100 px-2 py-0.5 text-xs text-slate-700"
    >
        { fmt.Sprint(n) }
    </span>
}
```

The same component renders in the initial page (`oob=false`) and in responses (`oob=true`). The target element must already exist in the DOM with the same `id`.

## 6. HTMX orchestration rules

Before writing any `hx-*` attribute, answer three questions: **what triggers it, what does it target, how does it swap.** State them in a short comment in your reply when the interaction is non-obvious.

### Targeting and swapping

| Goal | Pattern |
|---|---|
| Update contents of a container | `hx-target="#list" hx-swap="innerHTML"` |
| Replace the element itself (inline edit, row delete) | `hx-target="#item-7" hx-swap="outerHTML"` |
| Append new row | `hx-target="#rows" hx-swap="beforeend"` |
| Patch an independent region | response includes element with `hx-swap-oob="true"` |
| Fire a side effect only | `hx-swap="none"` plus `HX-Trigger` response header |

- Always set `hx-target` explicitly. Inherited targets are acceptable only on a tight wrapper, such as a form that swaps itself with its validation errors.
- Set `hx-swap` explicitly too. The default is `innerHTML`, but writing it out makes the intent reviewable.
- Use `hx-select` sparingly. If you need it, the handler is probably returning too much.

### Triggers

- Search-as-you-type: `hx-trigger="input changed delay:300ms, search"` with `hx-get`, `hx-target`, and `hx-push-url="true"` if the result should be shareable.
- Polling: `hx-trigger="every 5s"`; stop it by returning a fragment without the polling attribute.
- Lazy load: `hx-trigger="revealed"` or `load`.
- Infinite scroll: `hx-trigger="revealed" hx-swap="afterend"` on the last row, which the next page fragment replaces.
- Cross-component events: the server sends `HX-Trigger: item:created`, and other elements listen with `hx-trigger="item:created from:body"`. Prefer this over Alpine stores.

### Indicators

Every request that can take more than ~100ms needs visible feedback. Use CSS only:

```templ
templ SubmitButton(label string) {
    <button
        type="submit"
        class="inline-flex items-center gap-2 rounded bg-slate-900 px-4 py-2 text-white
               [&.htmx-request]:opacity-60 [&.htmx-request]:pointer-events-none"
    >
        <span>{ label }</span>
        <svg
            class="htmx-indicator hidden size-4 animate-spin [.htmx-request_&]:block"
            viewBox="0 0 24 24" fill="none" aria-hidden="true"
        >
            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" class="opacity-25"></circle>
            <path d="M4 12a8 8 0 018-8" stroke="currentColor" stroke-width="4" class="opacity-75"></path>
        </svg>
    </button>
}
```

htmx puts `.htmx-request` on the element that issued the request (or on the element named by `hx-indicator`). Style off that class. For a separate indicator element: `hx-indicator="#spinner"` and `[&.htmx-request]:opacity-100` on `#spinner`.

### Error handling (common trap)

htmx **does not swap 4xx/5xx responses** by default. Two consequences:
- Validation errors returned with `422` will be silently dropped unless you opt in.
- Server errors need a visible fallback.

Add once in `static/js/app.js` (loaded by the base layout):

```js
document.body.addEventListener("htmx:beforeSwap", (e) => {
  const status = e.detail.xhr.status;
  if (status === 422 || status === 400) {
    e.detail.shouldSwap = true;   // render the validation fragment
    e.detail.isError = false;
  }
});
document.body.addEventListener("htmx:responseError", () => {
  // show a toast via a pre-rendered element; keep it tiny, no data logic
  document.getElementById("toast-error")?.classList.remove("hidden");
});
```

Validation pattern: the form re-renders itself with errors, using `hx-target="this" hx-swap="outerHTML"` on the `<form>`. The form must also work as a normal POST (set `action` and `method`) so it degrades without JS.

### Navigation

Prefer `hx-boost="true"` on `<body>` or a nav container for ordinary links and forms: faster navigation with a real URL for every state. Use `hx-push-url` for fragment navigations that should be bookmarkable (tabs, filters, pagination).

## 7. Alpine.js boundary

Alpine exists for micro-interactions that the server does not need to know about.

**Allowed:** dropdowns, modals open/close, mobile menu, accordion, tab highlighting, input masking, clipboard-copy feedback, character counters.

**Forbidden:** network calls, mirroring server data, shared state across unrelated components (`Alpine.store` for domain data), form submission logic, validation rules that duplicate the server's.

```templ
templ Disclosure(title string) {
    <div x-data="{ open: false }" class="rounded-lg border p-4">
        <button
            type="button"
            @click="open = !open"
            :aria-expanded="open"
            class="rounded bg-slate-900 px-4 py-2 text-white"
        >
            { title }
        </button>
        <div x-show="open" x-cloak x-transition class="mt-2 text-slate-600">
            { children... }
        </div>
    </div>
}
```

Rules:
- `x-cloak` only works if `input.css` contains `[x-cloak] { display: none !important; }` inside `@layer base`. Verify it exists when you use `x-cloak`.
- Keep `x-data` objects small and literal. Pass server values via `x-data={ templ.JSONString(v) }` only for display or initial UI state, never to be sent back as truth.
- **Swapped-in content:** htmx-inserted DOM containing `x-data` is initialized by Alpine's mutation observer, so fragments can include Alpine components safely. Do not rely on Alpine state surviving a swap of its own element; the server re-render resets it. If state must survive, keep the Alpine element outside the swap target.
- If a requirement needs more than a few lines of Alpine logic, stop and ask whether the server or a CSS state (`peer`, `group`, `:has()`, `<details>`) can do it. Native `<details>` and `<dialog>` often remove the need for Alpine entirely.

## 8. Tailwind standards (v4, CSS-first, no config file)

The project targets **Tailwind CSS v4**. All configuration lives in the CSS entry file (`static/css/input.css`). There is no `tailwind.config.js`; do not create one. Much of what you remember about Tailwind v3 is wrong in v4 (config, directives, renamed utilities, defaults), so when unsure whether a utility, variant, or directive exists, check the docs for the pinned version instead of guessing.

### Baseline `input.css`

```css
@import "tailwindcss";

/* Design tokens: each one also creates utilities (see namespaces below) */
@theme {
  --font-display: "Inter", sans-serif;
  --color-brand-500: #3b82f6;
  --breakpoint-3xl: 120rem;
}

@layer base {
  /* Alpine: hide x-cloak elements until Alpine initializes (ALP-3) */
  [x-cloak] { display: none !important; }
  /* v4 Preflight removes <dialog> margins; restore centering for native dialogs */
  dialog { margin: auto; }
}
```

### Directives you will actually use

| Need | v4 way |
|---|---|
| Load Tailwind | `@import "tailwindcss";` (never `@tailwind base/components/utilities`) |
| Design tokens | `@theme { --color-*, --font-*, --text-*, --spacing, --radius-*, --shadow-*, --breakpoint-*, --animate-* ... }` |
| Replace a whole default namespace | `@theme { --color-*: initial; --color-ink: #111; }` |
| Token that references another variable | `@theme inline { --font-sans: var(--font-inter); }` |
| Custom utility (works with variants) | `@utility name { ... }`. Not `@layer utilities` |
| Customize `container` | `@utility container { margin-inline: auto; padding-inline: 2rem; }` |
| Custom variant | `@custom-variant name (&:where(...));` |
| Extra source directories | `@source "../../other/dir";` Exclude with `@source not "..."` |
| Safelist classes that never appear in source | `@source inline("...")` (there is no `safelist` option) |
| Use a token in custom CSS | `var(--color-brand-500)`, not the v3 `theme()` function |
| Keyframes | Inside `@theme` next to `--animate-*`, or outside `@theme` to always emit |

Use `@theme` for values that should generate utilities and `:root` for plain CSS variables that should not.

### Source detection

Tailwind v4 scans project files automatically as **plain text**. It skips files in `.gitignore`, `node_modules`, binary files, and CSS files. Consequences:
- `.templ` files are found automatically, as long as they (and their folders) are not git-ignored.
- Class names must appear as complete strings (TW-2). Map values to full class names in Go instead of concatenating.
- Add directories outside the default scan with `@source`; use `@import "tailwindcss" source(none);` plus explicit `@source` lines when you want fully explicit scanning.

### v3 -> v4 changes that bite (use the v4 names)

| v3 | v4 |
|---|---|
| `shadow-sm` / `shadow` | `shadow-xs` / `shadow-sm` |
| `rounded-sm` / `rounded` | `rounded-xs` / `rounded-sm` |
| `blur-sm` / `blur`, `drop-shadow-sm` / `drop-shadow` | `blur-xs` / `blur-sm`, `drop-shadow-xs` / `drop-shadow-sm` |
| `outline-none` (for focus styling) | `outline-hidden` |
| `ring` (3px, blue) | `ring-3` plus an explicit color (default is now 1px `currentColor`) |
| `bg-opacity-50`, `text-opacity-*`, etc. | `bg-black/50` opacity modifiers |
| `flex-shrink-0`, `flex-grow` | `shrink-0`, `grow` |
| `bg-gradient-to-r` | `bg-linear-to-r` |
| `bg-[--brand]` | `bg-(--brand)` |
| `!flex` (important prefix) | `flex!` (suffix) |
| `first:*:pt-0` (stacked variants, right to left) | `*:first:pt-0` (left to right) |
| `grid-cols-[a,b]` with commas as spaces | `grid-cols-[a_b]` (underscores) |
| `transform-none` to reset rotate/scale/translate | `rotate-none`, `scale-none`, `translate-none` |

### Defaults that changed (they affect appearance)

- `border-*` and `divide-*` default to `currentColor`: always name the color (`border border-slate-200`).
- Placeholder color is the current text color at 50% opacity; buttons use `cursor: default` (add `cursor-pointer` where wanted).
- `hover:` only applies on devices that support hover. Treat hover as an enhancement; never hide essential actions behind it.
- `space-y-*`/`divide-y-*` use a new selector; with inline children or extra margins prefer `flex flex-col gap-*`.
- A `hidden` attribute now wins over display utilities like `flex`.
- Browser floor: Safari 16.4+, Chrome 111+, Firefox 128+. If the product must support older browsers, stop and tell the user (Tailwind v3.4 would be required).

### Rules of thumb

- Utilities first. Extract a templ component, not a CSS class, when a pattern repeats.
- CSS that cannot be expressed as utilities (complex keyframes, `::before` decorations, third-party markup) goes in `input.css` under `@layer components` (or `@utility` if it should compose with variants), never in `<style>` blocks.
- Keep long class lists readable by breaking attributes across lines.
- Do not hand-edit `output.css`. It is a build artifact.
- Do not run Sass, Less, or Stylus through Tailwind v4; write plain CSS in `input.css`.
- Accessibility basics: real `<button>`/`<a>`/`<form>`, visible focus (`focus-visible:ring-2` with a ring color), `aria-live="polite"` on regions that receive OOB messages, `sr-only` labels on icon buttons.

## 9. Security checklist

- **CSRF:** every state-changing request (POST/PUT/PATCH/DELETE) needs protection. Put the token in the layout once: `<body hx-headers={ templ.JSONString(map[string]string{"X-CSRF-Token": csrf}) }>` and validate it in middleware. Do not add the token per button.
- **XSS:** rely on templ escaping. Avoid `templ.Raw`, `templ.SafeURL` on unvalidated input, and building `<script>` content from user data (use `templ.JSONScript` / `templ.JSONString`).
- **AuthZ in handlers, not in the UI.** Hiding a button is not authorization; check permissions in every handler that mutates or reads protected data.
- **Method semantics:** use GET only for reads. Never trigger mutations with `hx-get`.
- Set sensible `Content-Security-Policy` and avoid inline event handler attributes (`onclick=`). Alpine's `@click` is fine; if the CSP forbids `unsafe-eval`, use the Alpine CSP build.

## 10. Workflow when making changes

1. Read the existing handlers, components, and layout before adding to them. Match the project's naming and structure.
2. Decide the interaction in one line: trigger -> request -> fragment -> target/swap.
3. Write or modify the `.templ` component first, then the handler, then the route registration.
4. Run, in order: `templ fmt ./...`, `templ generate`, `go build ./...`, `go vet ./...`, `go test ./...`.
5. If styles changed, make sure the Tailwind build ran (it picks up `.templ` changes while `--watch` is running). If a class has no effect, check source detection (section 8) before changing markup.
6. Verify behavior: hit the endpoint with `curl -H "HX-Request: true"` and confirm the response is a fragment with no `<html>` tag; hit it without the header and confirm the full page works.

Local dev (three processes, or one wrapper such as `make dev`):

```bash
air                                  # rebuild + restart Go server
templ generate --watch               # regenerate *_templ.go on change
# Tailwind v4: standalone binary (no Node needed) ...
tailwindcss -i static/css/input.css -o static/css/output.css --watch
# ... or the npm CLI (package: @tailwindcss/cli)
npx @tailwindcss/cli -i static/css/input.css -o static/css/output.css --watch
# production build: add --minify
```

Use the command the repo's `Makefile`/`package.json` already defines. Do not introduce a second build system, and do not add `tailwind.config.js` or PostCSS/Autoprefixer: Tailwind v4 handles imports and vendor prefixing itself.

## 11. Testing

- **Handlers:** use `httptest`. Assert status code, the `HX-*` headers, and that fragments do not contain `<html`.
- **Components:** render to a `bytes.Buffer` and assert on the output (substring or `goquery` selectors). Test escaping with an input like `<script>`.
- **Regression to always cover:** the validation path (422 + re-rendered form) and the empty-state fragment.

```go
func TestCreate_ReturnsRowFragment(t *testing.T) {
    req := httptest.NewRequest(http.MethodPost, "/items", strings.NewReader("name=Widget"))
    req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
    req.Header.Set("HX-Request", "true")
    rec := httptest.NewRecorder()

    handler.Create(rec, req)

    body := rec.Body.String()
    if rec.Code != http.StatusOK { t.Fatalf("status = %d", rec.Code) }
    if strings.Contains(body, "<html") { t.Fatal("fragment must not include layout") }
    if !strings.Contains(body, "Widget") { t.Fatal("row missing") }
}
```

## 12. Anti-patterns

The full Do/Don't catalog with rule IDs and default severities is in `references/gotth-rules.md` section 5. Check your output against it before presenting code. The mistakes that appear most often:

- JSON for UI lists, or `fetch()` in Alpine (ARCH-1, ALP-1).
- Missing `hx-target`/`hx-swap`, or a target `id` that does not exist (HTMX-1, TEMPL-3).
- `hx-get` for mutations, `http.Redirect` for HTMX requests, `204` after an `outerHTML` delete (HTMX-2, HTMX-4, HTMX-5).
- 422 validation fragments with no `htmx:beforeSwap` opt-in (HTMX-3).
- Dynamic Tailwind class names, `<style>` blocks in `.templ` (TW-2, TW-1).
- v3-isms: creating `tailwind.config.js`, `@tailwind base;`, `theme()`, `shadow-sm`/`rounded`/`ring` with v3 meaning, `outline-none` (TW-4, TW-7).
- Editing `*_templ.go`, or `templ.Raw` on user data (TEMPL-2, SEC-1).

## 13. Pre-delivery checklist

Before presenting code, confirm:

- [ ] Handlers return HTML fragments (or full pages for direct navigation); no UI JSON.
- [ ] Every `hx-*` element has explicit `hx-target` and `hx-swap`, and targets exist with matching `id`s.
- [ ] Mutations use POST/PUT/PATCH/DELETE and are CSRF-protected.
- [ ] Validation errors use 422 and the `htmx:beforeSwap` opt-in exists.
- [ ] Loading state uses `.htmx-request` with Tailwind variants.
- [ ] Alpine is limited to local UI state; `x-cloak` CSS exists if used.
- [ ] No `templ.Raw` on user data; no string-built HTML; no edits to generated files.
- [ ] Tailwind v4 only: config in CSS (`@theme`, `@utility`, `@custom-variant`), no `tailwind.config.js`, v4 utility names, colors named on borders/rings.
- [ ] Tailwind classes are complete strings; `.templ` files are scanned (not git-ignored).
- [ ] `templ generate`, `go build`, `go vet`, and tests pass.
- [ ] No guardrail from `references/gotth-rules.md` section 3 was crossed without asking; deviations are noted in one line.
- [ ] Reply explains each interaction in one line (trigger -> target -> swap) so the reviewer can verify intent quickly.