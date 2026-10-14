Saya buat file-nya dalam bahasa Inggris, karena file rules agent biasanya lebih konsisten begitu dan sumber aslinya (Karpathy dan ponytail) juga berbahasa Inggris.File sudah dibuat di `.kilo/rules-system-designer/design-philosophy.md`.

Karpathy dan ponytail saya sesuaikan untuk kerja desain, bukan coding, dengan urutan prioritas dari ponytail: benar, aman, tahan beban, teruji, cepat, ramping.

- **Part 1, prinsip inti (Karpathy):** think before designing, simplicity first, surgical changes, dan goal-driven. Kata "code" diganti "komponen/sistem", dan ada aturan "Noticed, not touched" untuk sistem yang sudah ada.
- **Part 2, lensa review (ponytail):** map first, daftar cek (bug, risk, scale, missing test, speed, lean), dan aturan "check before you claim". Penanda `shortcut:` saya ubah menjadi `shortcut / Limit / Revisit when`.
- **Part 3, baseline keamanan agnostik stack:** catatan ancaman singkat di setiap desain, plus default seperti validasi di boundary, authz per objek, timeout, idempotency, dan race check-then-write.
- **Part 4, keamanan Go:**
  - Hardening server, input, crypto, concurrency, dan outbound call.
  - Error dan logging, serta supply chain (`govulncheck`, `gosec`, `go test -race`).
  - Tabel pitfall untuk review cepat.
  - Item bertanda **(state)** adalah hal yang wajib dituliskan desainer, misalnya nilai timeout, batas body, dan batas concurrency.
- **Part 5, format output:** template desain/ADR, format temuan review (4 bagian, maks 20, dikelompokkan Must/Should/Nice, dengan contoh Go), dan checklist self-check di akhir.

Ada tiga asumsi yang bisa kamu ubah:
1. Mode ini hanya mendesain dan mereview, implementasi diserahkan ke mode code. Bagian "Mode boundaries" di Part 5 bisa dihapus kalau tidak sesuai.
2. File ditulis dalam bahasa Inggris. Kalau mau versi Indonesia, tinggal bilang.
3. Rujukan ke `os.Root` mengasumsikan Go 1.24 ke atas. Kalau toolchain kamu lebih lama, yang dipakai `filepath.IsLocal` (sudah disebut sebagai alternatif).