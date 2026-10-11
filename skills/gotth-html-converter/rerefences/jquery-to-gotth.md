# jQuery (and plain JS) to GOTTH

Contents: 1. Survey the JS · 2. Idiom mapping · 3. Worked examples · 4. Plugins and vendor islands · 5. Re-initialization after swaps · 6. Behavior checklist

## 1. Survey the JS first

Find out what the code actually does before choosing replacements.

```bash
# Most frequent jQuery idioms (selector + method)
grep -rhoE '\$\([^)]*\)\.[a-zA-Z]+' legacy --include=*.js --include=*.html | sort | uniq -c | sort -rn | head -50

# AJAX calls
grep -rnE '\$\.(ajax|get|post|getJSON)|\.load\(|fetch\(|XMLHttpRequest' legacy --include=*.js --include=*.html

# Plugin calls (extend the list with what you find)
grep -rhoE '\.(datepicker|select2|DataTable|slick|owlCarousel|modal|tooltip|popover|dropdown|collapse|carousel|sortable|autocomplete|validate)\(' legacy | sort | uniq -c | sort -rn

# Inline handlers
grep -rnE 'on(click|change|submit|keyup|input)=' legacy --include=*.html
```

Add each behavior to the inventory with a classification: **Alpine / HTMX / CSS / Vendor island / Drop**.

## 2. Idiom mapping

| Legacy | GOTTH replacement | Notes |
|---|---|---|
| `$(document).ready(...)`, `DOMContentLoaded` | Remove; load scripts with `defer` | Init code moves to Alpine `x-init` or `htmx.onLoad` |
| `$(sel).on('click', ...)` toggling a class | Alpine `@click` + `:class`, or CSS (`peer`, `group`, `:has`) | Keep state local to the element |
| `.show()`, `.hide()`, `.toggle()`, `.slideToggle()`, `.fadeIn()` | Alpine `x-show` + `x-transition`, or `<details>` | `x-cloak` needs its CSS (ALP-3) |
| `.animate({...})` | CSS transitions/animations | Match duration and easing from the original |
| Tabs, accordions, dropdowns, mobile menu | Alpine; accordion can be `<details>` | If tabs load server content: `hx-get` + `hx-target` + `hx-push-url` |
| Modal (custom or plugin) | Native `<dialog>` with Alpine to open/close, or Alpine `x-show` overlay | Trap focus, close on Esc, restore focus |
| `$.ajax`/`$.get`/`$.post` filling a container | `hx-get`/`hx-post` + `hx-target` + `hx-swap` | Handler returns a fragment, not JSON |
| `.load(url)` | `hx-get` with `hx-trigger="load"` or `revealed` | Lazy parts of a page |
| Form submit via AJAX + manual validation | Real form + `hx-post`, server validation, 422 fragment | Keep native HTML5 constraints (`required`, `pattern`) as a first line |
| Live search/filter on keyup | `hx-get` + `hx-trigger="input changed delay:300ms"` | Purely client-side filtering of a tiny static list may stay in Alpine |
| Sort/paginate a table | `hx-get` with params + `hx-push-url` | Server returns the table body fragment |
| Infinite scroll | `hx-trigger="revealed"` + `hx-swap="afterend"` | |
| Polling / auto-refresh (`setInterval` + ajax) | `hx-trigger="every Ns"` | Stop when the server omits the attribute |
| Event delegation (`$(document).on('click','.x',...)`) | Usually unnecessary | htmx and Alpine bind to swapped-in content automatically |
| Character counter, input mask, copy-to-clipboard feedback | Alpine | Small `x-data` only |
| Scroll-spy, sticky header, back-to-top | CSS `position: sticky`, `scroll-behavior`; `IntersectionObserver` if truly needed | |
| Carousel/slider (simple) | CSS `scroll-snap` plus a few Alpine buttons | Complex ones: vendor island |
| `localStorage` UI preference (theme, collapsed sidebar) | Alpine with a few lines of `localStorage` | The Alpine `persist` plugin is a new dependency: ask first |
| Smooth anchor scrolling | CSS `scroll-behavior: smooth` | |
| Cookie/consent banner | Alpine plus a small server endpoint if consent is stored | |

## 3. Worked examples

### Dropdown (jQuery -> Alpine)

Legacy:
```js
$('.menu-toggle').on('click', function () { $('.menu').slideToggle(150); });
$(document).on('click', function (e) { if (!$(e.target).closest('.nav').length) $('.menu').hide(); });
```
GOTTH (structure and classes unchanged, behavior in Alpine):
```templ
<div class="nav" x-data="{ open: false }" @click.outside="open = false">
    <button type="button" class="menu-toggle" @click="open = !open" :aria-expanded="open">Menu</button>
    <ul class="menu" x-show="open" x-cloak x-transition.duration.150ms>
        { children... }
    </ul>
</div>
```

### Live search (jQuery AJAX -> HTMX)

Legacy:
```js
$('#q').on('keyup', function () {
  $.getJSON('/search', { q: this.value }, function (rows) { /* build <tr> strings */ });
});
```
GOTTH:
```templ
<input
    id="q" name="q" type="search"
    hx-get="/items"
    hx-trigger="input changed delay:300ms, search"
    hx-target="#item-rows" hx-swap="innerHTML"
    hx-push-url="true"
    class="..."
/>
<tbody id="item-rows">
    for _, it := range items { @ItemRow(it) }
</tbody>
```
The `/items` handler returns only the rows for HTMX requests and the full page otherwise (gotth-stack section 4).

### Form with AJAX validation

Legacy: `$('#signup').on('submit', e => { e.preventDefault(); $.post(...) ... })`
GOTTH: `<form action="/signup" method="post" hx-post="/signup" hx-target="this" hx-swap="outerHTML">`; the handler validates, returns the same form with errors and status 422 on failure. Add the `htmx:beforeSwap` opt-in once (HTMX-3).

## 4. Plugins and vendor islands

Decide per plugin, in this order:

1. **Replace with native/CSS/Alpine** when the plugin is used trivially (tooltip, simple modal, collapse, simple carousel, date input -> `<input type="date">`).
2. **Replace with server-driven HTMX** when the plugin mostly fetches and renders data (DataTables with server paging -> `hx-get` table fragments).
3. **Keep as a vendored island** when it is genuinely complex (rich text editor, charts, maps, advanced select with search, drag-and-drop sorting). The legacy code already depends on it, so keeping it is usually the lowest-risk path.

For islands:
- Vendor the exact version used by the legacy design into `static/js/vendor/` (pin it). If it depends on jQuery, vendor jQuery too and load it only on pages that need it.
- This is a guardrail event: record each island (plugin, version, pages, reason) as an exception in `gotth-rules.md` Project overrides.
- Keep islands inside their own container and never let jQuery code manage server data; the server stays the source of truth. If the island must send data, use a normal form field or an `hx-vals`/`hx-post` on a plain button.
- Initialize through `htmx.onLoad` (section 5) so it also works on swapped content.

## 5. Re-initialization after swaps

Plugins initialized on page load will not see HTML inserted by htmx. Initialize through `htmx.onLoad`, which runs for the initial page and for every swapped-in fragment:

```js
// static/js/app.js
htmx.onLoad(function (content) {
  // scope to the new content, and guard against double init
  content.querySelectorAll?.('[data-select2]:not([data-ready])').forEach(function (el) {
    $(el).select2();
    el.setAttribute('data-ready', '');
  });
});
```

Also destroy or clean up before an element is removed if the plugin leaves global listeners (`htmx:beforeCleanupElement`), and re-check that elements inside a swapped region keep their IDs unique.

## 6. Behavior checklist (per page)

- [ ] Every behavior in the inventory has a replacement or a documented drop.
- [ ] No inline `on*=` handlers remain; no `fetch`/XHR inside Alpine (ALP-1).
- [ ] Interactions still work after an HTMX swap (open a modal, then trigger a swap, then open it again).
- [ ] Keyboard: Tab order, Esc closes overlays, Enter/Space activate buttons.
- [ ] Loading states exist for requests that can take more than ~100ms (HTMX-6).
- [ ] The page works without JS for navigation and form submission where it did before.
- [ ] Console is free of errors and warnings on every converted page.