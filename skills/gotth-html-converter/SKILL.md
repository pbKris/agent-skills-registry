---
name: gotth-html-converter
description: Convert an existing UI design (static HTML, CSS, and JavaScript such as jQuery, or a mockup/template/legacy front end) into a working GOTTH application (Go, templ, Tailwind, HTMX, Alpine) with pixel-faithful visuals and working behavior. Use this skill whenever the user wants to convert, migrate, port, slice, templatize, or "turn this HTML/design into templ/Go/HTMX", wants to replace jQuery with HTMX/Alpine, wants to move CSS to Tailwind, or hands over HTML/CSS/JS files, a template theme, or a design export and asks for it to run on the GOTTH stack. Use it even if the user only says "make this design work in our Go app". Pairs with gotth-stack (rules and patterns) and gotth-code-reviewer (review of the result).
---

# GOTTH HTML Converter

Turn a finished visual design into a functional, tidy GOTTH app **without the visuals drifting**. The order of priorities is: (1) looks identical, (2) behaves the same or better, (3) code is clean and idiomatic GOTTH. Never trade 1 for 3 in the first pass. Refactor only after a page passes visual verification.

## 0. Read these first

1. `gotth-stack/SKILL.md` and `gotth-stack/references/gotth-rules.md`: rules, guardrails, precedence, Project overrides.
2. `references/source-stack-profile.md` in this skill: what the source UI is built with. **Its status may be `ASSUMED`** (plain HTML/CSS + jQuery). Treat assumed values as hypotheses, see section 1.
3. Load the others only when needed:
   - `references/css-conversion.md`: before touching CSS or the Tailwind entry file. The project uses **Tailwind v4, CSS-first, no config file**; this file is written for that.
   - `references/jquery-to-gotth.md`: before converting any JavaScript.
   - `references/visual-regression.md`: before verifying a page.

## 1. Intake: confirm the source stack, do not trust the assumption

Before converting anything, detect the real stack from the files (a few minutes of grep saves days of rework):

```bash
# CSS frameworks and libraries referenced
grep -rhoiE "bootstrap|bulma|foundation|tailwind|materialize|font-?awesome|material-icons" legacy | sort | uniq -c | sort -rn
# JS libraries and plugins
grep -rhoiE "jquery[-.a-z0-9]*|alpine|vue|react|angular|swiper|slick|select2|datatables|chart\.?js|flatpickr|moment" legacy | sort | uniq -c | sort -rn
# Preprocessors / build hints
ls legacy | grep -iE "scss|sass|less|package.json|webpack|vite|gulp"
```

Then:
- If the detected stack **matches** `source-stack-profile.md`, proceed.
- If it **differs** (Bootstrap found, a framework found, Sass sources found), stop, update the "Detected facts" section of the profile, tell the user in 3-4 lines what you found and how it changes the plan, and continue unless the change is large (e.g. a React app), in which case ask first.
- **Check the browser floor.** Tailwind v4 targets Safari 16.4+, Chrome 111+, Firefox 128+. If the design must support older browsers, stop and tell the user before converting (v4 cannot serve them). Record the answer in the profile.
- **Check for a CSS preprocessor** (Sass/Less/Stylus sources). Tailwind v4 is not designed to be used with them: convert from the compiled CSS and continue in plain CSS.
- Keep the original files untouched in `legacy/` (or the user's folder) and work in the Go project. The legacy files are the visual reference.

## 2. Principles

- **Structure-preserving first.** Keep the original DOM structure and class order in the first conversion, only translating syntax. The CSS was written against that DOM; restructuring it early is the main cause of broken layouts.
- **Fidelity is measured, not eyeballed.** A component or page is done only when it passes the visual comparison in `references/visual-regression.md`.
- **One pilot page first.** Pick a representative page (header + nav + content + a form or table). Finish it through all phases, then reuse its patterns.
- **Do not invent behavior or content.** Convert what exists. Missing states (empty, error, loading) are added by the gotth-stack rules, and listed in the report as additions.
- **Asset parity.** Fonts, icons, images, favicons, and meta tags move with the design (`/static/...`). Missing assets are reported, not silently substituted.
- **Guardrails still apply.** Adding a library (e.g. keeping a jQuery plugin) is a guardrail event: record it as an exception in the Project overrides table rather than adding it silently.

## 3. Workflow

Work through the phases in order. Each phase has an exit criterion; do not move on until it is met.

### Phase 1: Inventory

Create `docs/conversion/inventory.md` with these tables (generate from the files, do not guess):

| Page / template | Route | Shared parts used | JS used | Priority |
|---|---|---|---|---|

| Component | Appears on | Variants / states | JS behavior | Target templ name |
|---|---|---|---|---|

| JS behavior | File:line | Classification (Alpine / HTMX / CSS / Vendor island / Drop) | Notes |
|---|---|---|---|

Exit: every page, repeated component, and JS behavior is listed and classified. Open questions go at the bottom of the file.

### Phase 2: Tokens and base styles

Extract design tokens (colors, fonts, type scale, spacing, radii, shadows, breakpoints) into `@theme` in `static/css/input.css` and set up the base layer. There is no `tailwind.config.js`. Follow `references/css-conversion.md`, including the bridge setup (legacy CSS imported with `layer(components)`) and `@source not` for the legacy folder.

Exit: a token map table exists; a "kitchen sink" page (headings, paragraphs, lists, links, buttons, inputs) renders identically to the legacy equivalent at all test widths.

### Phase 3: Components (smallest first)

Order: atoms (button, badge, icon, input) -> molecules (card, form field, alert) -> organisms (navbar, table, modal, footer) -> layouts.

For each component:
1. Create a typed `.templ` component. Replace static content with typed props; repeated items become loops over a slice.
2. Keep class lists and DOM structure from the legacy markup (translate legacy classes to utilities per the CSS strategy).
3. Add it to a dev-only catalog page (e.g. `/dev/components`) with its variants side by side.
4. Verify against the legacy snippet (`references/visual-regression.md`).

Exit: catalog page matches legacy for every variant.

### Phase 4: Behavior

Convert JavaScript per the classification, using `references/jquery-to-gotth.md`. Summary:

| Legacy JS does... | Becomes |
|---|---|
| Show/hide, toggle classes, tabs, accordions, dropdowns, modals | Alpine, native `<details>`/`<dialog>`, or CSS |
| Fetches or posts data, filters/sorts/paginates, live search, form submit | HTMX + handler returning a fragment |
| Third-party widget (chart, date picker, carousel, rich editor) | Vendored "island" initialized via `htmx.onLoad` (record as exception) |
| Pure animation/scroll effect | CSS transition, `scroll-snap`, `sticky`, `IntersectionObserver` if needed |
| Dead or duplicated code | Dropped (list in the report) |

Exit: each behavior in the inventory works on the converted page, including after HTMX swaps.

### Phase 5: Pages and handlers

Assemble pages from components; add routes and handlers per gotth-stack. Use **stub data** (hard-coded structs in a `fixtures` package) first so visual verification is deterministic; connect the real store afterwards.

Exit: every page loads at its route with fixture data, both as a full page and (where relevant) as an HTMX fragment.

### Phase 6: Verify

Run the visual comparison at all configured widths and the behavior checks. Fix differences at the component level, not with page-specific overrides. Details in `references/visual-regression.md`.

Exit: no unexplained visual diffs above threshold; behavior checklist passes; `templ generate`, `go build`, `go vet`, `go test` pass.

### Phase 7: Clean up

Only after verification: remove unused legacy CSS from the bridge layer, delete dead JS, replace temporary exceptions where possible, and have the result reviewed with `gotth-code-reviewer`.

## 4. Conversion rules for markup

- Text content that is data becomes props; text that is design copy may stay literal.
- Links become real routes (`href` to Go routes, or `hx-get` + `hx-push-url` for in-page navigation with a real URL fallback).
- Inline `style=` attributes: keep if truly dynamic (e.g. a width percentage), otherwise convert to utilities.
- Inline `onclick=` and similar: remove; replace with Alpine `@click` or HTMX.
- Repeated static markup (list items, table rows, cards) becomes one component plus a loop, with the first item matching the legacy HTML exactly.
- Preserve semantics and accessibility attributes (`alt`, `aria-*`, `label for`, heading order). Do not "improve" them in the first pass unless they are broken; list issues in the report.
- Forms: keep `name`s and structure, add `action`/`method`, CSRF, server-side validation, and a 422 re-render path.
- Dark mode, print styles, and `prefers-reduced-motion` rules in legacy CSS must be carried over, not dropped.

## 5. Per-page report (reply format)

After each page or milestone, report briefly:

```
Converted: <page/components>
Verified: <widths tested, diff results, commands run>  (or "not verified: reason")
JS: <behavior -> approach> (one line each)
Exceptions: <vendor islands, legacy CSS kept, with reason>
Deviations / additions: <what differs from legacy and why>
Open questions: <only what blocks or changes the plan>
```

Never claim visual parity without the comparison results.

## 6. Common ways conversions go wrong

- **Unlayered legacy CSS** overriding utilities. In v4, unlayered CSS beats every cascade layer; import legacy CSS with `layer(components)`.
- **The legacy folder being scanned** by Tailwind, generating stray utilities from its class names. Exclude it with `@source not`.
- **v3 habits:** creating `tailwind.config.js`, `@tailwind base;`, `theme()`, v3 utility names (`shadow-sm`, `rounded`, `ring`, `outline-none`), or relying on v3 defaults for borders and rings.
- **Desktop-first media queries** in legacy CSS (`max-width`) translated naively to Tailwind's mobile-first `md:`/`lg:`. Convert deliberately (see css-conversion).
- **Tailwind Preflight** resets margins, heading sizes, list styles, and image display, shifting the layout. Compare early on the kitchen-sink page.
- **Plugins not re-initialized** after an HTMX swap (select2, datepickers, tooltips).
- **Fonts and icons** not loaded, so text metrics change and layouts reflow.
- **Dynamic class names** vanishing from the Tailwind build.
- **Live data in comparisons** (dates, random content) causing false diffs. Use fixtures.
- **Refactoring the DOM** during the first pass. Do it after the page is verified.
- **Page-specific CSS patches** to make one page match; fix the component or token instead.

## 7. When the stack info changes

When the user supplies the real stack (framework, JS libs, build tools):
1. Update `references/source-stack-profile.md` (set Status to `CONFIRMED`, fill the table).
2. Extend the matching sections in `css-conversion.md` (framework mapping) and `jquery-to-gotth.md` (library mapping). Both have clearly marked provisional sections.
3. Re-run the intake detection (section 1) and adjust the inventory if the stack differs from the assumption.