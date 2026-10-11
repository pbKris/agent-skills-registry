# GoTTH HTML Converter

## Tahap Kerja

Usul saya: konversi per halaman dan per komponen dengan tolok ukur visual yang diukur otomatis, bukan satu kali konversi besar. Kerapian visual datang dari pengukuran, bukan dari kehati-hatian saja.

**1. Audit dan pemetaan dulu, sebelum menulis kode**
- Daftar semua halaman, bagian berulang (navbar, kartu, tabel, modal, form), dan semua JS.
- Klasifikasikan setiap potongan JS ke salah satu dari empat:
  - menjadi Alpine (dropdown, tab, modal),
  - menjadi HTMX (apa pun yang mengambil atau mengirim data),
  - tetap sebagai library pihak ketiga yang di-vendor (chart, carousel, date picker),
  - dibuang (animasi yang bisa diganti CSS).
- Tentukan batas fragmen: bagian mana yang akan di-swap dan butuh `id` stabil.

**2. Ekstrak design token ke Tailwind**
Warna, font, spacing, radius, shadow, dan breakpoint dari CSS asli dipindah ke konfigurasi Tailwind (`@theme` di v4, atau `tailwind.config.js` di v3). Ini kunci agar tampilan tetap identik, dan cara paling murah untuk menghindelas kelas arbitrer seperti `w-[347px]`. Catatan penting untuk v4: CSS lama harus diimpor dengan `layer(components)` untuk tidak kalah dengan utilitas, dan Tailwind v4 tidak memindai file yang masuk `.gitignore` (jika folder `.templ` ter-ignore, kelasnya tidak akan dibuat).

**3. Strategi CSS: jangan konversi seluruhnya sekaligus**
Ada konflik dengan aturan `TW-1` (utilitas saja). Saya sarankan bertahap:
- Fase A: pertahankan CSS asli yang sulit diterjemahkan (animasi kompleks, selector rumit) di `input.css` pada `@layer components`, dengan catatan sebagai pengecualian di tabel Project overrides.
- Fase B: pindahkan ke utilitas per komponen setelah halaman itu lolos uji visual.
- Waspadai Preflight Tailwind. Reset-nya mengubah margin, heading, dan list sehingga tampilan bisa bergeser, jadi periksa itu dulu kalau desain asli bergantung pada default browser.
- Catatan v4 penting: tidak mendukung Sass/Less/Stylus (konversi dari CSS hasil kompilasi saja), hanya supports Safari 16.4+, Chrome 111+, Firefox 128+ (cek di tahap intake), dan palet bawaan memakai OKLCH (warna hex lama tidak identik dengan warna bawaan yang mirip).

**4. Konversi per komponen, urut dari yang paling kecil**
Pola, ikon, tombol, lalu kartu, tabel, form, layout, dan terakhir halaman. Tiap komponen menjadi `.templ` dengan struct bertipe, dan dibuatkan halaman katalog komponen internal (`/dev/components`) untuk dilihat berdampingan dengan desain asli.

**5. Uji regresi visual otomatis (bagian terpenting)**
- Playwright mengambil screenshot halaman asli dan hasil GOTTH pada 3-4 lebar layar (mobile, tablet, desktop, wide).
- Bandingkan dengan `pixelmatch` atau `toHaveScreenshot`, dengan ambang selisih yang disepakati.
- Matikan animasi dan tunggu font dimuat supaya hasilnya stabil.
- Setiap komponen baru dianggap selesai hanya jika lolos perbandingan.

**6. Jebakan yang sering membuat visual berantakan**
- Library JS pihak ketiga tidak berinisialisasi ulang setelah swap. Pakai `htmx.onLoad` atau event `htmx:load`.
- State Alpine hilang saat elemennya ikut ter-swap.
- Kelas dinamis hilang dari hasil build Tailwind (`TW-2`).
- Font, ikon, dan gambar tidak ikut dipindah, atau berbeda path.
- Perbedaan perilaku antara halaman penuh dan fragmen, yang menyebabkan kedipan atau layout bergeser.
- Tidak ada indikator loading, sehingga terasa tidak mulus. Aturan `HTMX-6` mengatasinya.

**7. Urutan kerja**
1. Satu halaman pilot yang representatif (misalnya dashboard) sampai lolos uji visual.
2. Dari pilot itu, tetapkan pola dan perbaiki skill atau aturan.
3. Lanjutkan halaman lain dengan pola yang sudah terbukti.

Saya juga menyarankan skill ketiga, `gotth-html-converter`, yang memuat alur di atas: audit, klasifikasi JS, daftar token, pola konversi komponen, dan prosedur uji visual dengan Playwright. Agen Anda jadi mengikuti prosedur yang sama di setiap halaman, dan hasilnya konsisten.

Mau saya buatkan skill itu? Kalau ya, sebutkan versi Tailwind yang dipakai desain asli Anda (atau CSS biasa, Bootstrap, dan sebagainya), karena itu menentukan strategi konversi CSS-nya.

---

## `gotth-html-converter`

Bisa. Saya buat sekarang dengan asumsi HTML/CSS polos dan jQuery. Semua hal yang bergantung pada stack saya taruh di file `references/` terpisah dan diberi status "ASSUMED", jadi nanti Anda cukup memperbarui file itu.Bisa. Skill ketiga, `gotth-html-converter`, sudah dibuat dengan asumsi HTML/CSS polos dan jQuery. Belum saya uji pada desain nyata, dan template Playwright-nya belum pernah dijalankan.

Struktur skill ini:

```
gotth-html-converter/
├── SKILL.md                          ← alur kerja 7 fase
└── references/
    ├── source-stack-profile.md       ← file yang Anda perbarui nanti
    ├── jquery-to-gotth.md            ← pemetaan jQuery → Alpine/HTMX/CSS
    ├── css-conversion.md             ← strategi CSS → Tailwind
    └── visual-regression.md          ← verifikasi visual dengan Playwright
```

**Soal stack yang belum diketahui:**
- Semua hal yang bergantung pada stack ada di `source-stack-profile.md`, berstatus `ASSUMED`. Setelah info masuk, Anda isi tabelnya, ubah status ke `CONFIRMED`, lalu tambahkan bagian varian (Bootstrap, Sass, plugin tertentu) sesuai tabel di bagian 3 file itu.
- Agen tidak diminta mempercayai asumsi. Di tahap intake ia menjalankan `grep` untuk mendeteksi framework dan library yang sebenarnya, lalu melapor dan menyesuaikan rencana jika hasilnya berbeda. Jadi kalau ternyata desainnya memakai Bootstrap, itu terdeteksi sejak awal.
- Bagian Bootstrap di `css-conversion.md` sudah saya sediakan sebagai draf sementara, termasuk pemetaan grid, spacing, dan breakpoint-nya.

**Isi alur kerjanya:**
- Fase 1-7: inventaris, token dan style dasar, komponen (dari yang terkecil), perilaku JS, halaman dan handler dengan data fixture, verifikasi, lalu pembersihan. Tiap fase punya kriteria selesai.
- Struktur DOM dipertahankan di konversi pertama, karena CSS asli ditulis untuk struktur itu. Perapian dilakukan setelah halaman lolos verifikasi.
- CSS memakai strategi "bridge": CSS lama sementara disimpan di `@layer components`, lalu dimigrasi per komponen. Ini menghindari perubahan tampilan yang tidak terukur. Untuk v4, ini sangat penting karena CSS tanpa layer akan kalah terhadap utilitas Tailwind.
- Perbedaan media query desktop-first (`max-width`) vs Tailwind mobile-first dibahas khusus, karena ini penyebab umum layout rusak.
- jQuery dipetakan idiom demi idiom, dengan tiga contoh lengkap dan keputusan per plugin (ganti, jadikan HTMX, atau pertahankan sebagai "vendor island" yang diinisialisasi lewat `htmx.onLoad`).
- Kerapian visual diukur dengan screenshot legacy vs hasil konversi pada beberapa lebar layar, dengan data fixture agar tidak ada selisih palsu.

Dua hal yang perlu Anda sadari:
- Playwright dan plugin jQuery yang dipertahankan dihitung sebagai guardrail event, jadi agen akan meminta konfirmasi dan mencatatnya sebagai pengecualian di tabel Project overrides.
- Sebelum dipakai di halaman pertama, jalankan template Playwright sekali di repo Anda dan sesuaikan path serta ambangnya.

Saran urutan kerja: pilih satu halaman pilot yang representatif (ada navbar, konten, dan satu form atau tabel), selesaikan sampai fase 6, lalu perbaiki skill berdasarkan masalah yang muncul sebelum lanjut ke halaman lain.