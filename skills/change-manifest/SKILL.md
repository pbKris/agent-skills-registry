---
name: change-manifest
description: Ubah pilihan skill vendor di .kilo/skills.manifest lalu regenerasi symlink (link-skills.sh); tambah, pindah mode, hapus, atau ganti skill/vendor. Gate wajib - pemilik concern, ketergantungan, nama bentrok, anggaran per mode. Use for "tambah skill", "aktifkan skill", "hapus skill dari manifest", "pindah skill ke mode", "ganti skill", "update manifest", "link-skills".
---

# Change Manifest

`.kilo/skills.manifest` adalah satu-satunya sumber kebenaran skill aktif. `.kilo/skills*/` hanya hasil generate. Setiap perubahan lewat prosedur ini agar keputusan tetap konsisten antar sesi. **Menolak adalah hasil yang valid.**

Mode → folder: `global`→`skills/`, `plan`→`skills-plan/`, `code`→`skills-code/`, `debug`→`skills-debug/`, `ask`→`skills-ask/`. Path di manifest relatif ke `.kilo/vendor/`.

## 0. Prasyarat

```bash
ls .kilo/skills.manifest .kilo/link-skills.sh
git submodule status        # tanpa awalan '-'; jika ada, ikuti git-convention/references/submodule-vendor.md §2
```

Baca: blok `## Skills (multi-vendor)` di `AGENTS.md` (pemilik concern, aturan aktif), bagian "ditolak" dan komentar `# dep:` di manifest, lalu `references/vendor-facts.md` (snapshot fakta vendor dan alasan keputusan awal). Jika file `.kilo/*` tidak ada → berhenti, arahkan ke `.kilo/plans/multi-vendor-skills-implementation.md`.

## 1. Fase 1 — Analisis (read-only)

Klasifikasi: **ADD**, **MOVE** (ubah mode), **REMOVE**, **REPLACE** (ganti pemilik concern), **VENDOR BARU** (submodule dulu: `git-convention/references/submodule-vendor.md` §6), **SEMENTARA** (aktif sebentar, mis. setup; tidak di-commit).

### Gate A — Discovery

```bash
find .kilo/vendor/<v>/ -name SKILL.md -not -path '*/.git/*' -not -path '*/.openclaw/*' -not -path '*/templates/*' | sed 's|^\.kilo/vendor/||; s|/SKILL.md$||' | sort
f=.kilo/vendor/<path>; sed -n '1,12p' $f/SKILL.md; wc -c < $f/SKILL.md; du -sb $f | cut -f1
grep -m3 -E '^(disable-model-invocation|user-invocable):' $f/SKILL.md
```

Catat `name:` (nama symlink = `name:`, bukan nama folder), deskripsi, ukuran, dan flag. Path tidak ada → `HILANG`, jangan lanjut.

### Gate B — Pemilik concern

1. Tentukan **satu** concern skill itu. Cek pemilik di `AGENTS.md` dan daftar "ditolak" di manifest.
2. Concern sudah punya pemilik → **TOLAK**. Pengecualian hanya REPLACE: user setuju, pemilik lama dinonaktifkan di perubahan yang sama, `AGENTS.md` diperbarui.
3. Skill orkestrator (memuat skill lain otomatis, mis. `golang-how-to`) → tolak: melawan manifest.
4. Concern beda tapi deskripsi tumpang tindih dengan skill aktif → tandai dan tanya user.

### Gate C — Ketergantungan

```bash
p=.kilo/vendor/<path>; self=$(basename $p)
grep -nE 'Skill tool' $p/SKILL.md | cut -c1-120
for o in $(find .kilo/vendor/<v>/ -name SKILL.md -not -path '*/.git/*' | xargs -n1 dirname | xargs -n1 basename | sort -u); do
  [ "$o" = "$self" ] && continue
  grep -nE "(^|[^a-z-])/?$o([^a-z-]|$)" $p/SKILL.md | head -1 | sed "s|^|  $o: |" | cut -c1-120
done
grep -noE '\.\./[A-Za-z0-9._/-]+' $p/SKILL.md | sort -u      # abaikan yang bukan path skill
```

- **Keras** (`Skill tool`, atau path `../<skill>/`) → pasangannya harus aktif di **mode yang sama**. Tambahkan sekaligus atau tolak. Alasan `../`: tool yang menormalisasi path secara leksikal mencari `skills-<mode>/<skill>/`.
- **Lunak** ("lihat juga") → abaikan kecuali project memakai.
- **REMOVE/MOVE** → cek siapa yang bergantung pada skill ini (nilai hasilnya dengan membaca barisnya, banyak kata umum yang cocok):
  `grep -nE "(^|[^a-z-])/?<name>([^a-z-]|$)" .kilo/skills/*/SKILL.md .kilo/skills-*/*/SKILL.md | cut -c1-140`
- Skill yang butuh setup sebelum dipakai: lihat `references/vendor-facts.md` §2.

### Gate D — Nama dan anggaran

Script hanya mendeteksi `name:` kembar **di dalam satu folder mode**. Dua cek manual setelah perubahan diterapkan:

```bash
for m in plan code debug ask; do comm -12 <(ls .kilo/skills | sort) <(ls .kilo/skills-$m | sort); done   # global vs mode: harus kosong
find .kilo/vendor/ -name SKILL.md -not -path '*/.git/*' -not -path '*/.openclaw/*' -not -path '*/templates/*' | while read f; do sed -n "s/^name:[[:space:]]*//p" "$f" | head -1 | tr -d "\"'\r"; done | sort | uniq -d   # antar vendor: harus kosong
```

**Anggaran: ≤10 skill efektif per mode (global + mode):**
`for m in plan code debug ask; do echo $m $(( $(ls .kilo/skills | wc -l) + $(ls .kilo/skills-$m | wc -l) )); done`

Hitung **hasil akhir** setelah perubahan. Lebih dari 10 → user memilih satu untuk dikeluarkan atau dipindah. Jangan menaikkan angka tanpa keputusan user. Skill `disable-model-invocation: true` tetap dihitung (konservatif, belum terverifikasi apakah Kilo menyembunyikannya).

### Gate E — Perilaku (ADD/REPLACE)

Skill adalah instruksi untuk agent: tinjau seperti kode.

```bash
p=.kilo/vendor/<path>
grep -niE '\bcommit|\bpush|git reset|npx |npm i|go get|curl |rm -rf' $p/*.md $p/*/*.md 2>/dev/null | cut -c1-140 | head -8
find $p -type f -perm -u+x -not -name '*.md'; ls $p | grep -E '^(scripts|hooks)$'
```

Temuan **dilaporkan**, bukan otomatis menolak: perintah commit/instal, file yang bisa dieksekusi, atau instruksi yang bertentangan dengan blok `## Skills` di `AGENTS.md` (mis. `implement` meng-commit ke branch aktif).

## 2. Konfirmasi

Tampilkan laporan ini dan **tunggu persetujuan**. Tanpa "ya", jangan edit.

```
Perubahan : ADD matt/skills/engineering/foo → code
Concern   : <x>  | Pemilik saat ini: <y>  → ok / TOLAK / REPLACE
Gate C    : ikut ditambah: <pasangan keras> | lunak diabaikan: <...>
Gate D    : bentrok: tidak ada | anggaran code 10 → 11 ✗ (keluarkan salah satu: <...>)
Gate E    : <temuan perilaku> / tidak ada
Rekomendasi: terapkan / tolak / alternatif
```

## 3. Fase 2 — Terapkan

Mode aktif tidak bisa mengedit file atau menjalankan perintah (mis. plan)? Berhenti di §2: tuliskan perubahan yang disetujui sebagai baris `+`/`-` manifest dan serahkan ke user (atau mode `code`).

1. Branch sesuai `git-convention`: `chore/skills-<desc>-<developer-initial>` (SEMENTARA: tanpa branch).
2. Edit `.kilo/skills.manifest`: satu baris per perubahan, format `<mode>  <vendor>/<path>`. REMOVE = hapus baris (bukan dikomentari), kecuali baris di bagian kondisional. Urutan bagian: global, plan, code, debug, ask, sementara, kondisional, ditolak.
3. Catat di manifest sebagai komentar agar keputusan bertahan: `# dep: <skill> -> <pasangan> (mode sama)` untuk ketergantungan keras, dan satu baris di bagian "ditolak" untuk skill yang ditolak atau dikeluarkan (`# <skill>  (<alasan singkat>)`).
4. `.kilo/link-skills.sh` → harapan: tanpa `HILANG:`, `BENTROK:`, `MODE?:`; jumlah baris `ok` = jumlah baris manifest aktif.
5. Verifikasi: Gate D (tiga cek), symlink rusak (`for l in .kilo/skills*/*; do [ -f "$l/SKILL.md" ] || echo "RUSAK: $l"; done`), dan `ls -l .kilo/skills-<mode>/<name>` menunjuk vendor.
6. Uji di Kilo (sesi baru): "What skills do you have available?" → skill muncul (atau hilang untuk REMOVE) pada mode yang benar. Skill user-only tidak terdaftar: uji dengan `/nama`.
7. Jika pemilik concern atau anggaran berubah → perbarui blok `## Skills (multi-vendor)` di `AGENTS.md`.
8. Commit dengan path eksplisit (`git add .kilo/skills.manifest AGENTS.md`; jangan `-A`; hasil generate di-gitignore):
   `chore(skills): <activate|deactivate|move|replace> <skill> in <mode>`
   Body: concern, pemilik, hasil gate, efek anggaran. PR, bukan push langsung. Pointer vendor baru = commit terpisah.
   SEMENTARA: setelah dipakai, hapus barisnya dan jalankan `.kilo/link-skills.sh`; jangan di-commit.

## 4. Larangan

- Mengedit `.kilo/skills*/` atau membuat symlink manual.
- Mengedit isi `.kilo/vendor/**`. Perbaikan lewat repo asal (gotth: checkout terpisah, lalu bump pointer).
- `npx skills add`: membuat salinan datar, melawan arsitektur.
- Menambah skill tanpa lolos Gate B–D, atau menaikkan anggaran tanpa persetujuan user.
- Meng-commit baris SEMENTARA, atau mengabaikan `HILANG:`/`BENTROK:`.

## 5. Kasus khusus

- **Bump vendor mengubah/menghapus skill terpakai** (`HILANG:`) → analisis sebagai REMOVE atau REPLACE.
- **`BENTROK:`** → aktifkan satu; yang lain dipindah mode atau dicatat di "ditolak".
- **Vendor baru** → submodule dulu, lalu Gate A untuk semua kandidat dan cek duplikat antar vendor (Gate D).
