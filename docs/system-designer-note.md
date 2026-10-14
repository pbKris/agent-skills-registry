File `system-designer.md` sudah dibuat di `.kilo/agents/`, mengikuti template di bagian 5.2 dokumenmu lalu dilengkapi dari bagian lain (4.1, 7.1, 8, 9).

**Isi file:**
- **Frontmatter:** `mode: primary` dan permission dari template (`read`, `edit`, `bash`, `glob`, `grep`, `question`). `skill` saya ubah dari `allow` biasa menjadi allowlist: `"*": deny`, lalu 14 skill yang boleh dipanggil. Isinya 12 skill dari manifest `system-designer`, ditambah `cobra-viper` (kondisional) dan `setup-matt-pocock-skills` (global).
- **Aturan awal:** `design-philosophy.md` dimuat otomatis lewat `rules-system-designer/`, jadi agent tidak membacanya ulang kecuali belum ada di konteks.
- **Pra-cek:** memastikan `docs/agents/` ada (kalau belum, user disuruh menjalankan setup sekali, agent tidak menjalankannya sendiri), membaca konfigurasi tracker, `GLOSSARY.md`, ADR, dan `go.mod`.
- **Alur kerja:** `grill-with-docs` (dengan `domain-modeling`) → `to-spec` → `go-spec-reviewer` (khusus Go) → `to-tickets` → handoff ke `plan` mode. `/go` berfungsi sebagai guardrail arsitektur, bukan langkah. Setiap langkah selesai, agent menyebut perintah berikutnya dan menunggu, tidak berantai sendiri.
- **Tabel 14 skill:** cara memulai tiap skill (user via `/command`, atau agent sendiri untuk `domain-modeling`) dan fungsinya. Skill `go` dimuat lewat router `SKILL.md` → `index-go.md` → satu file referensi.
- **Kontrak output:** hanya boleh menulis `GLOSSARY.md`, `docs/adr/`, `artifacts/SPEC.md`, tiket, dan `.scratch/` untuk prototype. Dilarang menyentuh source code, `.kilo/plans/`, `vendor/`, manifest, dan config. Perubahan skill harus lewat `/change-manifest` di plan mode.

**Soal "mode/agent lain tidak bisa memanggilnya":**
- `mode: primary` mencegah agent lain men-delegasikan tugas ke system-designer.
- Allowlist `skill` di file ini mengunci skill apa yang bisa dimuat system-designer. Sebaliknya, skill di `skills-system-designer/` hanya terlihat di mode ini berkat pola folder native, seperti yang kamu tulis di dokumen.
- File ini tidak bisa membatasi agent lain. Kalau mau dikunci dari sisi mereka, tambahkan `deny` untuk nama skill itu di permission `plan`, `code`, `debug`, dan `ask`, dan pastikan setiap `.kilo/commands/*.md` untuk skill ini punya `agent: system-designer`.
- Sintaks `skill:` berbentuk map (pola `"*": deny`) saya ambil dari konvensi opencode. Tolong cek di versi Kilo-mu, dan kalau tidak didukung, kembalikan ke `skill: allow` seperti di template dokumen.

**Ketidakkonsistenan di dokumen sumber:**
1. `grilling` ada di manifest tapi tidak dijelaskan di tabel 4.1. Saya mengasumsikannya sebagai versi polos dari `grill-with-docs` dan memakainya hanya jika user meminta.
2. `/triage` terikat ke system-designer (bagian 8, 9.1), tapi tidak ada skill `triage` di manifest, jadi tidak masuk allowlist. Kalau skill itu mau dipakai, tambahkan ke manifest dan allowlist.
3. Manifest mengomentari `matt/wayfinder` sebagai "ditolak", padahal skill itu aktif di baris system-designer. Saya ikuti yang aktif.

Sama seperti dua file sebelumnya, isinya berbahasa Inggris.