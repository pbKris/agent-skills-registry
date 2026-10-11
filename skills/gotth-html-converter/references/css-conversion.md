# CSS Conversion to Tailwind v4 (CSS-first, no config file)

Contents: 1. Preconditions · 2. Strategy: bridge, then migrate · 3. Entry file layout · 4. Token extraction · 5. Preprocessors · 6. Breakpoints · 7. Preflight and changed defaults · 8. Hard-to-translate CSS · 9. Fonts, icons, assets · 10. Source detection · 11. Bootstrap (provisional)

The project uses **Tailwind CSS v4 with CSS-first configuration and no `tailwind.config.js`**. Everything below configures Tailwind in the CSS entry file (`static/css/input.css`). When unsure whether a directive, utility, or variant exists in the pinned version, check the docs rather than relying on v3 memory.

## 1. Preconditions (check before converting)

1. **Browser support.** Tailwind v4 targets Safari 16.4+, Chrome 111+, and Firefox 128+ (it relies on `@property` and `color-mix()`). If the legacy design must support older browsers, stop and tell the user: v4 cannot serve them. Record the answer in `source-stack-profile.md`.
2. **No preprocessor in the pipeline.** Tailwind v4 is not designed to be used with Sass, Less, or Stylus. Convert from the **compiled CSS** of the legacy design and write plain CSS from here on (section 5).
3. **No config file.** Do not create `tailwind.config.js`, and do not add PostCSS or Autoprefixer (v4 handles imports and vendor prefixing).

## 2. Strategy: bridge, then migrate

Rewriting all legacy CSS into utilities at once risks visual drift. Default plan for plain CSS:

1. **Bridge.** Load the legacy CSS **inside a cascade layer** so Tailwind utilities can override it. Tailwind v4 uses native CSS cascade layers (`theme, base, components, utilities`), and **unlayered CSS beats every layer**, so legacy CSS left unlayered would override your utilities. Import it into the `components` layer:

   ```css
   @import "tailwindcss";
   @import "./legacy.css" layer(components);
   ```

   (Or paste the legacy rules inside `@layer components { ... }`.) A legacy reset/normalize goes into `layer(base)` instead, after Tailwind's own Preflight, and only if the design needs it. Record the bridge as an exception to `TW-1` in Project overrides.
2. **Migrate per component.** When a component passes visual verification, translate its legacy classes to utilities in the `.templ`, then delete the corresponding legacy rules and re-verify.
3. **Retire.** When the bridge file is empty, remove the import.

If the design is small (a few pages, little CSS), skip the bridge and convert directly per component. Say which you chose, and why, in the first report.

## 3. Entry file layout

```css
/* static/css/input.css */
@import "tailwindcss";
@import "./legacy.css" layer(components);   /* bridge: remove when empty */

/* Do not scan the legacy design folder: its class names would generate stray utilities */
@source not "../../legacy";

@theme {
  /* tokens extracted from the legacy CSS (section 4) */
}

@layer base {
  [x-cloak] { display: none !important; }
  dialog { margin: auto; }                    /* v4 Preflight removed dialog margins */
  /* compat rules for changed defaults (section 7), only if the design needs them */
}

@utility container {                          /* v4: container options are no longer in config */
  margin-inline: auto;
  padding-inline: 2rem;
}
```

`@source` paths are relative to the stylesheet. Adjust them to the real folder layout.

## 4. Token extraction (do this before components)

Read the legacy CSS (including CSS custom properties) and fill a token map:

| Token type | Legacy values found | `@theme` namespace | Action |
|---|---|---|---|
| Colors | `#1a73e8`, `#202124`, ... | `--color-*` | add exact values (e.g. `--color-brand-500: #1a73e8;`) |
| Font families | `"Inter", sans-serif` | `--font-*` | add; `font-display` etc. |
| Type scale | 12/14/16/20/28 px | `--text-*` (with `--text-*--line-height`) | add exact sizes and line heights |
| Font weights, tracking, leading | values used | `--font-weight-*`, `--tracking-*`, `--leading-*` | add only if different from defaults |
| Spacing | 4, 8, 12, 16, 24, 32 px | `--spacing` (base multiplier, default `0.25rem`) | keep the default if the legacy scale is multiples of 4px; otherwise change `--spacing` or add `--spacing-*` steps |
| Radii | 4, 8, 999 px | `--radius-*` | add or override |
| Shadows | box-shadow strings | `--shadow-*` | add custom shadows with the exact legacy values |
| Breakpoints | 600, 900, 1200 px | `--breakpoint-*` | see section 6 |
| Container widths | max-width values | `--container-*` | add if the legacy widths differ |
| Transitions, keyframes | durations, easings | `--ease-*`, `--animate-*` | add; define `@keyframes` inside `@theme` next to `--animate-*` (or outside `@theme` to always emit) |

Rules:
- **The default palette is OKLCH.** A legacy hex such as `#3b82f6` that merely looks like `blue-500` is not identical. Define exact legacy colors as tokens; map to a default only when the user accepts the small difference. To remove the default palette entirely, use `--color-*: initial;` inside `@theme` and define only the design's colors.
- Round nothing. 15px stays 15px (a token or a one-off arbitrary value), not 16px "because it is close". Accumulated rounding is visible drift.
- Use a token instead of an arbitrary value (`w-[347px]`) when a value appears more than once.
- Tokens that reference other variables need `@theme inline { ... }` so utilities resolve the value at the right place.
- Use `@theme` for values that should create utilities and `:root` (inside `@layer base`) for plain CSS variables that should not. Legacy custom properties that the old CSS still reads can stay in `:root` during the bridge phase.
- Use `var(--color-brand-500)` in custom CSS, not the v3 `theme()` function.

## 5. Preprocessors

If the source is Sass/SCSS/Less/Stylus, work from the **compiled CSS** output (what the browser actually uses). Map variables to `@theme` tokens and mixins to components or `@utility` afterwards. Do not feed `.scss` through Tailwind v4.

## 6. Breakpoints: desktop-first vs mobile-first

Tailwind is mobile-first (`md:` means `min-width`). Many legacy stylesheets are desktop-first (`@media (max-width: ...)`). Do not translate them one-to-one.

1. List every media query and the rule changes under it.
2. Derive the base (smallest-screen) styles, then express larger screens as `sm:`/`md:`/`lg:` overrides.
3. Set the breakpoint tokens to the legacy values so edges match exactly, for example `--breakpoint-md: 768px; --breakpoint-lg: 992px;` (or `--breakpoint-3xl` for new ones). Unit matters: Tailwind's defaults are in `rem`; use `px` if the legacy queries use `px`.
4. For a faithful desktop-first port of a complex page, the `max-*` variants (`max-md:`) are available; prefer mobile-first for anything new.
5. Test widths **just below and just above** each breakpoint (e.g. 767/768, 991/992) during visual verification.

## 7. Preflight and changed defaults

Preflight resets margins, heading sizes and weights, list styles, `img` display, and border defaults. v4 also changed several defaults. All of these can shift a converted layout:

| Change in v4 | Effect | Compat rule (add only if the design needs it) |
|---|---|---|
| Default border/divide color is `currentColor` | Borders lose the old gray | name the color explicitly, or `@layer base { *, ::after, ::before, ::backdrop, ::file-selector-button { border-color: var(--color-gray-200, currentColor); } }` |
| `ring` is 1px `currentColor` (was 3px blue) | focus rings look thinner | use `ring-3` plus a color, or `@theme { --default-ring-width: 3px; --default-ring-color: var(--color-blue-500); }` (compat only) |
| Placeholder is current text color at 50% | different placeholder tone | `@layer base { input::placeholder, textarea::placeholder { color: var(--color-gray-400); } }` |
| Buttons use `cursor: default` | no pointer cursor | `@layer base { button:not(:disabled), [role="button"]:not(:disabled) { cursor: pointer; } }` |
| `<dialog>` margins reset | dialogs no longer centered | `@layer base { dialog { margin: auto; } }` |
| `hidden` attribute beats `block`/`flex` | elements that relied on class priority | remove the `hidden` attribute where the element should show |
| `hover:` only on hover-capable devices | tap-to-hover behavior disappears on touch | `@custom-variant hover (&:hover);` to restore, but prefer not depending on hover |
| `space-y-*`, `divide-y-*` selectors changed | spacing differs with inline children or extra margins | use `flex flex-col gap-*` |

Process:
- Build a **kitchen-sink page** (all heading levels, paragraphs, lists, links, blockquote, table, form controls, buttons, images, a dialog) in both legacy and new, and compare **before** converting any component.
- Restore only what the design needs, in `@layer base`, using the legacy values.
- Do not disable Preflight unless there is a strong reason; if you do, record it as an exception.
- Check `box-sizing`, `line-height`, `button`/`input` font inheritance, and `img { display: block }` first; these cause most one-pixel shifts.

## 8. Hard-to-translate CSS

| Legacy | Approach |
|---|---|
| `@keyframes`, complex animations | `--animate-*` plus `@keyframes` inside `@theme`, or keep in `@layer components` |
| `::before`/`::after` decorations | `before:`/`after:` with `content-['']`, or keep as component CSS if complicated |
| `:nth-child`, sibling selectors | variants (`odd:`, `even:`, `first:`, `last:`, `peer-*`, `group-*`), or keep as component CSS |
| `!important`, high-specificity overrides | remove by fixing layer order and specificity; in v4 the important modifier is a suffix (`flex!`) |
| `@supports`, `@media print`, `prefers-reduced-motion`, dark mode | carry over explicitly (`print:`, `motion-reduce:`, `dark:` or a custom variant via `@custom-variant`) |
| Complex grid templates | `grid-cols-[...]` arbitrary values (underscores for spaces) or tokens |
| Vendor prefixes | drop; v4 prefixes automatically |
| CSS that must behave like a utility with variants | `@utility name { ... }` (not `@layer utilities`) |
| Background images/gradients | utilities where exact (`bg-linear-to-r`), otherwise component CSS referencing `/static/...` assets |
| Variables in arbitrary values | `bg-(--brand)`, not `bg-[--brand]` |

Do not convert CSS that is complex and working just to reach "100% utilities". Keep it in a named component layer and note it.

## 9. Fonts, icons, assets

- Move font files to `static/fonts/`, define `@font-face` in `input.css` (`@layer base`), keep the legacy `font-display`, and preload critical fonts in the layout.
- Icon fonts: keep the same font and class mapping initially; replace with inline SVG components later (separate task).
- Update asset URLs to `/static/...`. Check for 404s in the browser console on every converted page.

## 10. Source detection

v4 scans project files automatically as plain text. It skips `.gitignore`d files, `node_modules`, binary files, and CSS files.

- `.templ` files are found automatically if they are not git-ignored.
- **Exclude the legacy design folder** with `@source not "../../legacy";` so its HTML class names (`flex`, `container`, ...) do not generate stray utilities that interfere with the bridged legacy CSS.
- Add directories outside the default scan with `@source "path"`; use `@import "tailwindcss" source(none);` with explicit `@source` lines for fully explicit scanning.
- Classes that never appear literally in source (rare) are safelisted with `@source inline("...")`.
- Class names must appear complete (TW-2). Map values to full class names in Go.

## 11. Bootstrap (provisional until the stack is confirmed)

If the source turns out to use Bootstrap, adjust the plan:

- **Do not mix** Bootstrap CSS with Tailwind long-term: conflicting resets and utility names (`.container`, `.row`, `.col-*`, `.d-flex`, `.m-*`, `.p-*`) will fight. Bridge strategy: keep Bootstrap's compiled CSS in `layer(components)` temporarily (or in `layer(base)` if it provides the reset), convert component by component, then remove it.
- Mapping of common pieces (verify exact values per Bootstrap version):

| Bootstrap | Tailwind v4 direction |
|---|---|
| `.container` | `@utility container { ... }` with matching max widths and padding |
| `.row` / `.col-*` | `grid grid-cols-12 gap-*` with `col-span-*`, or flex; Bootstrap gutters are padding-based |
| `.d-flex`, `.justify-*`, `.align-*` | `flex`, `justify-*`, `items-*` |
| `.m-*`, `.p-*` | Tailwind spacing (Bootstrap steps are 0.25/0.5/1/1.5/3 rem; map exactly with tokens or arbitrary values) |
| `.btn`, `.card`, `.alert`, `.badge`, `.navbar` | templ components with utilities; verify padding, radius, and colors against Bootstrap |
| `.collapse`, `.dropdown`, `.modal`, `.tooltip` (JS) | Alpine / `<dialog>` per `jquery-to-gotth.md` |
| Breakpoints (576/768/992/1200/1400) | `--breakpoint-*` tokens in `px` matching these exactly |

- Bootstrap customizations (Sass variables) live in the project's Sass: extract final values from the compiled CSS.