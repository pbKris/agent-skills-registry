diff --git a/skills/git-convention/SKILL.md b/skills/git-convention/SKILL.md
index ecd7310..562927d 100644
--- a/skills/git-convention/SKILL.md
+++ b/skills/git-convention/SKILL.md
@@ -1,6 +1,6 @@
 ---
 name: git-convention
-description: Enforce branch/commit/tag naming with <developer-initial> suffix. Interview, inspect git, propose names. Use for "cek git rule", "buat branch baru", "mau commit". Baseline tags, Conventional Commits, PR-only.
+description: Enforce branch/commit/tag naming with <developer-initial> suffix. Interview, inspect git, propose names. Use for "cek git rule", "buat branch baru", "mau commit". Baseline tags, Conventional Commits, PR-only. Repo ber-submodule (.gitmodules): bump/update vendor, baca references/submodule-vendor.md.
 ---
 
 # git-convention — Git Workflow Rules
@@ -44,6 +44,9 @@ git tag --list "v*-*<developer-initial>" --sort=-v:refname | head -20
 # 3. Cleanliness
 git branch --merged
 git fetch --prune --dry-run
+
+# 4. Submodule (hanya jika ada .gitmodules)
+git submodule status
 ```
 
 Agent harus laporkan:
@@ -52,6 +55,7 @@ Agent harus laporkan:
 - 5 commit terakhir
 - Tag baseline terakhir (v<N>-baseline-*-<developer-initial>)
 - Apakah ada branch `*-<developer-initial>` yang sudah ada dengan nama mirip
+- Jika ada `.gitmodules`: status submodule (sinkron / basi / kotor). Aturan lengkap: `references/submodule-vendor.md`
 
 **Step 3 - Decision:**
 Baru setelah itu agent suggest nama branch/commit/tag sesuai rule di bawah, dan minta konfirmasi user.
@@ -265,6 +269,7 @@ Ketika `/git-convention` di-invoke, agent harus lakukan ini berurutan:
 ### Phase 4: Execute (after user YES)
 - [ ] Jika working tree kotor dan user mau branch baru: `git stash push -m "temp: before <new-branch>-<developer-initial>"`
 - [ ] `git checkout <base-branch> && git pull`
+- [ ] Jika ada `.gitmodules`: sinkronkan submodule dan jalankan `.kilo/link-skills.sh` (`references/submodule-vendor.md` §3)
 - [ ] `git checkout -b <new-branch-<developer-initial>>`
 - [ ] Jika ada stash: `git stash pop`
 - [ ] Untuk tag: `git tag -a <tag> -m "<message>"`
@@ -274,6 +279,7 @@ Ketika `/git-convention` di-invoke, agent harus lakukan ini berurutan:
 - [ ] JANGAN pernah commit langsung ke main/develop
 - [ ] JANGAN pernah buat tag tanpa `-<developer-initial>` dan tanpa `baseline`
 - [ ] Selalu ingatkan untuk buat PR, bukan push langsung
+- [ ] JANGAN `git add -A` / `git commit -a` bila `git status` menampilkan baris submodule; vendor read-only, bump pointer = commit sendiri (`references/submodule-vendor.md` §4)
 
 ---
 
diff --git a/skills/git-convention/references/submodule-vendor.md b/skills/git-convention/references/submodule-vendor.md
new file mode 100644
index 0000000..bf7c05f
--- /dev/null
+++ b/skills/git-convention/references/submodule-vendor.md
@@ -0,0 +1,71 @@
+# Submodule Vendor — Aturan Git
+
+Baca file ini **hanya jika** repo punya `.gitmodules` (mis. `.kilo/vendor/*`) dan tugasnya menyentuh submodule: update/bump vendor, tambah/hapus vendor, ganti branch atau pull, atau `git status` menampilkan baris vendor. Selain itu abaikan.
+
+Diuji pada git 2.43 dengan submodule dangkal: `switch`, `submodule update --init --depth 1`, `submodule update --remote --depth 1`, `diff --submodule`, `add -A`. Tidak diuji: `pull`/`merge`/`rebase` dan penghapusan vendor.
+
+## 1. Prinsip
+
+- Vendor **read-only**. Isi `.kilo/vendor/<v>/` hanya berubah lewat repo asalnya. Untuk vendor milik sendiri (gotth): edit dan push di checkout terpisah, lalu bump pointer di repo ini.
+- Repo ini hanya mencatat **SHA pointer**. Skill adalah instruksi untuk agent, jadi perubahan pointer = perubahan perilaku agent. Perlakukan seperti perubahan kode: ditinjau dan di-commit sendiri.
+- `.kilo/skills/` dan `.kilo/skills-*/` adalah hasil generate. Tidak pernah di-commit.
+
+## 2. Membaca status
+
+| Tampilan | Arti | Tindakan |
+|---|---|---|
+| `git submodule status`, awalan spasi | sinkron dengan pointer | — |
+| awalan `+` dan `git status` ` M .kilo/vendor/x` | SHA vendor ≠ pointer: vendor basi (setelah ganti branch) atau bump disengaja | Jika tidak disengaja → §3. Jangan stage |
+| awalan `-` | belum di-init (folder kosong) | `git submodule update --init --depth 1` |
+| `git status` ` m .kilo/vendor/x` | isi vendor dimodifikasi | Laporkan ke user. `git add -A` tidak menyimpannya, jadi edit itu tidak pernah masuk commit. Jangan `restore` tanpa konfirmasi |
+| awalan `U` | konflik pointer | Selesaikan manual, tanya user |
+
+**Bahaya utama:** setelah `git switch` ke branch lain tanpa sinkron, vendor tertinggal di SHA branch sebelumnya dan tampil ` M`. `git add -A` atau `git commit -a` pada kondisi itu menyimpan **SHA basi sebagai pointer** (revert diam-diam).
+
+## 3. Sinkron setelah ganti konteks
+
+Setelah `checkout`, `switch`, `pull`, `merge`, `rebase`:
+
+1. Sekali per clone: `git config submodule.recurse true`. Setelah itu `switch`/`checkout` menyelaraskan submodule otomatis. Cek: `git config --get submodule.recurse`.
+2. Jika masih ` M` atau awalan `+`: `git submodule update --init --depth 1`.
+3. `.kilo/link-skills.sh` agar symlink mengikuti pointer. Harapan: tanpa `HILANG:` atau `BENTROK:`.
+
+## 4. Staging dan commit
+
+- Jika `git status` menampilkan baris vendor: stage per path eksplisit. JANGAN `git add -A`, `git add .`, `git commit -a`.
+- Bump pointer = commit tersendiri, tidak dicampur dengan fitur:
+  - `chore(skills): bump <vendor> to <sha7>`
+  - `chore(skills): add <vendor> submodule`
+  - `chore(skills): activate <skill> in <mode>` (perubahan `skills.manifest`; boleh satu commit dengan pointer bila saling terkait)
+- Branch: `chore/skills-bump-<vendor>-<developer-initial>`. Satu vendor per branch agar mudah di-revert.
+- Body commit: ringkas perubahan pada skill yang dipakai manifest (hasil §5 langkah 4), bukan salinan log upstream.
+
+## 5. Update vendor (hanya atas permintaan user)
+
+1. Buat branch sesuai §4. Catat pointer lama: `OLD=$(git rev-parse HEAD:.kilo/vendor/<v>)`
+2. `git submodule update --remote --depth 1 .kilo/vendor/<v>`, lalu `NEW=$(git -C .kilo/vendor/<v> rev-parse HEAD)`
+3. Jika `OLD` = `NEW`: selesai, tidak ada yang berubah.
+4. Tinjau **isi**, bukan log. Untuk setiap path vendor itu di `.kilo/skills.manifest`:
+   `git -C .kilo/vendor/<v> diff $OLD $NEW -- <path-tanpa-awalan-vendor>`
+   (`git diff --submodule=log` hanya menampilkan ujung `OLD` dan `NEW` karena riwayat dangkal; `git diff --submodule=diff` menampilkan seluruh isi.)
+5. Laporkan ke user: file skill terpakai yang berubah; skill hilang atau di-rename; perubahan frontmatter (`name:`, `disable-model-invocation`, `allowed-tools`); instruksi baru yang menjalankan perintah atau mengakses jaringan.
+6. `.kilo/link-skills.sh` → tanpa `HILANG:` atau `BENTROK:`. Tunggu konfirmasi user.
+7. `git add .kilo/vendor/<v>` (path eksplisit) lalu commit sesuai §4.
+
+Rollback: `git revert <commit-bump>`, lalu §3.
+
+## 6. Tambah / hapus vendor
+
+- Tambah: `git submodule add --depth 1 <url> .kilo/vendor/<name>`, tambah baris di `skills.manifest`, `.kilo/link-skills.sh`, commit `chore(skills): add <vendor> submodule`.
+- Hapus: hapus baris manifest vendor itu, `git submodule deinit -f .kilo/vendor/<name>`, `git rm -f .kilo/vendor/<name>`, `.kilo/link-skills.sh`, commit. Folder `.git/modules/.kilo/vendor/<name>` dihapus user bila perlu.
+
+## 7. Clone baru
+
+`git clone --recurse-submodules --shallow-submodules <repo>` → `git config submodule.recurse true` → `.kilo/link-skills.sh`. Jika folder vendor kosong: `git submodule update --init --depth 1`.
+
+## 8. Larangan
+
+- Mengedit, `git pull`, atau `git checkout` di dalam `.kilo/vendor/<v>/`.
+- `git submodule update --remote` tanpa diminta user.
+- Meng-commit hasil generate (`.kilo/skills*/`).
+- Mengubah `.gitmodules` (URL atau branch) tanpa konfirmasi: itu mengganti sumber instruksi agent.
diff --git a/skills/index.json b/skills/index.json
index 38429a7..0907ae9 100644
--- a/skills/index.json
+++ b/skills/index.json
@@ -2,11 +2,12 @@
   "skills": [
     {
       "name": "git-convention",
-      "description": "Enforce branch/commit/tag naming with <developer-initial> suffix. Interview, inspect git, propose names. Use for \"cek git rule\", \"buat branch baru\", \"mau commit\". Baseline tags, Conventional Commits, PR-only.",
+      "description": "Enforce branch/commit/tag naming with <developer-initial> suffix. Interview, inspect git, propose names. Use for \"cek git rule\", \"buat branch baru\", \"mau commit\". Baseline tags, Conventional Commits, PR-only. Repo ber-submodule (.gitmodules): bump/update vendor, baca references/submodule-vendor.md.",
       "files": [
-        "SKILL.md"
+        "SKILL.md",
+        "references/submodule-vendor.md"
       ],
-      "version": "1.0.0"
+      "version": "1.1.0"
     },
     {
       "name": "gotth-code-reviewer",