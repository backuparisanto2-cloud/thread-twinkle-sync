# Halaman Tenant & Pembayaran

Halaman baru `/tenant` untuk mengelola data penghuni kost secara lengkap: data pribadi, kontak darurat, kendaraan, dokumen, lokasi, data kost, serta riwayat pembayaran dan riwayat status.

## Struktur data

Tabel `tenants` yang sudah ada diperluas, lalu ditambah 5 tabel anak yang terhubung ke tenant (hapus tenant = data anaknya ikut terhapus).

```text
rooms ──< tenants ──< tenant_phones          (nomor telepon, bisa banyak)
                 ├──< tenant_emergency_contacts (kontak darurat, bisa banyak)
                 ├──< tenant_vehicles         (kendaraan)
                 ├──< tenant_payments         (riwayat pembayaran + bukti)
                 └──< tenant_status_history   (riwayat perubahan status)
```

Field tambahan di `tenants`: NIK, nomor kartu pelajar/mahasiswa, alamat rumah, alamat tinggal saat ini, email, alamat sekolah/tempat kerja, link Google Maps rumah, link Google Maps sekolah/kerja, dokumen (kartu identitas dsb), persetujuan peraturan kost + tanggal setuju, `room_id` (relasi ke kamar), tanggal masuk, periode sewa, tanggal jatuh tempo.

Status tenant memakai 4 pilihan: Aktif, Tidak Aktif, Akan Checkout, Checkout. Setiap perubahan status otomatis tercatat di riwayat status (lewat trigger database).

`tenant_payments` berisi tanggal bayar, periode yang dibayar, jumlah, metode pembayaran (Transfer Bank, Cash, QRIS, Lainnya), catatan, dan file bukti pembayaran. Ini tabel terpisah dari halaman Pendapatan, sesuai pilihan.

Nomor kamar dipilih dari daftar kamar yang sudah ada di database, dengan indikator kamar yang sudah terisi penghuni aktif.

## Halaman & tampilan

**Daftar tenant** — kartu ringkas: nama, kamar, status (badge warna), jatuh tempo, dan penanda jika sudah lewat/mendekati jatuh tempo. Ada pencarian nama/kamar/telepon dan filter status.

**Detail tenant** — panel per bagian mengikuti alur: Data Pribadi → Kontak Darurat → Data Kost → Pembayaran → Dokumen → Riwayat Status. Link Google Maps dapat langsung dibuka, nomor telepon bisa langsung ditelepon/WhatsApp.

**Form tenant** — dialog bertahap per seksi (A–G) dengan tombol tambah/hapus baris untuk telepon, kontak darurat, dan kendaraan. Checkbox kesanggupan mengikuti peraturan kost wajib dicentang.

**Form pembayaran** — tanggal, periode, jumlah, metode, catatan, dan upload bukti (memakai uploader yang sudah ada: gambar/PDF dikompres ke WebP maksimum 300KB).

Menu "Tenant & Pembayaran" ditambahkan ke navigasi. Halaman Pendapatan tetap seperti sekarang, termasuk daftar penghuninya.

## Catatan teknis

- Satu migrasi SQL: `ALTER TABLE tenants` + `CREATE TABLE` untuk 5 tabel anak, lengkap dengan GRANT, RLS, policy publik (mengikuti pola tabel yang sudah ada), trigger `set_updated_at`, dan trigger pencatat riwayat status.
- Index pada semua kolom `tenant_id` dan pada `tenants.room_id`.
- Modul data baru `src/lib/tenants.ts` (query + mutation via browser Supabase client, pola sama dengan `src/lib/income.ts`).
- Komponen baru: `TenantDetailDialog`, `TenantFullFormDialog`, `TenantPaymentDialog`; `TenantFormDialog` lama tetap dipakai halaman Pendapatan.
- Route baru `src/routes/tenant.tsx` dengan `head()` meta sendiri; upload memakai `ProofUploader`/`uploadAttachment` yang ada.
- Validasi input dengan zod (NIK 16 digit, email, format link Maps, jumlah pembayaran > 0).
