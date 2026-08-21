# Validasi Form Ketat, Soft-Delete + Undo, dan Audit Log Detail

## 1. Validasi form yang ketat

Semua dialog input (Kamar, Unit Barang, Tenant, Pembayaran, Pemasukan, Pengeluaran) memakai skema validasi Zod dengan aturan seragam:

- Wajib isi: nama, nomor kamar, jumlah, nominal, tanggal.
- Nomor kamar: 1-10 karakter, hanya angka/huruf/strip, tidak boleh duplikat.
- Lantai: bilangan bulat 1-20. Jumlah unit: bilangan bulat 1-9999.
- Nominal uang: >= 0, maksimum Rp 1 miliar per transaksi.
- Tanggal: format valid; tanggal beli tidak boleh di masa depan; garansi tidak boleh sebelum tanggal beli; periode akhir tidak boleh sebelum periode awal.
- Kontak/telepon: 8-16 digit. Email: format email. NIK: 16 digit.
- Teks bebas (catatan, alamat): batas panjang 500-1000 karakter, otomatis trim.
- Pesan error tampil di bawah tiap field dalam Bahasa Indonesia, tombol simpan nonaktif selama data belum valid, dan simpan ganda dicegah.

## 2. Soft-delete dan Undo

Hapus tidak lagi menghilangkan data permanen. Setiap tabel utama (kamar, unit barang kamar, fasilitas bersama, tenant, pembayaran, pemasukan, pemasukan lain, pengeluaran) mendapat penanda "dihapus" beserta waktu dan alasan.

- Menghapus data akan menyembunyikannya dari semua daftar, laporan, dan PDF.
- Muncul notifikasi "Data dihapus" dengan tombol **Urungkan** selama 10 detik; menekan tombol mengembalikan data seperti semula.
- Halaman **Kelola Data** mendapat tab **Tempat Sampah**: daftar semua data terhapus (30 hari terakhir) dengan tombol Pulihkan dan Hapus Permanen.
- Menghapus kamar akan ikut menyembunyikan unit barang di dalamnya, dan memulihkannya mengembalikan keduanya.

## 3. Log audit detail di Riwayat perubahan

Riwayat sekarang mencatat semua entitas, bukan hanya tenant.

- Tiap aksi tercatat: waktu, jenis aksi (tambah/ubah/hapus/pulihkan), entitas (kamar, barang, tenant, transaksi), nama data, dan daftar field yang berubah beserta nilai lama → nilai baru.
- Tab **Riwayat perubahan** diperluas menjadi linimasa lengkap dengan filter jenis entitas, jenis aksi, rentang tanggal, dan pencarian nama.
- Perubahan nominal dan tanggal ditampilkan berformat Rupiah/tanggal Indonesia agar mudah dibaca.
- Tombol Ekspor PDF pada riwayat mengikuti filter yang aktif.

## Catatan teknis

- Migrasi database: kolom `deleted_at` + `deleted_reason` pada tabel terkait, tabel baru `audit_log` (entity_type, entity_id, entity_label, action, changed_fields jsonb, created_at), serta trigger generik pencatat perubahan per tabel. GRANT + RLS mengikuti pola tabel publik yang sudah ada.
- Semua query pembacaan diberi filter `deleted_at is null`; trigger audit mencatat diff kolom otomatis, termasuk transisi soft-delete/restore.
- Validasi memakai Zod + react-hook-form (keduanya sudah terpasang), dengan skema bersama di `src/lib/validation.ts` agar dipakai ulang oleh semua dialog.
- Undo diimplementasikan lewat aksi toast Sonner yang memanggil fungsi restore, plus invalidasi cache React Query.
