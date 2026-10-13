# Vendor Facts — Snapshot 2026-10-11

Hasil discovery terhadap HEAD tiap repo pada tanggal ini, plus keputusan awal beserta alasannya. Ini **snapshot, bukan sumber kebenaran aktif**: verifikasi lewat Gate A/C di `SKILL.md`. Temuan atau keputusan baru dicatat sebagai komentar di `.kilo/skills.manifest` (karena `.kilo/vendor/` read-only), bukan di file ini.

## 1. Vendor dan pola path

| Folder | Upstream | Path skill di manifest | Catatan |
|---|---|---|---|
| `matt` | `mattpocock/skills` | `matt/skills/<kategori>/<skill>` | `grilling`, `grill-me` di `productivity/`; sisanya `engineering/` |
| `samber` | `samber/cc-skills-golang` | `samber/skills/<skill>` | 46 skill pada tanggal ini |
| `spf13` | `spf13/go-skills` | `spf13/<skill>` | `go`, `cobra-viper`, `go-spec-reviewer`, `go-release`, `wails`, `fileflow-pathologize`; `templates/` bukan skill |
| `jetbrains` | `JetBrains/go-modern-guidelines` | `jetbrains/plugin/skills/use-modern-go` | satu skill |
| `karpathy` | `multica-ai/andrej-karpathy-skills` | `karpathy/skills/karpathy-guidelines` | satu skill |
| `ponytail` | `dietrichgebert/ponytail` | `ponytail/skills/<skill>` | 6 skill. Jangan `.openclaw/skills/` (salinan kedua, `name:` bentrok) |
| `gotth` | `pbKris/agent-skills-registry` (milik sendiri) | `gotth/skills/<skill>` | `git-convention`, `gotth-stack`, `gotth-code-reviewer`, `gotth-html-converter`, `change-manifest`, `skills-urls-agent-skills-registry` |

## 2. Ketergantungan (terverifikasi)

| Skill | Bergantung pada | Jenis | Mode |
|---|---|---|---|
| matt `grill-with-docs` | `grilling` (productivity) dan `domain-modeling` | keras (`Skill tool`) | plan |
| matt `implement` | `tdd` (`Skill tool`), `code-review` | keras | code |
| matt `tdd` | `codebase-design`, `code-review` | rujukan opsional | code |
| matt `to-spec`, `to-tickets` | konfigurasi `setup-matt-pocock-skills` dan label `ready-for-agent` | prasyarat setup | plan |
| gotth `gotth-code-reviewer`, `gotth-html-converter` | `../gotth-stack/references/gotth-rules.md` | keras (path) | `gotth-stack` di mode yang sama |
| samber (banyak skill) | "lihat juga" ke skill samber lain (mis. oops, slog) | lunak | abaikan kecuali lib dipakai |

Setup matt (sekali): aktifkan sementara `setup-matt-pocock-skills` **dan** `triage` di `plan`. Tanpa `triage`, setup melewati bagian label dan `to-spec`/`to-tickets` memakai label yang belum ada.

## 3. Tidak diaktifkan

| Skill | Alasan | Pemilik concern |
|---|---|---|
| samber `golang-how-to` | orkestrator "always active": memuat banyak skill, melawan manifest | — |
| samber `golang-modernize` | tumpang tindih `use-modern-go` | jetbrains |
| samber `golang-project-layout` | tumpang tindih `gotth-stack` | gotth |
| samber `golang-cli`, `golang-spf13-cobra`, `golang-spf13-viper` | tumpang tindih `cobra-viper` | spf13 (kondisional) |
| spf13 `go` | menduplikasi cluster samber (±27KB) | samber |
| spf13 `wails`, `fileflow-pathologize` | di luar kebutuhan | — |
| matt `grill-me`, `ask-matt`, `implement-spec`, `diagnosing-bugs`, `wayfinder` | `grill-me` sejenis `grilling`/`grill-with-docs`; `ask-matt` router atas repo matt penuh; `implement-spec` ≈ `implement`; `diagnosing-bugs` ≈ samber `golang-troubleshooting`; `wayfinder` besar, ditunda | matt / samber |
| ponytail `-review`, `-audit`, `-debt`, `-gain`, `-help` | reviewer sudah ada (matt `code-review`, `gotth-code-reviewer`); debt = `grep -rn "shortcut:"`; audit untuk legacy; gain/help tak berguna di Kilo | — |
| gotth `skills-urls-agent-skills-registry` | distribusi remote, tidak relevan di arsitektur submodule | — |

Vendor off atau ditunda beserta syarat revisit: `go-ai-assisted` (off); `cxuu/golang-skills` (jika gotth + samber terbukti kurang saat review nyata); `eduardo-sl/go-agent-skills` (jika scaffolding framework/ORM yang tidak dicakup samber); `metalagman/agent-skills` (ditolak: `git-convention` sudah memegang konvensi git); `affaan-m/ECC` (ditolak: overlap dengan samber).

## 4. Skill user-only (`disable-model-invocation: true`)

Terverifikasi di frontmatter: matt `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `triage`, `setup-matt-pocock-skills`. Dipanggil lewat `/nama`, tidak auto-trigger. Bukan user-only: matt `grilling`, `domain-modeling`, `tdd`, `code-review`; gotth dan samber (samber memakai `user-invocable: true`).

## 5. Baseline anggaran (≤10 efektif per mode)

Pada 2026-10-11: `plan` 9, `code` 10, `debug` 7 (global: `karpathy-guidelines`, `use-modern-go`). Mode `code` sudah penuh: skill baru di `code` berarti mengeluarkan yang lain.

## 6. Prinsip yang melandasi

Satu concern, satu pemilik. YAGNI: skill baru hanya jika ada kebutuhan konkret yang belum dicakup pemilik yang ada. Vendor read-only dan terkunci (submodule); satu-satunya tempat keputusan aktif adalah `.kilo/skills.manifest` dan blok `## Skills (multi-vendor)` di `AGENTS.md`.
