# Source Stack Profile

**Status: ASSUMED** (set to `CONFIRMED` once the real stack is known)

This file describes what the source UI (the design to convert) is built with. Other files in this skill defer to it. Until the status is `CONFIRMED`, treat every value below as a hypothesis and verify it against the actual files during intake (SKILL.md section 1).

## 1. Profile

| Item | Value | Confidence |
|---|---|---|
| HTML | Plain static HTML, multiple pages | assumed |
| CSS framework | None (hand-written CSS) | assumed |
| CSS preprocessor | None (plain `.css`). Note: Tailwind v4 cannot be used with Sass/Less/Stylus; compile first | assumed |
| JS library | jQuery (version unknown) | assumed |
| jQuery plugins | Unknown (list when found: select2, datatables, datepicker, slick, ...) | unknown |
| Other JS libs | Unknown (charts, maps, editors, ...) | unknown |
| Build tooling | None | assumed |
| Icon system | Unknown (icon font / SVG sprite / inline SVG / images) | unknown |
| Fonts | Unknown (local files / Google Fonts / system) | unknown |
| Image handling | Static files | assumed |
| Browser targets | Evergreen browsers. Must meet Tailwind v4's floor: Safari 16.4+, Chrome 111+, Firefox 128+ (ask the user to confirm) | assumed |
| Design source of truth | The legacy HTML/CSS render (no Figma/spec) | assumed |
| Number of pages | Unknown | unknown |
| Responsive approach | Unknown (desktop-first `max-width` or mobile-first `min-width`) | unknown |
| Dark mode / print styles | Unknown | unknown |
| Legacy location in repo | `legacy/` | assumed |

## 2. Detected facts (filled by the agent during intake)

Record what was actually found, with evidence (file names, grep counts). Overwrite assumptions above when they are contradicted.

| Fact | Evidence | Impact on plan |
|---|---|---|
| (none yet) | | |

## 3. Variants to add when the real stack is known

Delete what does not apply. Each variant needs a short mapping section in the named file.

| If the source uses... | Add/extend | Notes |
|---|---|---|
| Bootstrap 3/4/5 | `css-conversion.md` section 11 (Bootstrap) | Grid, utilities, components; its JS (modal, dropdown, collapse, tooltip) maps via `jquery-to-gotth.md` |
| Sass/SCSS or Less | `css-conversion.md` section 5 | Convert from compiled CSS first; variables become `@theme` tokens |
| Another CSS framework (Bulma, Foundation, Materialize) | `css-conversion.md` | Add a class-mapping table |
| Tailwind already | `css-conversion.md` | If v3, migrate to v4 first (renamed utilities, config to `@theme`); if v4, mostly copy classes |
| Vue/React/Angular components | Ask the user before proceeding | Conversion becomes a rewrite of component logic, not a markup port |
| Specific jQuery plugins | `jquery-to-gotth.md` section 4 | Decide per plugin: native/Alpine replacement or vendored island |
| Webpack/Vite bundling | `visual-regression.md` | Capture baselines from the built output, not source |

## 4. Update procedure

1. Fill section 1 with real values; set Confidence to `confirmed`.
2. Set **Status** at the top to `CONFIRMED`.
3. Add the Project overrides (versions, plugins as exceptions) to `gotth-stack/references/gotth-rules.md` section 2.
4. Extend the variant sections from the table in section 3.
5. Re-run intake detection and update the inventory if anything changed.