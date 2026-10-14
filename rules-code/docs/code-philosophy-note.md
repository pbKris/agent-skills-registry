File untuk mode code sudah dibuat di `.kilo/rules-code/code-philosophy.md`. Strukturnya sejajar dengan versi system-designer, jadi kedua mode memakai bahasa dan urutan prioritas yang sama.

Karena ini mode coding, Karpathy dan ponytail menyatu langsung tanpa banyak adaptasi:

- **Dua mode kerja:** *Change mode* (default) memakai Karpathy, jadi hanya menyentuh yang diminta. *Audit mode* memakai ponytail sebagai laporan sekali jalan tanpa mengubah kode. Ini menyelesaikan benturan di antara keduanya: ponytail menyuruh menandai kode yang bisa dihapus, Karpathy melarang menghapus dead code lama. Jadi di change mode dead code hanya dilaporkan, di audit mode dilaporkan sebagai temuan, dan baru dihapus setelah user bilang "fix N".
- **Part 1 (Karpathy):** keempat prinsipnya tetap, dengan aturan lean ponytail (reuse, stdlib, yagni, merge, split, delete) dipakai sebagai aturan saat menulis kode. Ada juga larangan khas coding agent: tidak menghapus, melonggarkan, atau melewati test supaya hijau, tidak menelan error, dan tidak bilang "done" untuk kode yang belum dijalankan.
- **Part 2:** cek diri sendiri sebelum bilang selesai, memakai lensa ponytail (correctness, risk, scale, test, speed, lean) dan format `shortcut: ... Limit: ... Revisit when: ...`.
- **Part 3:** baseline keamanan agnostik stack, dalam bentuk aturan menulis kode.
- **Part 4 (Go):** versi level kode dengan snippet siap pakai: `http.Server` dengan timeout, `MaxBytesReader`, query terparameter, `os.OpenRoot`, `subtle.ConstantTimeCompare`, `errgroup.SetLimit`, dan `http.Client` dengan timeout. Ada juga catatan Go yang lebih ramping (stdlib dulu, interface hanya jika ada implementasi kedua), daftar tooling sebelum bilang "done" (`go vet`, `-race`, `staticcheck`, `gosec`, `govulncheck`), dan tabel pitfall.
- **Part 5:** audit mode dari ponytail, dengan format temuan 4 bagian dan contoh bergaya Go.
- **Part 6:** format laporan setelah mengubah kode, ditutup dengan self-check.

Dua hal yang perlu kamu cek:
1. Saya menambahkan aturan bahwa kalau ada desain dari mode system-designer, kriteria sukses di desain itu menjadi definisi "done" di mode code. Kalau kode dan desain bertentangan, agent diminta bilang dulu. Hapus bagian itu kalau workflow kamu tidak memakai handoff seperti ini.
2. Beberapa contoh memakai fitur Go terbaru (`os.OpenRoot` butuh Go 1.24+, routing method di `net/http` butuh Go 1.22+, `for` loop per-iterasi di contoh `errgroup` butuh Go 1.22+). File sudah meminta agent mengecek versi di `go.mod` dulu, tapi kalau toolchain kamu lebih lama, sesuaikan contohnya.