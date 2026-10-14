# Skills Code Layer — Implementation Notes

**Sumber:** `re-strategy.md` (Layer 3: Code / Eksekusi)  
**Mode:** `code` (native Kilo)  
**Folder:** `.kilo/skills-code/`  
**Rules:** `.kilo/rules-code/code-philosophy.md` (autoload via native `rules-{mode}/`)  
**Tujuan:** Eksekusi: implement → tdd → code-review → pr

---

## 1. Skills di Layer Code (Max 15)

| Skill | Vendor | Kategori | Panggil Via | Status |
|-------|--------|----------|-------------|--------|
| `implement` | matt | Engineering | `/implement` (user, 1 ticket/sesi) | ✅ Core |
| `implement-spec` | matt | Engineering | `/implement-spec` (parallel sub-agents) | ✅ Core |
| `tdd` | matt | Engineering | Model-invoked (di dalam implement) | ✅ Core |
| `diagnosing-bugs` | matt | Engineering | `/diagnosing-bugs` (user) | ✅ Core |
| `code-review` | matt | Engineering | `/code-review` (user, 2 axis: Standards + Spec) | ✅ Core |
| `pr` | matt | Engineering | `/pr` (user, shape PR body) | ✅ Core |
| `wizard` | matt | Engineering | `/wizard` (interactive bash provisioning) | ✅ Core |
| `gotth-stack` | pbk | Workflow | Auto-invoked via implement | ✅ Core |
| `git-convention` | pbk | Git | Auto-invoked via implement | ✅ Core |
| `go` (wrapper) | pbk | Arsitektur Idiomatik | `/go` (model-invoked via `index-go.md` router) | ✅ Core |
| `golang-error-handling` | samber | Go Depth | Model-invoked (di implement/tdd) | ✅ Core |
| `golang-testing` | samber | Go Depth | Model-invoked (di implement/tdd) | ✅ Core |
| `golang-safety` | samber | Go Depth | Model-invoked (di implement) | ✅ Core |
| `golang-security` | samber | Go Depth | Model-invoked (di implement) | ✅ Core |
| `golang-troubleshooting` | samber | Go Depth | Model-invoked (di implement) | ✅ Core |
| `golang-performance` | samber | Go Depth | Model-invoked (kondisional, butuh perf) | 🔄 Conditional |
| `golang-observability` | samber | Go Depth | Model-invoked (kondisional, logs/metrics/traces) | 🔄 Conditional |
| `golang-concurrency` | samber | Go Depth | Model-invoked (kondisional, kode konkuren) | 🔄 Conditional |
| `golang-database` | samber | Go Depth | Model-invoked (kondisional, akses DB) | 🔄 Conditional |
| `go-release` | spf13 | Release | `/go-release` (saat rilis) | ✅ Core (wajib) |
| `fileflow-pathologize` | spf13 | File Safety | `/fileflow-pathologize` (kondisional, file ops) | 🔄 Conditional |
| `wails` | spf13 | Desktop | `/wails` (kondisional, Wails project) | 🔄 Conditional |
| `cobra-viper` | spf13 | CLI | `/cobra-viper` (kondisional, CLI tool) | 🔄 Conditional |
| `gotth-html-converter` | pbk | Convert | `/gotth-html-converter` (kondisional, konversi HTML) | 🔄 Conditional |

**Total Core: 15 skills (batas max Kilo per mode)**  
**Conditional: 8 skills** — hanya aktifkan via `skills.manifest` uncomment saat butuh.

---

## 2. Vendor Ownership (Satu Concern Satu Pemilik)

| Concern | Pemilik | Alasan |
|---------|---------|--------|
| Pipeline eksekusi (implement→tdd→review→pr) | **matt** | Backbone pipeline |
| Arsitektur Go idiomatik (guardrail saat nulis code) | **spf13** via **pbk/go wrapper** | 1.142 baris, cover anti-pattern Java-in-Go |
| Sintaks Go modern (version-specific, deteksi go.mod) | **jetbrains** (`use-modern-go` global) | Best practice Go 1.22+ |
| Go Depth Production (error, test, safety, security, troubleshooting, perf, obs, concurrency, db) | **samber** | Domain expertise, checklist atomik |
| Release Engineering | **spf13** (`go-release`) | Semver, Deprecated:, GoReleaser |
| File Operations Safety | **spf13** (`fileflow-pathologize`) | Cross-filesystem safe move/copy |
| Desktop Apps (Wails) | **spf13** | Native desktop |
| CLI Architecture | **spf13** (`cobra-viper`) jika CLI tool / **samber** jika service dgn CLI kecil | Pilih satu, jangan keduanya |
| Stack GOTTH + Git Convention | **pbk** | Workflow konsisten + git hygiene |
| Go Wrapper Token Optimization | **pbk** (`go` via `index-go.md` router) | Hemat 83% token |

---

## 3. Conflict Guards (Dari ADR-013)

| Guard | Aturan |
|-------|--------|
| `spf13/go` aktif (via pbk/go) | `samber/golang-code-style`, `golang-design-patterns`, `golang-project-layout`, `golang-naming` → **DITOLAK** |
| `spf13/cobra-viper` aktif | `samber/golang-cli`, `golang-spf13-cobra`, `golang-spf13-viper` → **DITOLAK** |
| `spf13/go-spec-reviewer`, `go-release`, `wails`, `fileflow-pathologize` | **BOLEH COEXIST** (concern unik) |
| `samber/golang-safety` + `spf13/fileflow-pathologize` | **BOLEH COEXIST** (general safety vs file ops) |
| `jetbrains/use-modern-go` global | **TIDAK TABRAKAN** dgn `spf13/go` (syntax vs architecture) |

> Diedarkan di `link-skills.sh` + komentar di `skills.manifest`

---

## 4. Symlink Structure (`.kilo/skills-code/`)

```
skills-code/
├── tdd -> ../../vendor/matt/skills/engineering/tdd
├── implement -> ../../vendor/matt/skills/engineering/implement
├── code-review -> ../../vendor/matt/skills/engineering/code-review
├── pr -> ../../vendor/matt/skills/engineering/pr
├── gotth-stack -> ../../vendor/pbk/skills/gotth-stack
├── git-convention -> ../../vendor/pbk/skills/git-convention
├── go -> ../../vendor/pbk/go                              # WRAPPER
├── golang-error-handling -> ../../vendor/samber/skills/golang-error-handling
├── golang-testing -> ../../vendor/samber/skills/golang-testing
├── golang-safety -> ../../vendor/samber/skills/golang-safety
├── golang-security -> ../../vendor/samber/skills/golang-security
├── golang-troubleshooting -> ../../vendor/samber/skills/golang-troubleshooting
├── golang-performance -> ../../vendor/samber/skills/golang-performance       # 🔄
├── golang-observability -> ../../vendor/samber/skills/golang-observability   # 🔄
├── golang-concurrency -> ../../vendor/samber/skills/golang-concurrency       # 🔄
├── golang-database -> ../../vendor/samber/skills/golang-database             # 🔄
├── go-release -> ../../vendor/spf13/go-release                           # ✅
├── fileflow-pathologize -> ../../vendor/spf13/fileflow-pathologize         # 🔄
├── wails -> ../../vendor/spf13/wails                                       # 🔄
├── cobra-viper -> ../../vendor/spf13/cobra-viper                           # 🔄
└── gotth-html-converter -> ../../vendor/pbk/skills/gotth-html-converter    # 🔄
```

---

## 5. `/` Commands di `.kilo/commands/` (Code Mode)

| Command | File | Deskripsi |
|---------|------|-----------|
| `/implement` | `implement.md` | 1 ticket/sesi, drive TDD, call code-review |
| `/code-review` | `code-review.md` | 2 axis: Standards + Spec |
| `/pr` | `pr.md` | Summary + Evidence + Merge Danger |
| `/go` | `go.md` | Arsitektur Go idiomatik via index-go.md router |
| `/go-release` | `go-release.md` | Release engineering (spf13) |
| `/fileflow-pathologize` | `fileflow-pathologize.md` | File operations safety (kondisional) |
| `/wails` | `wails.md` | Wails desktop apps (kondisional) |
| `/cobra-viper` | `cobra-viper.md` | CLI architecture (kondisional) |
| `/gotth-html-converter` | `gotth-html-converter.md` | HTML design conversion (kondisional) |
| `/golang-concurrency` | `golang-concurrency.md` | Concurrency patterns (samber, kondisional) |

---

## 6. Workflow Code Mode

```
[Input] .kilo/plans/<timestamp>-<slug>.md (dari create-plan)
   |
   v
Mode: code
   - /implement (1 ticket/sesi)
       - drives /tdd (model-invoked)
       - guardrail: /go (model-invoked via index-go.md) → arsitektur idiomatik
       - samber skills auto-invoked: error-handling, testing, safety, security, troubleshooting
       - kondisional: performance, observability, concurrency, database
   - /code-review (2 axis: Standards + Spec compliance)
   - /pr (shape PR body: Summary + Evidence + Merge Danger)
   - /go-release (saat rilis)
```

---

## 7. Action Items (dari re-strategy.md §10.1)

| # | Item | Status |
|---|------|--------|
| 1 | Buat `vendor/pbk/go/` wrapper (SKILL.md tipis + index-go.md + references/) | ❌ Belum |
| 2 | Update `skills.manifest` entries code section (15 core + conditional) | ✅ Di doc |
| 3 | Update `link-skills.sh` handle pbk/go wrapper symlink folder | ✅ Di doc |
| 4 | Buat `.kilo/commands/*.md` untuk 10 code commands | ❌ Belum |
| 5 | Buat `.kilo/rules-code/code-philosophy.md` (Karpathy+Ponytail code) | ❌ Belum |
| 6 | Jalankan `.kilo/link-skills.sh` → verifikasi 15 skills di skills-code/ | ❌ Belum |

---

## 8. Rules Code Philosophy (`.kilo/rules-code/code-philosophy.md`)

**Sumber:** Karpathy + Ponytail (via pbk vendor)  
**Fokus:**
- Naming: explicit > implicit, domain language dari GLOSSARY.md
- Deep modules: shallow interface, deep implementation
- Testability: dependency injection, interface at boundary
- No ball-of-mud: package per domain, anti `utils/`, `common/`
- Simple > Clever: readability > cleverness
- Shortcuts: `// shortcut: <batas>, <kapan upgrade>` (grep-able)

---

## 9. Notes untuk Implementasi

1. **`pbk/go` wrapper** — jangan symlink file `SKILL.md` saja, symlink **seluruh folder** `vendor/pbk/go/` karena ada `index-go.md` + `references/`
2. **`gotth-stack`** depends on `gotth-code-reviewer` + `gotth-html-converter` → perlu di mode yang sama (code + debug)
3. **`implement`** commits ke active branch → pastikan branch name match `git-convention` sebelum panggil
4. **Conditional skills** — default commented di `skills.manifest`, uncomment + re-run `link-skills.sh` saat butuh
5. **Max 15 skills** — count: 8 matt + 2 pbk (gotth-stack, git-convention) + 1 pbk/go wrapper + 5 samber core + 1 spf13 go-release = 17 → perlu kurangi 2 conditional ke default-off

---

## 10. Quick Reference

```
CODE MODE (Layer 3 - Execute)
├── Core Pipeline (matt): implement → tdd → code-review → pr
├── Guardrails: go (pbk wrapper), use-modern-go (global)
├── Go Depth (samber): error, test, safety, security, troubleshooting
├── Conditional Go Depth: perf, obs, concurrency, db
├── Release: go-release (spf13, wajib)
├── Workflow: gotth-stack, git-convention (pbk)
├── Conditional: fileflow-pathologize, wails, cobra-viper, gotth-html-converter
└── Philosophy: rules-code/code-philosophy.md (autoload)
```