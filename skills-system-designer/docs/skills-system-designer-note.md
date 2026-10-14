# Skills System Designer Layer — Design Notes

**Sumber:** `re-strategy.md` (Layer 1: System Designer)  
**Mode:** `system-designer` (custom mode Kilo)  
**Folder:** `.kilo/skills-system-designer/`  
**Rules:** `.kilo/rules-system-designer/design-philosophy.md` (autoload via native `rules-{mode}/`)  
**Tujuan:** Alignment + Domain Modeling + Spec → Output: `GLOSSARY.md` + `docs/adr/` + `artifacts/SPEC.md`

---

## 1. Skills di Layer 1 (System Designer) — Max 12

| Skill | Vendor | Kategori | Panggil Via | Status |
|-------|--------|----------|-------------|--------|
| `grill-with-docs` | matt | Engineering | `/grill-with-docs` (user-invoked) | ✅ Core |
| `domain-modeling` | matt | Engineering | Model-invoked (paralel dengan grill) | ✅ Core |
| `codebase-design` | matt | Engineering | `/codebase-design` (reference) | ✅ Core |
| `improve-codebase-architecture` | matt | Engineering | `/improve-codebase-architecture` | ✅ Core |
| `to-spec` | matt | Engineering | `/to-spec` (user-invoked) | ✅ Core |
| `to-tickets` | matt | Engineering | `/to-tickets` (user-invoked) | ✅ Core |
| `wayfinder` | matt | Engineering | `/wayfinder` (work besar > 1 sesi) | ✅ Core |
| `prototype` | matt | Engineering | `/prototype` (throwaway pertanyaan desain) | ✅ Core |
| `research` | matt | Engineering | `/research` (background agent) | ✅ Core |
| `go` (wrapper) | pbk | Arsitektur Idiomatik | `/go` (user-invoked, via `index-go.md` router) | ✅ Core |
| `go-spec-reviewer` | spf13 | Spec Review | `/go-spec-reviewer` (user-invoked, setelah to-spec) | ✅ Core |
| `cobra-viper` | spf13 | CLI Design | `/cobra-viper` (kondisional, hanya project CLI) | 🔄 Conditional |

**Total Core: 11 skills** (di bawah batas max 15 Kilo per mode)  
**Conditional: 1 skill** — hanya aktifkan via `skills.manifest` uncomment saat project CLI.

---

## 2. Vendor Ownership (Satu Concern Satu Pemilik)

| Concern | Pemilik | Alasan |
|---------|---------|--------|
| Pipeline design (story→spec→tickets) | **matt** | Backbone pipeline |
| Domain modeling (entities, boundaries, ubiquitous language) | **matt** | Part of grill-with-docs flow |
| Arsitektur Go idiomatik (flat, domain packages, anti utils, interface discovered) | **spf13** via **pbk/go wrapper** | 1.142 baris, cover anti-pattern Java-in-Go |
| Spec Review Go | **spf13** (`go-spec-reviewer`) | Review spec bahasa Go spesifik |
| Sintaks Go modern (version-specific, deteksi go.mod) | **jetbrains** (`use-modern-go` global) | Best practice Go 1.22+ |
| CLI Architecture | **spf13** (`cobra-viper`) jika CLI tool | Author asli Cobra/Viper |
| Big effort mapping (>1 sesi) | **matt** (`wayfinder`) | Decision tickets untuk work besar |
| Throwaway prototype | **matt** (`prototype`) | Jawab 1 pertanyaan desain |
| Background research | **matt** (`research`) | Notes, bukan decisions |
| Go Wrapper Token Optimization | **pbk** (`go` via `index-go.md` router) | Hemat 83% token |
| Minimalis/Pragmatis (Filosofis) | **pbk** (rules `design-philosophy.md`) | Anti-overengineering, shortcuts tercatat |

---

## 3. Conflict Guards (Dari ADR-013, Berlaku Juga di System-Designer)

| Guard | Aturan |
|-------|--------|
| `spf13/go` aktif (via pbk/go) | `samber/golang-code-style`, `golang-design-patterns`, `golang-project-layout`, `golang-naming` → **DITOLAK** |
| `spf13/cobra-viper` aktif | `samber/golang-cli`, `golang-spf13-cobra`, `golang-spf13-viper` → **DITOLAK** |
| `spf13/go-spec-reviewer` | **BOLEH COEXIST** (concern unik: spec review Go) |
| `jetbrains/use-modern-go` global | **TIDAK TABRAKAN** dgn `spf13/go` (syntax vs architecture) |

> Diedarkan di `link-skills.sh` + komentar di `skills.manifest`

---

## 4. Symlink Structure (`.kilo/skills-system-designer/`)

```
skills-system-designer/
├── grilling -> ../../vendor/matt/skills/productivity/grilling
├── domain-modeling -> ../../vendor/matt/skills/engineering/domain-modeling
├── grill-with-docs -> ../../vendor/matt/skills/engineering/grill-with-docs
├── codebase-design -> ../../vendor/matt/skills/engineering/codebase-design
├── improve-codebase-architecture -> ../../vendor/matt/skills/engineering/improve-codebase-architecture
├── to-spec -> ../../vendor/matt/skills/engineering/to-spec
├── to-tickets -> ../../vendor/matt/skills/engineering/to-tickets
├── wayfinder -> ../../vendor/matt/skills/engineering/wayfinder
├── prototype -> ../../vendor/matt/skills/engineering/prototype
├── research -> ../../vendor/matt/skills/engineering/research
├── go -> ../../vendor/pbk/go                              # WRAPPER (folder, bukan file)
├── go-spec-reviewer -> ../../vendor/spf13/go-spec-reviewer
└── cobra-viper -> ../../vendor/spf13/cobra-viper           # 🔄 Conditional
```

---

## 5. `/` Commands di `.kilo/commands/` (System Designer Mode)

| Command | File | Deskripsi |
|---------|------|-----------|
| `/grill-with-docs` | `grill-with-docs.md` | Interview + domain modeling parallel |
| `/to-spec` | `to-spec.md` | Spec dari hasil grill |
| `/to-tickets` | `to-tickets.md` | Split spec → tracer-bullet tickets |
| `/go` | `go.md` | Arsitektur Go idiomatik via index-go.md router |
| `/go-spec-reviewer` | `go-spec-reviewer.md` | Review spec Go (spf13) |
| `/cobra-viper` | `cobra-viper.md` | CLI architecture (kondisional) |
| `/setup-matt-pocock-skills` | `setup-matt-pocock-skills.md` | Run sekali per repo (setup config) |
| `/triage` | `triage.md` | Issue eksternal → agent-ready brief |
| `/wayfinder` | `wayfinder.md` | Map effort besar → decision tickets |
| `/prototype` | `prototype.md` | Throwaway prototype untuk pertanyaan desain |
| `/research` | `research.md` | Background research agent |
| `/codebase-design` | `codebase-design.md` | Reference: how codebase should be shaped |
| `/improve-codebase-architecture` | `improve-codebase-architecture.md` | Existing code drift: find structural problems |

---

## 6. Workflow System Designer Mode

```
[User] "Mau bikin fitur X"
   |
   v
Mode: system-designer
   - SELALU baca .kilo/rules-system-designer/design-philosophy.md di awal sesi
   |
   +-- /grill-with-docs (user-invoked)
   |      - Interview user against existing docs
   |      - Parallel: domain-modeling (model-invoked) untuk terms/entities/boundaries baru
   |      - Output: update GLOSSARY.md + docs/adr/
   |
   +-- /to-spec (user-invoked, setelah grill settle)
   |      - Input: GLOSSARY.md + docs/adr/
   |      - Output: artifacts/SPEC.md
   |
   +-- /go (user-invoked, via pbk wrapper index-go.md)
   |      - Guardrail arsitektur idiomatik (flat, domain packages, anti utils)
   |      - Fixes go back into spec
   |
   +-- /go-spec-reviewer (user-invoked, setelah to-spec, Go only)
   |      - Review spec bahasa Go spesifik (spf13)
   |      - Fixes go back into spec
   |
   +-- /to-tickets (user-invoked, setelah spec final)
   |      - Split spec → thin tracer-bullet tickets
   |      - Local files atau GitHub issues (per docs/agents/ config)
   |
   +-- Side branches (hanya saat butuh):
   |      - /prototype → throwaway di .scratch/ untuk pertanyaan desain
   |      - /research → background agent, hasil notes bukan decisions
   |      - /codebase-design → reference shaping
   |      - /improve-codebase-architecture → existing code drift
   |      - /wayfinder → work > 1 sesi, map ke decision tickets
   |
   +-- Handoff ke plan mode: /create-plan
```

---

## 6. Output Artifacts (Hanya Di Mode System-Designer)

| Artifact | Path | Ditulis Oleh |
|----------|------|--------------|
| Domain Language (Ubiquitous Language) | `GLOSSARY.md` (repo root) | `grill-with-docs`, `domain-modeling` |
| Architecture Decision Records | `docs/adr/` (numbered, follow existing format) | `grill-with-docs`, `domain-modeling`, `go`, `go-spec-reviewer` |
| Specification | `artifacts/SPEC.md` | `to-spec` |
| Tickets | Local files atau GitHub issues | `to-tickets` (per `docs/agents/` config) |
| Throwaway Prototypes | `.scratch/` only | `prototype` (never copied to source) |
| Research Notes | `.scratch/` only | `research` |

> **Critical:** `edit: allow` di mode system-designer → unrestricted seperti architect, bisa nulis bebas ke paths di atas. Tidak kena hardening `plan`.

---

## 7. Rules Design Philosophy (`.kilo/rules-system-designer/design-philosophy.md`)

**Sumber:** Karpathy + Ponytail (via pbk vendor)  
**Fokus:**
- **Simple > Clever**: readability over cleverness
- **Deep Modules**: shallow interface, deep implementation
- **Ubiquitous Language**: terms dari GLOSSARY.md dipakai konsisten
- **ADRs**: record decisions dengan trade-offs, bukan hanya choices
- **Prototype First**: throwaway prototype untuk jawab pertanyaan desain sebelum commit
- **Shortcuts**: `// shortcut: <batas>, <kapan upgrade>` (grep-able via `grep -rn "shortcut:" .`)
- **State Assumptions**: explicit assumptions di awal
- **Checkable Success Criteria**: verifiable, not vague
- **Security Note**: singkat tapi ada

---

## 8. Action Items (dari re-strategy.md §10.1, relevan system-designer)

| # | Item | Status |
|---|------|--------|
| 1 | Buat `vendor/pbk/go/` wrapper (SKILL.md tipis + index-go.md + references/) | ❌ Belum |
| 2 | Update `skills.manifest` entries system-designer section (11 core + 1 conditional) | ✅ Di doc |
| 3 | Update `link-skills.sh` handle pbk/go wrapper symlink folder + custom modes | ✅ Di doc |
| 4 | Buat `.kilo/commands/*.md` untuk 13 system-designer commands | ❌ Belum |
| 5 | Buat `.kilo/rules-system-designer/design-philosophy.md` (Karpathy+Ponytail design) | ❌ Belum |
| 6 | Buat `.kilo/agents/system-designer.md` (trigger auto-discovery custom mode) | ❌ Belum |
| 7 | Buat `kilo.jsonc` dengan customModes system-designer + create-plan | ❌ Belum |
| 8 | Jalankan `.kilo/link-skills.sh` → verifikasi 11 skills di skills-system-designer/ | ❌ Belum |
| 9 | Jalankan `/setup-matt-pocock-skills` sekali untuk setup `docs/agents/` | ❌ Belum |

---

## 9. Notes untuk Implementasi

1. **`pbk/go` wrapper** — jangan symlink file `SKILL.md` saja, symlink **seluruh folder** `vendor/pbk/go/` karena ada `index-go.md` + `references/`
2. **`domain-modeling`** dipanggil **model-invoked** paralel dengan `grill-with-docs` — bukan user-invoked
3. **`go` + `go-spec-reviewer`** hanya untuk project Go (`go.mod` exists) — guardrail opsional
4. **`cobra-viper`** conditional — hanya uncomment di manifest + re-run link-skills.sh jika project CLI tool
5. **`wayfinder`** — hanya untuk work besar > 1 sesi, map ke decision tickets
6. **`prototype` & `research`** — output ke `.scratch/` only, never ke source tree
7. **Max 15 skills** — current 11 core + 1 conditional = 12, well under limit

---

## 10. Quick Reference

```
SYSTEM-DESIGNER MODE (Layer 1 - Design)
├── Core Pipeline (matt): grill-with-docs → to-spec → to-tickets
├── Parallel: domain-modeling (model-invoked)
├── Guardrails: go (pbk wrapper), go-spec-reviewer (spf13)
├── Reference: codebase-design, improve-codebase-architecture
├── Big Work: wayfinder (decision tickets)
├── Throwaway: prototype, research (→ .scratch/)
├── Conditional: cobra-viper (CLI only)
├── Setup Once: setup-matt-pocock-skills (general folder)
└── Philosophy: rules-system-designer/design-philosophy.md (autoload)
```

---

## 11. Prasyarat Sebelum Pipeline Bisa Jalan

1. **`/setup-matt-pocock-skills`** harus dijalankan **sekali per repo** (manual, user-invoked)
   - Output: `docs/agents/*.md` (issue tracker config, domain docs location, triage labels)
2. **`docs/agents/`** harus exist — jika tidak, stop dan suruh user jalankan setup
3. **`GLOSSARY.md`** dan **`docs/adr/`** — baca jika exist di awal sesi
4. **`go.mod`** — jika exist, catat Go version, `go` + `go-spec-reviewer` skills apply

---

## 12. Handoff ke Plan Mode

```
End session dengan note:
1. Artifacts written/changed: GLOSSARY.md, docs/adr/*.md, artifacts/SPEC.md, tickets
2. Assumptions made + open questions
3. Noticed, not touched: problems outside request
4. Next step: switch to plan mode → /create-plan
```