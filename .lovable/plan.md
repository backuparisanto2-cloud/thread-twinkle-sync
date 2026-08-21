# Splash Eksklusif, CRUD Kamar, Tenant Lengkap, dan Ekspor PDF

## 1. Splash screen elegan dengan foto gedung

Foto gedung yang Anda unggah dipakai sebagai latar splash screen (menggantikan placeholder buatan sebelumnya):

- Foto diunggah ke penyimpanan aset dan dipakai dalam 3 ukuran responsif.
- Tampilan dibuat premium: foto full-bleed, gradasi gelap lembut di bagian bawah, logo/nama "Lavin Kost Purwokerto" dengan tipografi serif tipis + garis emas tipis, animasi fade/zoom halus, lalu transisi ke beranda.

## 2. Halaman CRUD kamar dan unit barang

Saat ini barang per kamar dan fasilitas bersama sudah bisa ditambah/ubah/hapus, tapi **kamar itu sendiri belum bisa dikelola**.

- Halaman baru `Kelola Data` (`/kelola`) dengan dua tab: **Kamar** dan **Unit Barang**.
- Tab Kamar: tabel semua kamar (nomor, lantai, jumlah barang, catatan) + tambah, ubah, hapus. Hapus kamar meminta konfirmasi dan menjelaskan bahwa barang di dalamnya ikut terhapus.
- Tab Unit Barang: satu daftar gabungan barang kamar + fasilitas bersama, bisa dicari/difilter per lantai, kamar, dan kondisi; ubah/hapus langsung dari baris, serta tambah barang ke kamar mana pun tanpa harus membuka halaman kamar.
- Tombol menuju halaman ini ditambahkan ke navigasi utama.

## 3. Manajemen tenant + riwayat perubahan

Halaman tenant sudah ada di kode, tetapi tabel pendukungnya belum ada di database sehingga halaman ini belum berfungsi. Yang akan dikerjakan:

- Melengkapi tabel `tenants` (NIK, kartu pelajar, alamat rumah/domisili, email, alamat sekolah/kerja, tautan Maps, dokumen, persetujuan aturan, kamar, tanggal masuk, periode sewa, jatuh tempo).
- Menambah tabel: nomor telepon, kontak darurat, kendaraan, pembayaran tenant, dan **riwayat perubahan** tenant.
- Riwayat dicatat otomatis oleh database setiap kali status, kamar, atau tanggal jatuh tempo berubah, plus saat tenant dibuat/dihapus — jadi terlihat siapa menempati kamar mana dan sejak kapan.
- Di halaman tenant ditambah tab **Riwayat**: linimasa perubahan per tenant, serta tampilan "Kamar → penghuni saat ini" agar mudah melihat hunian tiap kamar.

## 4. Ekspor PDF ringkasan

Menggunakan mesin PDF yang sudah ada di proyek (jsPDF + autotable), ditambahkan tombol **Ekspor PDF** di:

- Halaman Kamar → ringkasan kamar per lantai + jumlah/kondisi barang.
- Halaman Fasilitas → daftar fasilitas bersama beserta kondisi dan nilai.
- Halaman Pemasukan & Pengeluaran → transaksi terfilter + total dan rekap per kategori.
- Halaman Tenant → daftar penghuni, kamar, jatuh tempo, total dibayar.

Semua PDF memakai kop laporan seragam (judul, periode, tanggal cetak, ringkasan angka) agar rapi saat dibagikan.

## Catatan teknis

- Migrasi database: `ALTER TABLE tenants` + tabel `tenant_phones`, `tenant_emergency_contacts`, `tenant_vehicles`, `tenant_payments`, `tenant_status_history`, lengkap dengan GRANT dan RLS mengikuti pola tabel yang sudah ada (akses publik, sama seperti tabel lain di proyek ini).
- Trigger `AFTER INSERT/UPDATE/DELETE` pada `tenants` menulis ke `tenant_status_history`.
- Helper PDF baru di `src/lib/pdf-report.ts` (kop + tabel generik), dipakai oleh semua tombol ekspor.
- Foto splash diunggah lewat Lovable Assets; `src/components/SplashScreen.tsx` disesuaikan.
