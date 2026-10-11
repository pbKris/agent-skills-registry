# Visual and Behavior Verification

Contents: 1. Approach · 2. Setup · 3. Stabilize the comparison · 4. Test template · 5. Reading diffs · 6. Behavior checks · 7. Definition of done

## 1. Approach

"Looks the same" is verified by comparing screenshots of the **legacy** page against the **converted** page at fixed widths, with fixed data. Use Playwright's screenshot comparison. Legacy output is the baseline; the converted app is the thing under test.

Note on tools: this adds Playwright as a dev/test dependency (a guardrail event: ask or confirm with the user before installing, and keep it out of production builds). If the user declines, fall back to manual side-by-side checks at the same widths and say verification was manual.

## 2. Setup (dev only)

```bash
npm init -y   # only if the repo has no package.json for tooling
npm i -D @playwright/test
npx playwright install chromium
```

`playwright.config.ts`:

```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  // Same path for baseline and comparison runs, independent of project name
  snapshotPathTemplate: '{testDir}/__snapshots__/{testFilePath}/{arg}{ext}',
  use: {
    baseURL: process.env.BASE_URL,        // legacy for baselines, Go app for verification
    colorScheme: 'light',
    deviceScaleFactor: 1,
  },
  expect: {
    toHaveScreenshot: { maxDiffPixelRatio: 0.005, animations: 'disabled' },
  },
});
```

Serve the legacy files on a local static server (any simple one, e.g. `npx serve legacy -l 4000`) and run the Go app with fixture data on its own port.

## 3. Stabilize the comparison

False diffs waste time. Before comparing:

- **Same machine, same browser, same OS** for baseline and verification (font rendering differs across OSes).
- **Fonts loaded:** wait for `document.fonts.ready`. Load the same font files in both versions.
- **Animations off:** `animations: 'disabled'` in the config, and wait for any entrance transitions to finish.
- **Deterministic data:** the Go app renders fixtures that match the legacy page's text and images. Dynamic content (dates, counters, random avatars) must be fixed or masked.
- **Mask unavoidable dynamic regions** with the `mask` option.
- **Scrollbars and carets:** hide the caret (`caret: 'hide'`, default) and keep the viewport identical.
- **Third-party embeds** (maps, ads, chat widgets): mask or stub.

## 4. Test template

```ts
import { test, expect } from '@playwright/test';

const widths = [
  { name: 'mobile',  width: 390,  height: 844 },
  { name: 'tablet',  width: 768,  height: 1024 },
  { name: 'desktop', width: 1280, height: 800 },
  { name: 'wide',    width: 1728, height: 1000 },
  // add widths just below/above each legacy breakpoint, e.g. 767/768, 991/992
];

// route in the app under test and path in legacy; keep the key = snapshot name
const pages = [
  { key: 'home', path: '/' },
  { key: 'items', path: '/items' },
];

for (const p of pages) {
  for (const w of widths) {
    test(`${p.key} @ ${w.name}`, async ({ page }) => {
      await page.setViewportSize({ width: w.width, height: w.height });
      await page.goto(p.path);
      await page.waitForLoadState('networkidle');
      await page.evaluate(() => document.fonts.ready);
      await expect(page).toHaveScreenshot(`${p.key}-${w.name}.png`, {
        fullPage: true,
        mask: [page.locator('[data-visual-mask]')],
      });
    });
  }
}
```

If legacy and Go app use different paths for the same page, keep a mapping (`legacyPath`, `appPath`) and pick per `BASE_URL`.

Workflow:

```bash
# 1. Capture baselines from the legacy site
BASE_URL=http://localhost:4000 npx playwright test --update-snapshots

# 2. Compare the converted app
BASE_URL=http://localhost:8080 npx playwright test
```

Component-level checks: add a catalog route (`/dev/components`) and snapshot individual components with `locator.screenshot()` against screenshots of the matching legacy snippet in a small harness page.

(This template is a starting point; adjust paths, waits, and thresholds to the project and run it once to confirm it works before relying on it.)

## 5. Reading diffs

- Review the diff images Playwright writes next to failures (expected, actual, diff).
- Classify each difference: **real regression** (fix), **intended change** (document in the report), **noise** (fix the test's stability), **legacy bug** (ask the user whether to preserve it).
- Fix at the source: tokens, base layer, component. Never patch a single page to hide a component problem.
- Threshold: start strict (`maxDiffPixelRatio` around 0.5%) and loosen only with a written reason. Differences concentrated in one region are more important than a low overall ratio, so look at the images.
- Re-run the whole page set after fixing a shared component, because it can affect other pages.

## 6. Behavior checks

Run alongside the visual checks, as Playwright tests or a manual script, for each converted page:

- Click through every interactive element from the inventory: menus, tabs, modals, forms, filters, pagination.
- Repeat key interactions **after an HTMX swap** (state, plugin initialization, focus).
- Submit forms with valid and invalid data; confirm the 422 fragment renders and errors appear in place.
- Keyboard-only pass: Tab order, Esc closes overlays, visible focus.
- Console and network: no JS errors, no 404 assets, no failed requests.
- Back/forward buttons and reload on any URL that uses `hx-push-url`.
- Slow network or throttled CPU: loading indicators appear and layout does not jump.

## 7. Definition of done

A component or page is **done** when:

- [ ] Visual comparison passes at all configured widths (or each remaining diff is documented and accepted by the user).
- [ ] Behavior checks pass, including after swaps.
- [ ] No console errors; no missing assets.
- [ ] `templ generate`, `go build ./...`, `go vet ./...`, `go test ./...` pass.
- [ ] Guardrails respected; exceptions recorded in Project overrides.
- [ ] The report lists what was verified and what was not.