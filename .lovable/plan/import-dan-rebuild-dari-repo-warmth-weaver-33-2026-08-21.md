# Import dan Rebuild dari Repo warmth-weaver-33

## Tujuan
Mengambil seluruh isi repository GitHub `backuparisanto2-cloud/warmth-weaver-33` dan membangun ulang project Lovable ini berdasarkan kode repo tersebut.

## Cara kerja
Repo bersifat publik, sehingga kita dapat mengunduh arsip ZIP-nya langsung dari GitHub tanpa perlu konektor tambahan. Karena repo asal juga adalah project Lovable berbasis TanStack Start, struktur folder-nya cocok dengan project ini.

## Langkah-langkah

1. **Unduh dan ekstrak repo**
   - Download `https://github.com/backuparisanto2-cloud/warmth-weaver-33/archive/refs/heads/main.zip` ke folder sementara.
   - Ekstrak arsip sehingga kita mendapatkan folder `warmth-weaver-33-main/`.

2. **Salin file aplikasi ke project saat ini**
   - Ganti isi folder `src/` di project ini dengan `src/` dari repo.
   - Ganti `public/` dengan `public/` dari repo.
   - Ganti `README.md`, `package.json`, `bun.lock`, `bunfig.toml`, `vite.config.ts`, `tsconfig.json`, `components.json`, `eslint.config.js`, dan konfigurasi build lain dari repo.
   - Biarkan file Lovable internal seperti `.lovable/project.json` dan `.lovable/plan/` tetap sesuai project ini agar metadata project tidak tertimpa.

3. **Penanganan environment variables**
   - Repo membawa `.env`. Jangan langsung menimpa `.env` project ini; salin nilai-nilai non-rahasia yang relevan (biasanya `VITE_*`) ke konfigurasi project ini dengan aman. Rahasia/secret hanya ditambahkan jika memang dibutuhkan fitur dan diset melalui Lovable Secret/Cloud.

4. **Instal dependensi**
   - Jalankan `bun install` agar dependency yang tercantum di `package.json` repo terpasang.

5. **Build dan verifikasi**
   - Jalankan `bun run build` untuk memastikan project berhasil dibundel.
   - Periksa preview/live preview untuk memastikan halaman utama tidak lagi menampilkan placeholder.

6. **Bersihkan artefak sementara**
   - Hapus file ZIP dan folder ekstraksi setelah semua file penting tersalin.

## Hasil akhir
Project ini akan berisi kode, komponen, route, dan styling yang sama persis dengan repo `warmth-weaver-33`, siap dijalankan dan disunting lebih lanjut di Lovable.
