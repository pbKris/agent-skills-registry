# Analisis cepat dari `re-strategy.md`

## 1. Skills TIDAK Sama — Mapping Explisit per Mode

| Mode | Matt Skills (dari Table 2.1 & agent-files.manifest) |
|------|------------------------------------------------------|
| **system-designer** | `grill-with-docs`, `domain-modeling`, `codebase-design`, `improve-codebase-architecture`, `to-spec`, `to-tickets`, `wayfinder`, `prototype`, `research`, `grilling` (productivity) |
| **ask** | `ask-matt`, `grill-me`, `handoff`, `wait-what` |

**Total system-designer saat ini: 12 skills** (10 matt + `pbk/go` + `spf13/go-spec-reviewer`). **Kuota tersisa: 3 slots** (max 15).

---

## 2. Perbedaan Fundamental (Bukan Oversight)

| Aspek | `skills-ask` | `skills-system-designer` |
|-------|--------------|--------------------------|
| **Tujuan** | Navigasi, Q&A, context mgmt | Design workflow → artifacts (GLOSSARY, ADR, SPEC) |
| **Permission** | Read-only (native Kilo `ask`) | `edit: allow` (custom mode, unrestricted) |
| **Context Window** | Standard | Large (reasoning-heavy) |
| **Output** | Tidak ada file artifact | `GLOSSARY.md`, `docs/adr/`, `artifacts/SPEC.md` |

### Skill-by-skill:

| Skill | Mode | Kenapa Dipisah |
|-------|------|----------------|
| `grill-me` vs `grill-with-docs` | ask vs system-designer | `grill-me` = ad-hoc Q&A, no artifacts. `grill-with-docs` = structured interview → domain model → spec |
| `ask-matt` | ask only | Router untuk "skill mana yang dipakai?" — di system-designer user sudah tahu workflow (grill→spec→tickets) |
| `handoff` / `wait-what` | ask only | Session mgmt untuk multi-session Q&A. Di system-designer: artifacts **adalah** context (GLOSSARY/ADR/SPEC persist) |

---

## 3. Apakah Perlu Ditambahkan ke system-designer?

**Tidak perlu.** Alasan:

1. **`ask-matt`** — Di system-designer workflow sudah fixed: `grill-with-docs` → `to-spec` → `to-tickets`. Router tidak dibutuhkan.

2. **`grill-me`** — Berbeda concern: `grill-with-docs` sudah cover domain modeling + spec creation. `grill-me` untuk exploration belajar, bukan design delivery.

3. **`handoff` / `wait-what`** — Di system-designer, **artifacts = context persistence**. `GLOSSARY.md` + `docs/adr/` + `SPEC.md` *adalah* handoff yang persistent, tidak butuh file terpisah.

4. **Kuota 12/15** — Sisa 3 slot. Lebih baik disisakan untuk:
   - `spf13/cobra-viper` (kondisional, jika project CLI)
   - Future skill: `architecture-review` atau `decision-log` jika perlu

---

## 4. Solusi Terbaik: **Pertahankan Pemisahan (As Designed)**

```
┌─────────────────────────────────────────────────────────────┐
│  USER FLOW YANG BENAR                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  "Mau bikin fitur tapi bingung mulai dari mana?"           │
│       │                                                     │
│       ▼                                                     │
│  Mode: ASK                                                  │
│  /ask-matt → routes ke /grill-me (explorasi)               │
│  /grill-me → clear thinking, no artifacts                  │
│       │                                                     │
│       ▼ (siap design)                                       │
│  Mode: SYSTEM-DESIGNER                                      │
│  /grill-with-docs → GLOSSARY.md + ADRs                     │
│  /to-spec → artifacts/SPEC.md                              │
│  /to-tickets → tickets                                     │
│       │                                                     │
│       ▼                                                     │
│  Mode: PLAN → /create-plan → .kilo/plans/                  │
│       │                                                     │
│       ▼                                                     │
│  Mode: CODE → /implement → code                            │
│                                                             │
│  Multi-session design?                                      │
│  System-designer: BACA GLOSSARY.md + ADR + SPEC (sudah    │
│  persist, tidak butuh /handoff)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Jika User Ingin `handoff`/`wait-what` di System-Designer

**Workaround tanpa symlink ganda:**
```bash
# Di system-designer mode, user bisa:
# 1. Switch cepat ke ask mode
/mode ask
/handoff          # simpan context
/mode system-designer

# 2. Atau gunakan artifacts sebagai context (recommended)
cat GLOSSARY.md docs/adr/*.md artifacts/SPEC.md
```

**Atau** buat command wrapper di `.kilo/commands/design-handoff.md` yang memanggil `handoff` skill via sub-agent — tapi ini over-engineering. Artifacts sudah solve ini.

---

## 6. Kesimpulan

| Pertanyaan | Jawaban |
|------------|---------|
| Apakah skills ask juga ada di system-designer? | **Tidak** — mapping eksplisit berbeda di re-strategy.md |
| Apakah kamu salah memetakan? | **Tidak** — pemetaannya sudah benar per strategi |
| Tambahkan symlink ke system-designer? | **Jangan** — concern berbeda, permission berbeda, artifacts solve context persistence |
| Kuota system-designer cukup? | **Ya** — 12/15, sisa 3 untuk kondisional/future |

**Strategi sudah konsisten:** `ask` = safe exploration/router, `system-designer` = design delivery dengan artifacts. Pisahkan mode, jangan campur skills.

---

## Analisis Vendor untuk `architecture-review` & `decision-log`

### 1. Status Saat Ini di `re-strategy.md`

**Kedua skill ini TIDAK ADA** di tabel vendor assignments di `re-strategy.md` (section 2.2 & 3). Hanya muncul di file analisis sebagai "future skill":

```
# di analisa-skills-ask-vs-skills-system-designer.md:
- Future skill: `architecture-review` atau `decision-log` jika perlu
```

Namun, skills ini **ada di file research lain** (PRIMARY-CONTEXT):
- `go-architecture-review` terdaftar di `PRIMARY-CONTEXT-vendor-analisis-review.md` dan `vendor-table-never-used.md`
- Di mata Eduard (Staff Engineer) sebagai skill miliknya

---

### 2. Penentuan Vendor berdasarkan "Satu Concern, Satu Pemilik"

Mengadaptasi pattern yang ada di `re-strategy.md`, berikut prediksi vendor:

| Skill | Predisi Vendor | Alasan |
|-------|----------------|--------|
| **architecture-review** | **matt** | • Memiliki concerns: "Review" di pipeline matt (Story → Spec → **Review** → PR) <br>• Sudah ada `improve-codebase-architecture` di vendor matt yang generate architecture report <br>• Complementer dengan `to-spec`/`to-tickets` |
| **decision-log** | **spf13** | • Concerns: "Arsitektur Go Idiomatik" + "Release Engineering" <br>• ADRs (Architecture Decision Records) sudah di `rules-code/code-philosophy.md` (spf13) <br>• Release Engineering (`go-release`) menangani capture decision <br>• Complementer dengan `go-spec-reviewer` |

---

### 3. Validasi dengan Pattern Lain

Dari `PRIMARY-CONTEXT-vendor-analisis-review.yaml`:
```yaml
# Di plan mode:
plan: [ask-matt, architecture-review, wayfinder, to-spec, to-tickets]
```

Ini menunjukkan `architecture-review` bisa muncul di **plan mode** sebagai translator skill, bukan sekadar code-review.

---

### 4. Rekomendasi Implementasi

Karena belum ada di `re-strategy.md`, ada 2 opsi:

#### Opsi A: Masukkan ke re-strategy.md Sekarang
Tambahkan ke table vendor concern:

```diff
| Go Depth Production (error, testing, safety, security, troubleshooting, perf, obs, concurrency, db) | **samber** | matt `tdd`/`implement` panggil samber skills implicit |
+| Architecture Review & Decision Log | **matt** + **spf13** | - architecture-review: matt (review pipeline) <br> - decision-log: spf13 (ADRs + release) |
```

#### Opsi B: Biarkan sebagai Skills Baru (belum di strategi utama)
Jika belum siap diintegrasi ke strategi 3-layer:
- Bikin `.kilo/skills-system-designer/architecture-review` (jika butuh di system-designer)
- Atau `.kilo/skills-code/architecture-review` (jika butuh di code review)

---

### 5. Penutup

| Skill | Vendor Rekomendasi | Status |
|-------|-------------------|--------|
| `architecture-review` | **matt** | Sesuai pipeline Review→PR, complementer `improve-codebase-architecture` |
| `decision-log` | **spf13** | Sesuai concerns arsitektur Go + ADRs + Release Engineering |

**Catatan:** Kedua skill belum terdaftar di `agent-files.manifest` atau `symlinks-agent-files.sh`. Jika mau diintegrasikan, perlu:
1. Tambahkan ke `agent-files.manifest` di mode yang sesuai
2. Buat symlink via `symlinks-agent-files.sh`
3. Buat command di `.kilo/commands/`

**Solusi terbaik:** Masukkan ke `re-strategy.md` di section 10.1 (Immediate) sebagai item baru jika butuh segera, atau biarkan sebagai skill fleksibel yang bisa dipanggil dari mana mode saja via `/command`.