# GoTTH Skills Dan Rules

3 File cukup untuk mulai. Tapi ada tiga hal yang sebaiknya Anda lakukan dulu:

1. **Isi tabel Project overrides** di `gotth-rules.md` (module path, versi Tailwind, tipe ID, router, CSRF, dan seterusnya). Ini yang paling berpengaruh pada kualitas hasil, karena tanpanya agen akan menebak.
2. **Pasang ketiga file berdampingan** (`gotth-stack/` lengkap dengan `references/` dan `gotth-code-reviewer/`), supaya rujukan antar-skill berfungsi.
3. **Uji dengan 2-3 tugas nyata** di repo Anda, misalnya tambah fitur hapus baris, form dengan validasi, dan review satu PR kecil. Skill ini belum pernah dijalankan, jadi pasti ada bagian yang perlu disesuaikan. Perhatikan apakah skill terpicu, dan apakah agen membaca file aturan saat seharusnya.

Setelah uji pertama, perbaiki hal yang meleset, misalnya deskripsi yang kurang memicu atau aturan yang terlalu ketat untuk repo Anda. Tidak perlu menyempurnakan semuanya sebelum mulai.

---

## `gotth-stack/SKILL.md`

SKILL.md sudah dibuat, tapi saya belum mengujinya dengan prompt nyata. Isinya saya tulis dalam bahasa Inggris, karena agen AI biasanya lebih konsisten dengan instruksi berbahasa Inggris dan spesifikasi aslinya juga berbahasa Inggris.


- **Frontmatter `description` yang "pushy"**. Skill baru terpakai kalau deskripsinya memicu. Saya masukkan banyak kata kunci seperti `templ`, `hx-*`, handler, form, dan modal, termasuk permintaan yang tidak menyebut nama stack.
- **Alasan di balik tiap aturan.** Konsep intinya: server adalah satu-satunya sumber kebenaran, jadi state di sisi klien yang mencerminkan data server akan menyimpang.
- **Jebakan HTMX yang sering terlewat:**
  - Respons 4xx/5xx tidak di-swap secara default, jadi error validasi 422 hilang tanpa `htmx:beforeSwap`.
  - `302` pada request HTMX harus diganti `HX-Redirect`.
  - `204` tidak men-swap, jadi hapus baris pakai `200` dengan body kosong.
  - Navigasi `hx-boost` butuh halaman penuh, sedangkan request HTMX biasa cukup fragmen.
- **Perbaikan bug di contoh asli:**
  - Import `"://github.com"` rusak, diganti placeholder module path.
  - Penggabungan string untuk ID (`"item-" + item.ID`) diganti `fmt.Sprintf`.
  - `x-cloak` butuh CSS di `input.css` supaya berfungsi.
  - Kelas Tailwind dinamis (`"bg-" + color`) tidak akan ter-generate.
- **Bagian yang sebelumnya kosong:** keamanan (CSRF, XSS, otorisasi), pengujian handler dan komponen, daftar anti-pattern, dan checklist sebelum menyerahkan kode.
- **Perintah dev** (`air`, `templ generate --watch`, Tailwind) tetap saya pertahankan. Saya tambahkan catatan untuk cek versi Tailwind (v3 atau v4) dan pakai perintah dari `Makefile` repo jika ada.

Cara pakai: taruh di `.kilo/skills-code/gotth-stack/SKILL.md`. Kalau repo sudah punya struktur folder sendiri, sesuaikan bagian "Project layout".

---

## `gotth-code-reviewer/SKILL.md` 

SKILL.md sudah jadi, dan saya belum mengujinya dengan kode nyata. Skill ini melengkapi `gotth-stack`: skill pertama menulis kode, skill ini memeriksanya dengan aturan yang sama.

Isinya:

- **Deskripsi pemicu yang luas.** Skill aktif saat ada permintaan review, audit, atau PR, dan juga saat Anda hanya menempel kode lalu bertanya "ini benar nggak?" atau "kenapa swap-nya tidak jalan?".
- **Prinsip review.** Setiap temuan harus punya bukti (file dan baris) dan dampak yang jelas. Urutan ditentukan oleh tingkat keparahan, dan untuk diff hanya baris yang berubah yang direview.
- **Proses 6 langkah.** Reviewer memetakan tiap interaksi sebagai trigger, request, handler, fragmen, lalu target dan swap, karena bug GOTTH paling sering ada di antara layer. Ia juga menjalankan `build`/`vet`/`test` sebelum menyatakan sesuatu gagal.
- **Perintah `grep` otomatis** untuk temuan murah dan berkeyakinan tinggi, seperti `templ.Raw`, `fetch(` di Alpine, `hx-get` untuk mutasi, kelas Tailwind dinamis, dan `http.Redirect` pada request HTMX.
- **Checklist per layer.** Mencakup handler Go, templ, atribut HTMX (dalam tabel), Alpine, Tailwind, keamanan (XSS, CSRF, IDOR), dan tes.
- **Skala keparahan** Blocker, Major, Minor, dan Nit, dengan contoh dan aturan kalibrasi untuk menghindari eskalasi berlebihan.
- **Format laporan baku** dengan verdict (Approve sampai Block) dan aturan penentuannya, plus satu contoh kasus lengkap.
- **Daftar false positive**, misalnya `templ.Raw` pada string konstan atau `hx-target` yang diwarisi pada form yang men-swap dirinya sendiri, supaya review tidak berisik.
- **Mode debugging.** Kalau pertanyaannya "kenapa ini tidak jalan?", reviewer langsung menelusuri penyebab paling mungkin dan memberi perbaikan, tanpa laporan penuh.

Struktur folder yang disarankan:

```
.claude/skills/
├── gotth-stack/SKILL.md
└── gotth-code-reviewer/SKILL.md
```

Tidak ada duplikasi aturan secara penuh. Reviewer hanya merangkum aturan di bagian 3 dan menunjuk ke `gotth-stack` sebagai sumber utama, jadi kalau aturan berubah Anda cukup memperbaruinya di satu tempat.

Mau saya buatkan satu lagi, misalnya `gotth-scaffolder` untuk men-generate CRUD lengkap (handler, komponen, route, dan tes) dengan satu perintah?

---

## `gotth-rules.md` 

Rules sudah dibuat dan kedua `SKILL.md` sudah dirapikan agar merujuk ke sana. Isinya belum saya uji dengan kode nyata, hanya saya cek bahwa semua teks yang diganti ditemukan dan perubahannya masuk.

Strukturnya sekarang:

```
.claude/skills/
├── gotth-stack/
│   ├── SKILL.md
│   └── references/gotth-rules.md   ← sumber kebenaran bersama
└── gotth-code-reviewer/
    └── SKILL.md
```

**Isi `gotth-rules.md`:**
- **Precedence.** Urutan prioritas jika instruksi bertabrakan: permintaan user, lalu konvensi repo, lalu skill, lalu default agen. Aturan keamanan (`SEC-*`) dikecualikan: agen harus menjelaskan risikonya dan minta konfirmasi dulu.
- **Project overrides.** Tabel yang Anda isi per repo (module path, versi Tailwind, tipe ID, router, CSRF, dan lainnya) supaya agen tidak menebak. Saat ini tabel itu masih kosong, jadi perlu Anda isi.
- **Guardrails.** Daftar "berhenti dan tanya dulu", daftar "jangan pernah", dan daftar "selalu lakukan".
- **Ask vs assume.** Tabel kapan agen bertanya dan kapan berasumsi.
- **Katalog aturan.** 7 kelompok aturan: ARCH, TEMPL, HTMX, ALP, TW, SEC, GO. Tiap aturan punya ID, kolom Do dan Don't, serta severity default.
- **Catatan deviasi.** Format satu baris untuk menandai penyimpangan yang disengaja.

**Perubahan di `gotth-stack`:**
- Ada petunjuk kapan harus membaca file aturan: di repo baru, sebelum menyentuh hal yang ada di guardrails, atau saat ragu antara bertanya dan lanjut.
- Tabel anti-pattern dipindah ke file aturan. Di SKILL.md tinggal ringkasan enam kesalahan paling sering dengan ID aturannya.
- Checklist akhir bertambah satu butir soal guardrails.

**Perubahan di `gotth-code-reviewer`:**
- Bagian 3 tidak lagi menyalin aturan. Reviewer diminta mengutip ID aturan di setiap temuan dan memulai dari severity default.
- Format temuan sekarang memuat baris `Rule:`.
- Penyimpangan yang terdokumentasi tidak dianggap temuan, kecuali menyangkut keamanan. Penyimpangan tanpa catatan tetap dilaporkan.

Perhatikan satu hal: reviewer merujuk ke `gotth-stack/references/gotth-rules.md` dengan path relatif antar-skill. Jadi kedua folder harus terpasang berdampingan, dan kalau Anda memasang hanya satu skill, file aturannya harus ikut disalin.

---

## Update Terbaru: Implementasi Tailwind v4 CSS-first

Saya sedang menerapkan Tailwind v4 CSS-first ke semua skill. Berikut perubahan per file:

### **`gotth-stack/SKILL.md`**
- Bagian 8 ditulis ulang dengan template `input.css` baku, tabel direktif `@theme`/`@utility`/`@custom-variant`/`@source`, tabel nama utilitas v3 ke v4, dan daftar default yang berubah.
- Perintah dev kini memakai standalone binary atau `@tailwindcss/cli` (`--watch`, `--minify`). Tidak ada lagi `tailwind.config.js` atau PostCSS.

### **`gotth-rules.md`**
- Tabel Tailwind diganti menjadi `TW-1` sampai `TW-10`.
- Aturan baru: larangan config file dan direktif v3 (`TW-4`), nama utilitas v4 (`TW-7`), warna border dan ring harus eksplisit (`TW-8`), tidak ada Sass/Less (`TW-9`), dan hover hanya sebagai pelengkap (`TW-10`).
- Project overrides kini mencatat versi v4, CLI, file CSS utama, dan batas browser.
- Membuat `tailwind.config.js` masuk daftar guardrail "tanya dulu".

### **`gotth-code-reviewer`**
- Bagian 5.5 ditulis ulang untuk v4.
- Ada empat pemeriksaan `grep` baru: file config yang tidak seharusnya ada, sintaks v3, `.templ` yang ter-ignore git, dan border atau ring tanpa warna.

### **`gotth-html-converter`**
- `css-conversion.md` ditulis ulang total untuk v4 (bridge dengan `layer(components)`, token `@theme`, breakpoint, Preflight, dan `@source not`).
- `SKILL.md` dan profil stack disesuaikan.

### **Temuan dari dokumentasi yang mengubah rencana:**
- CSS lama tanpa layer mengalahkan semua utilitas di v4, karena v4 memakai cascade layer native. Karena itu CSS lama harus diimpor dengan `layer(components)`.
- Tailwind v4 tidak memindai file yang masuk `.gitignore`. Jika folder `.templ` ter-ignore, kelasnya tidak akan dibuat.
- Folder desain lama ikut terpindai. Class bawaannya (`flex`, `container`) bisa menghasilkan utilitas liar, jadi dikecualikan dengan `@source not "../../legacy"`.
- v4 hanya mendukung Safari 16.4+, Chrome 111+, dan Firefox 128+. Jika desain Anda harus mendukung browser lebih lama, v4 tidak bisa dipakai dan harus tetap di v3.4. Agen kini diminta mengecek ini di tahap intake.
- v4 tidak dirancang untuk dipakai dengan Sass, Less, atau Stylus. Konversi dimulai dari CSS hasil kompilasi.
- Palet bawaan v4 memakai OKLCH, jadi warna hex lama tidak identik dengan warna bawaan yang mirip. Warna desain harus didefinisikan sebagai token dengan nilai persis.

**Keputusan yang diperlukan:** Apakah desain lama wajib mendukung browser di bawah batas v4 (Safari 16.4+, Chrome 111+, Firefox 128+)? Kalau ya, perlu kembali ke v3.4 dan saya sesuaikan lagi semuanya.

---

## Saran Penempatan di Workspace - Struktur yang Direkomendasikan

Saya telah mengembalikan perubahan yang saya buat ke workspace. Seperti yang Anda minta, saya hanya akan memberikan saran tentang cara menempatkan skill GOTTH sesuai dengan konvensi workspace tanpa membuat perubahan apa pun.

Berdasarkan struktur workspace yang ada, berikut adalah rekomendasi untuk menempatkan skill GOTTH:

### 1. Lokasi Skill Utama
Letakkan implementasi skill sebenarnya di:
```
/Users/pbkris/MyDev/go-dual-mode-system/.agents/skills/
```

Contoh struktur:
```
.agents/skills/
├── gotth-stack/
│   ├── SKILL.md
│   └── references/
│       └── gotth-rules.md
├── gotth-code-reviewer/
│   └── SKILL.md
└── gotth-html-converter/
    ├── SKILL.md
    └── references/
        ├── source-stack-profile.md
        ├── jquery-to-gotth.md
        ├── css-conversion.md
        └── visual-regression.md
```

### 2. Symbolic Links di .kilo/skills-code/
Buat symbolic link dari `.kilo/skills-code/` ke setiap skill di `.agents/skills/`:
```
.kilo/skills-code/
├── gotth-stack -> ../../.agents/skills/gotth-stack
├── gotth-code-reviewer -> ../../.agents/skills/gotth-code-reviewer
└── gotth-html-converter -> ../../.agents/skills/gotth-html-converter
```

### 3. Prinsip Penamaan dan Struktur
- Setiap skill harus memiliki file `SKILL.md` sebagai titik masuk utama
- File aturan atau referensi yang bersama-disimpan dalam subdirektori `references/`
- Gunakan nama direktori skill yang konsisten (kecil, menggunakan tanda hub untuk memisahkan kata)
- Ikuti struktur yang sama dengan skill lain yang ada di `.agents/skills/` seperti `implement`, `code-review`, `tdd`, dll

### 4. Langkah-langkah Implementasi
Jika Anda ingin menerapkan struktur ini:
1. Buat direktori di `.agents/skills/` untuk setiap skill GOTTH
2. Salin file-file dari `research/gotth/` ke lokasi yang sesuai
3. Buat symbolic link di `.kilo/skills-code/` yang mengarah ke direktori skill di `.agents/skills/`

Contoh perintah (untuk referensi saja, jalankan hanya jika Anda ingin menerapkan):
```bash
# Untuk gotth-stack
mkdir -p .agents/skills/gotth-stack/references
cp research/gotth/gotth-stack/SKILL.md .agents/skills/gotth-stack/
cp research/gotth/gotth-stack/reference/gotth-rule.md .agents/skills/gotth-stack/references/gotth-rules.md
ln -s ../../.agents/skills/gotth-stack .kilo/skills-code/gotth-stack

# Ulangi untuk gotth-code-reviewer dan gotth-html-converter dengan struktur yang sesuai
```

Pendekatan ini memastikan:
- Skill dapat ditemukan oleh sistem Agent Manager melalui `.kilo/skills-code/`
- Implementasi sejati terisolasi di `.agents/skills/` untuk mudah dibackup atau dibagikan
- Struktur konsisten dengan skill lain yang ada di workspace
- Pemeliharaan dipermudah karena setiap skill memiliki tempat yang jelas dan terorganisir

Silakan konfirmasi jika Anda ingin saya membantu dengan cara lain atau jika Anda memerlukan klarifikasi lebih lanjut tentang struktur yang direkomendasikan.

---

## Laporan Implementasi Ke Wokspace

Berhasil menerapkan rencana penempatan skill GOTTH sesuai dengan konvensi workspace. Berikut ringkasan perubahan yang telah dilakukan:

### Struktur yang Telah Dibuat

#### 1. Lokasi Skill Utama di `.agents/skills/`
```
.agents/skills/
├── gotth-stack/
│   ├── SKILL.md
│   └── references/
│       └── gotth-rules.md
├── gotth-code-reviewer/
│   └── SKILL.md
└── gotth-html-converter/
    ├── SKILL.md
    └── references/
        ├── source-stack-profile.md
        ├── jquery-to-gotth.md
        ├── css-conversion.md
        └── visual-regression.md
```

#### 2. Symbolic Links di `.kilo/skills-code/`
```
.kilo/skills-code/
├── gotth-stack -> ../../.agents/skills/gotth-stack
├── gotth-code-reviewer -> ../../.agents/skills/gotth-code-reviewer
└── gotth-html-converter -> ../../.agents/skills/gotth-html-converter
```

### Detail Implementasi

**Untuk gotth-stack:**
- Direktori dibuat: `.agents/skills/gotth-stack/` dan `.agents/skills/gotth-stack/references/`
- File disalin:
  - `research/gotth/gotth-stack/SKILL.md` → `.agents/skills/gotth-stack/SKILL.md`
  - `research/gotth/gotth-stack/reference/gotth-rule.md` → `.agents/skills/gotth-stack/references/gotth-rules.md`
- Symbolic link dibuat: `.kilo/skills-code/gotth-stack` → `../../.agents/skills/gotth-stack`

**Untuk gotth-code-reviewer:**
- Direktori dibuat: `.agents/skills/gotth-code-reviewer/`
- File disalin:
  - `research/gotth/gotth-code-reviewer/SKILL.md` → `.agents/skills/gotth-code-reviewer/SKILL.md`
- Symbolic link dibuat: `.kilo/skills-code/gotth-code-reviewer` → `../../.agents/skills/gotth-code-reviewer`

**Untuk gotth-html-converter:**
- Direktori dibuat: `.agents/skills/gotth-html-converter/` dan `.agents/skills/gotth-html-converter/references/`
- File disalin:
  - `research/gotth/gotth-html-converter/SKILL.md` → `.agents/skills/gotth-html-converter/SKILL.md`
  - Semua file dari `research/gotth/gotth-html-converter/rerefences/` → `.agents/skills/gotth-html-converter/references/`
- Symbolic link dibuat: `.kilo/skills-code/gotth-html-converter` → `../../.agents/skills/gotth-html-converter`

Semua skill GOTTH sekarang siap digunakan melalui sistem Agent Manager dan sesuai dengan konvensi workspace yang ada. Skill dapat diakses melalui symbolic link di `.kilo/skills-code/` sementara implementasi sejati terisolasi di `.agents/skills/` untuk pemeliharaan yang lebih mudah.

