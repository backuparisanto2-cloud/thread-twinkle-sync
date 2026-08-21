# Rencana: Impor Repository tender-thread-maker ke Proyek Lovable Ini

## Tujuan
Menyalin seluruh kode, konfigurasi, dan aset dari repository GitHub `backuparisanto2-cloud/tender-thread-maker` ke proyek Lovable yang sedang aktif, sehingga aplikasi hasilnya dapat dijalankan dan dikembangkan di sini.

## Keterbatasan Penting
Lovable tidak mendukung impor otomatis dari repository GitHub yang sudah ada. Karena itu, impor akan dilakukan secara manual dengan menyalin file per file dari repo sumber, sambil menjaga identitas dan keamanan proyek tujuan.

## Analisis Singkat Repo Sumber
- Template: `tanstack_start_ts_current` (sama dengan proyek ini).
- Stack: TanStack Start + React 19 + Tailwind CSS v4 + shadcn/ui.
- Backend: Lovable Cloud / Supabase (terlihat dari folder `supabase/migrations`, `src/integrations/supabase`, dan file `.env` di repo sumber).
- Fitur utama: manajemen tenant/kamar, pendapatan, pengeluaran, laporan, denah lantai, inventory, fasilitas.
- Aset: gambar denah lantai dan splash building tersimpan sebagai metadata `.asset.json`; file gambar asli kemungkinan berada di storage Lovable, bukan di GitHub.

## Strategi Impor
1. **Salin kode sumber dan konfigurasi** dari repo sumber.
2. **Pertahankan identitas proyek ini**: jangan menimpa `.lovable/project.json` milik proyek saat ini.
3. **Jangan menyalin `.env` repo sumber**: secret Supabase di dalamnya milik proyek lain. Lovable Cloud akan membuatkan secret baru setelah diaktifkan.
4. **Aktifkan Lovable Cloud** agar Supabase, auth, dan storage tersedia di proyek ini.
5. **Terapkan ulang migrasi database** dari `supabase/migrations/` ke proyek Supabase yang baru.
6. **Tangani aset gambar**: unduh file gambar dari URL yang tercantum di `.asset.json` (jika masih publik) atau siapkan ulang jika rusak.
7. **Verifikasi build** setelah semua file tersalin.

## Langkah-Langkah Detail

### 1. Persiapan dan Backup
- Tinjau daftar file yang akan ditimpa di proyek ini.
- Pastikan tidak ada perubahan berharga di proyek saat ini yang belum tersimpan (proyek ini masih berupa template placeholder, jadi aman untuk ditimpa).

### 2. Salin File dari Repo GitHub
Salin file dan folder berikut dari `main` branch repo sumber ke proyek ini:
- `src/` (seluruh folder: components, hooks, integrations, lib, routes, styles, router, dll.)
- `public/` (ikon, favicon, manifest, robots.txt)
- `supabase/` (config.toml dan seluruh migrations)
- `sql/` (jika ada query tambahan)
- `package.json`, `bun.lock`, `bunfig.toml`
- `components.json`, `tsconfig.json`, `vite.config.ts`, `eslint.config.js`
- `.prettierrc`, `.prettierignore`, `.gitignore`
- `README.md`, `AGENTS.md`

### 3. Lindungi Identitas dan Secret Proyek Ini
- **Tetap gunakan** `.lovable/project.json` yang sudah ada di proyek ini; jangan menggantinya dengan milik repo sumber.
- **Hapus/tidak menyalin** file `.env` dari repo sumber.
- Setelah Lovable Cloud aktif, proyek ini akan mendapatkan `.env` baru secara otomatis.

### 4. Aktifkan Lovable Cloud
- Aktifkan Lovable Cloud di proyek ini supaya Supabase, autentikasi, dan storage tersedia.
- Ini akan membuatkan project Supabase baru dan secret `.env` yang sesuai dengan proyek ini.

### 5. Terapkan Migrasi Database
- Jalankan file SQL di `supabase/migrations/` secara berurutan pada project Supabase yang baru dibuat oleh Lovable Cloud.
- Pastikan tabel, fungsi, RLS policy, dan seed data (jika ada) tercipta dengan benar.

### 6. Penanganan Aset Gambar
- Periksa setiap file `.asset.json` di `src/assets/` untuk menemukan URL asli gambar.
- Jika URL masih dapat diakses, unduh gambar dan unggah ulang ke storage proyek ini melalui Lovable.
- Jika URL tidak dapat diakses, siapkan gambar pengganti atau minta user menyediakan file aslinya.

### 7. Instalasi Dependensi
- Jalankan `bun install` untuk menginstal dependensi dari `package.json` dan `bun.lock` repo sumber.
- Perbedaan versi akan ditangani oleh bun secara otomatis.

### 8. Verifikasi Build
- Jalankan `bun run build:dev` untuk memastikan tidak ada error kompilasi.
- Periksa preview untuk memastikan routing dan tampilan utama berjalan.
- Perbaiki error yang muncul secara bertahap.

## Risiko dan Catatan
- **Aset gambar**: file `.asset.json` mungkin merujuk ke URL lama yang sudah tidak aktif; ini bisa menyebabkan gambar tidak tampil.
- **Data database**: data lama tidak ikut tersalin; hanya schema dan seed dari migrations yang akan ada.
- **Konflik file**: beberapa file di proyek ini (misalnya `src/routes/index.tsx`) akan tertimpa; ini diinginkan karena proyek ini masih kosong.
- **Lovable Cloud wajib**: tanpa mengaktifkannya, aplikasi yang mengandalkan Supabase tidak akan berfungsi.

## Hasil Akhir
Proyek ini akan berisi kode aplikasi `tender-thread-maker`, berjalan dengan database Supabase milik proyek ini sendiri, dan siap untuk dikembangkan lebih lanjut di Lovable.
