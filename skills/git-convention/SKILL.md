---
name: git-convention
description: Enforce branch/commit/tag naming with <developer-initial> suffix. Interview, inspect git, propose names. Use for "cek git rule", "buat branch baru", "mau commit". Baseline tags, Conventional Commits, PR-only.
---

# git-convention — Git Workflow Rules

> **Skill Name:** `git-convention`
> **Owner:** <developer-initial> (e.g., pbk)
> **Purpose:** Enforce industry-standard naming for branch, commit, and tag with developer initial `<developer-initial>`. When invoked, agent MUST interview user about task, then inspect workspace + git history.

## 0. How this skill works when invoked

**Trigger:** User types `/git-convention` or says "cek git rule", "buat branch baru", "mau commit".
> **Note:** Replace `<developer-initial>` with your initials (e.g., `pbk`, `jdoe`, `asm`) throughout this workflow.

### Agent Invocation Protocol (WAJIB)

**Step 1 - Interview (grill):**
Agent WAJIB tanya dulu, jangan langsung bikin branch:
```
1. Kamu mau ngerjain apa? (feat / fix / hotfix / refactor / chore / docs / test / spike)
2. Scope / modul apa? (auth, payment, api, ui, infra)
3. Ada ticket/issue number? (opsional, contoh: JIRA-123, #45)
4. Ini baseline / milestone? (kalau iya, kita butuh tag v<N>-baseline-*-<developer-initial>)
5. Developer initial kamu apa? (contoh: pbk, jdoe, asm)
```

**Step 2 - Workspace & Git Health Check:**
Agent WAJIB jalankan dan rangkum:

```
# 1. Workspace status
git status --porcelain
git diff --stat
git stash list

# 2. Current context
git branch --show-current
git remote -v
git log --oneline --graph --decorate -20
git tag --list "v*-*<developer-initial>" --sort=-v:refname | head -20

# 3. Cleanliness
git branch --merged
git fetch --prune --dry-run
```

Agent harus laporkan:
- Apakah working tree clean atau kotor
- Branch sekarang dan base branch (main/develop)
- 5 commit terakhir
- Tag baseline terakhir (v<N>-baseline-*-<developer-initial>)
- Apakah ada branch `*-<developer-initial>` yang sudah ada dengan nama mirip

**Step 3 - Decision:**
Baru setelah itu agent suggest nama branch/commit/tag sesuai rule di bawah, dan minta konfirmasi user.

---

## 1. Branch Naming Convention

### Format
```
<type>/<scope>-<short-desc>-<developer-initial>
```
Atau jika ada ticket:
```
<type>/<ticket>-<scope>-<short-desc>-<developer-initial>
```

### Rules
- Selalu lowercase, kebab-case, tanpa spasi
- Selalu akhiri dengan `-<developer-initial>` (developer initial)
- `<type>` WAJIB salah satu:
  - `feat` - fitur baru
  - `fix` - bugfix di develop
  - `hotfix` - bugfix urgent dari main
  - `refactor` - refactor tanpa ubah behavior
  - `chore` - tooling, config, deps, build
  - `docs` - dokumentasi only
  - `test` - tambah/perbaiki test only
  - `spike` - eksplorasi / POC, akan dibuang
  - `release` - persiapan release
- `<scope>` opsional tapi SANGAT dianjurkan: `auth`, `payment`, `api`, `ui`, `infra`, `db`
- `<short-desc>` max 4 kata, verb-noun, contoh: `add-login`, `fix-race-condition`
- Panjang total branch < 60 char
- Base branch:
  - `feat/*`, `fix/*`, `refactor/*`, `chore/*`, `docs/*`, `test/*`, `spike/*` -> dari `develop` (atau `main` jika repo trunk-based)
  - `hotfix/*`, `release/*` -> dari `main`
  - Jangan pernah branch dari branch `*-<developer-initial>` orang lain tanpa izin

### Examples (GOOD) — using `pbk` as example
```
feat/auth-add-login-pbk
feat/JIRA-123-payment-gateway-pbk
fix/api-handle-null-token-pbk
fix/checkout-race-pbk
hotfix/prod-login-crash-pbk
refactor/db-optimize-query-pbk
chore/setup-husky-lint-pbk
docs/readme-git-rule-pbk
test/auth-coverage-pbk
spike/evaluate-bun-pbk
release/v1.2.0-pbk
```

### Examples (BAD)
```
pbk-feat-login (salah posisi initial)
feat/Auth_Login (uppercase + underscore)
fix bug login (spasi)
feat/login (tanpa -<developer-initial>)
main (jangan push langsung)
```

---

## 2. Commit Message Convention

Mengikuti **Conventional Commits** + best practice.

### Format
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Rules
- `<type>` sama seperti branch type (feat, fix, hotfix, refactor, chore, docs, test, etc)
- `<scope>` sama seperti branch scope
- `<subject>`: imperative mood, lowercase, tanpa titik di akhir, max 72 char
  - GOOD: `add login throttling`
  - BAD: `Added login throttling.` / `Add Login Throttling`
- Body: jelaskan WHY, bukan WHAT. Bungkus di 72 char per baris. Pisahkan dengan baris kosong dari subject.
- Footer: `BREAKING CHANGE:`, `Closes #123`, `Refs JIRA-123`
- Satu commit = satu logical change. Jangan campur refactor + feat.
- Initial `<developer-initial>` TIDAK perlu di commit message (sudah ada di branch), tapi WAJIB ada di tag.
- Tidak ada `WIP` commit di branch yang akan di-PR. Gunakan `git commit --fixup` atau stash.

### Examples (GOOD)
```
feat(auth): add login throttling with redis

Prevent brute force by limiting 5 attempts per 15 minutes.
Uses redis sliding window counter.

Closes #45
```

```
fix(api): handle null token in auth middleware

Previously middleware crashed when Authorization header missing.
Now returns 401 with clear error.

Refs JIRA-123
```

```
chore(tooling): setup husky and lint-staged

Ensures conventional commits and eslint run pre-commit.
```

### Template untuk agent
Agent harus suggest commit message seperti ini setelah cek diff:
```bash
git diff --cached --stat
git diff --cached
```

---

## 3. Tag Convention

Tag dipakai untuk **baseline / milestone / checkpoint** yang penting. Selalu annotated tag.

### Format
```
v<N>-baseline-<context>-<developer-initial>
```
Atau untuk milestone lebih spesifik:
```
v<MAJOR>-baseline-<type>-<context>-<developer-initial>
v<MAJOR>.<MINOR>-baseline-<context>-<developer-initial>
```

### Rules
- Selalu lowercase, kebab-case
- Selalu mulai dengan `v<N>` dimana N = 0,1,2,... (iteration/major version)
- Selalu ada kata `baseline` di tengah (sebagai marker checkpoint)
- Selalu akhiri dengan `-<developer-initial>`
- `<context>`: deskripsi singkat baseline: `start`, `mvp-auth`, `payment-stable`, `pre-release`, `alpha`, `beta`, `rc`, `stable`, `infra-ready`
- Gunakan annotated tag: `git tag -a <tag> -m "message"`
- Tag dibuat dari branch `main` atau `develop` yang sudah clean & tested
- Jangan pernah delete/rewrite tag yang sudah di-push (immutable)
- Push tag: `git push origin <tag>`

### Examples (GOOD) — using `pbk` as example
```
v0-baseline-start-pbk
v0-baseline-initial-setup-pbk
v1-baseline-mvp-auth-pbk
v1-baseline-alpha-pbk
v2-baseline-payment-release-pbk
v2-baseline-beta-pbk
v3-baseline-stable-pbk
v1.0-baseline-rc-pbk
```

### Examples (BAD)
```
v0-basline-start-pbk (typo baseline)
baseline-v0-start (salah urutan)
v1-start-pbk (tanpa baseline keyword)
v0-baseline-start (tanpa -<developer-initial>)
v0_baseline_start_pbk (underscore)
```

### When to create baseline tag?
- `v0-baseline-start-<developer-initial>`: saat repo pertama kali siap di-develop
- Setiap selesai 1 fitur besar / MVP slice
- Sebelum refactor besar / migrasi beresiko
- Sebelum release ke staging/prod

### Agent checklist for tagging
```bash
# Pastikan
git checkout main
git pull
git status # harus clean
npm test / go test / etc # harus green
git tag -a v1-baseline-mvp-auth-<developer-initial> -m "baseline: MVP auth flow complete - login, register, jwt"
git push origin v1-baseline-mvp-auth-<developer-initial>
```

---

## 4. Full Workflow Checklist for Agent

Ketika `/git-convention` di-invoke, agent harus lakukan ini berurutan:

### Phase 1: Grill
- [ ] Tanya: mau ngerjain apa, type, scope, ticket, perlu baseline?
- [ ] Tanya: base branch mau dari mana? (main/develop)
- [ ] Tanya: developer initial apa? (contoh: pbk)

### Phase 2: Inspect
- [ ] `git status --porcelain` -> laporkan file dirty/untracked
- [ ] `git branch --show-current` dan `git log --oneline -10`
- [ ] `git tag --list "v*-*<developer-initial>" -n` -> baseline terakhir
- [ ] `git diff --stat` -> apa yang berubah
- [ ] Cek apakah ada branch dengan nama mirip: `git branch -a | grep <developer-initial>`

### Phase 3: Propose
- [ ] Suggest 1-2 nama branch yang valid sesuai rule: `<type>/<scope>-<desc>-<developer-initial>`
- [ ] Jika ada perubahan: suggest commit message conventional
- [ ] Jika user bilang ini baseline: suggest tag `v<N>-baseline-<context>-<developer-initial>` dengan N = last tag N+1
- [ ] Jelaskan kenapa nama itu dipilih

### Phase 4: Execute (after user YES)
- [ ] Jika working tree kotor dan user mau branch baru: `git stash push -m "temp: before <new-branch>-<developer-initial>"`
- [ ] `git checkout <base-branch> && git pull`
- [ ] `git checkout -b <new-branch-<developer-initial>>`
- [ ] Jika ada stash: `git stash pop`
- [ ] Untuk tag: `git tag -a <tag> -m "<message>"`

### Phase 5: Guardrails
- [ ] JANGAN pernah `git push --force` ke main/develop tanpa konfirmasi eksplisit
- [ ] JANGAN pernah commit langsung ke main/develop
- [ ] JANGAN pernah buat tag tanpa `-<developer-initial>` dan tanpa `baseline`
- [ ] Selalu ingatkan untuk buat PR, bukan push langsung

---

## 5. Quick Reference Card

```
BRANCH: <type>/<scope>-<kebab>-<developer-initial>
   ex: feat/auth-add-login-pbk
       fix/payment-race-condition-pbk

COMMIT: <type>(scope): <imperative subject>
   ex: feat(auth): add login throttling with redis

TAG: v<N>-baseline-<context>-<developer-initial> (annotated)
   ex: v0-baseline-start-pbk
       v1-baseline-mvp-auth-pbk
       v2-baseline-stable-pbk

ALWAYS: 
   - branch dari develop (atau main jika trunk)
   - clean workspace sebelum switch
   - PR, bukan direct push
   - tag dari main/develop yang green
```

---

## 6. Integration with Other Skills

Skill ini kompatibel dengan standar aliran kerja yang umum dipakai di berbagai proyek pengembangan:

- **Definisi fitur sebelum branch**: Sering kali ada skill atau proses untuk mendefinisikan fitur sebelum membuat branch. Biasanya melibatkan diskusi, penulisan deskripsi, dan persetujuan stakeholder.
- **Branch dibuat via konvensi**: Setiap ticket atau fitur dibuat menggunakan branch naming convention: `<type>/<scope>-<desc>-<developer-initial>`. Konvensi ini kompatibel dengan berbagai tools dan workflows.
- **Test dan code review di branch `*-<developer-initial>`**: Setiap branch dapat dijalankan uji (test, code review) sebelum di-merge. Alur ini kompatibel dengan tools seperti `/tdd`, `/code-review`, dan sejenis skill lain yang berjalan di branch sementara.
- **Suggest perbaikan setelah review**: Evaluasi perbaikan dari sesi evaluasi (seperti post-mortem, refleksi, atau sprint review) dapat mengintegrasikan hasil dari konvensi git-convention.

Cara install sebagai skill:
```
mkdir -p .claude/skills/git-convention/
cp git-convention.md .claude/skills/git-convention/SKILL.md
```

Atau pakai skills.sh:
```
npx skills@latest add <developer-initial>/git-convention
```

---

## 7. Example Session

**User:** /git-convention

**Agent:** 
> Mau ngerjain apa hari ini? 
> 1. Type: feat/fix/hotfix/chore?
> 2. Scope: auth/payment/api/ui?
> 3. Deskripsi singkat?
> 4. Perlu baseline tag setelah selesai?
> 5. Developer initial? (contoh: pbk)

**User:** Mau bikin fitur login throttling, scope auth, feat, initial pbk.

**Agent:** (setelah cek git status, log, tags)
> Kondisi sekarang:
> - Branch: main, clean
> - Last tag: v0-baseline-start-pbk
> - Last 3 commits: ...
> 
> Saya suggest:
> - Branch: `feat/auth-login-throttling-pbk` dari `develop`
> - Commit nanti: `feat(auth): add login throttling with redis`
> - Tag baseline setelah merge: `v1-baseline-mvp-auth-pbk`
> 
> Oke untuk saya buatin?

**User:** Ya

**Agent:** 
```bash
git checkout develop && git pull
git checkout -b feat/auth-login-throttling-pbk
```

---

MIT License - pbk