# ELECTROVICE — Breakdown Workflow Baru (v2.0)

> Dokumen ini adalah breakdown detail dari diagram "Workflow Nanti" yang digambar tangan,
> dikombinasikan dengan analisis Figma Version 3.0.
> Last updated: 2026-04-11

---

## Gambaran Umum

Ada **3 aktor** di workflow baru:
- 🟡 **Customer** — mencari dan memesan teknisi
- 🔵 **Teknisi** — menerima, mendiagnosa, dan menyelesaikan pekerjaan
- 🔴 **Admin** — memverifikasi akun teknisi baru (diimplementasi belakangan)

---

## 🟡 CUSTOMER FLOW

### BAGIAN 1 — Cari & Pilih Teknisi

```
[Buka Aplikasi]
      │
      ▼
[Role Selection]
      │  • Pilih "I am a Customer"
      │  • Sudah punya akun? → Login
      │  • Belum? → Register
      ▼
[Home Page]
      │  • Tampil peta dengan teknisi terdekat
      │  • Bisa search atau pilih kategori
      ▼
[Cari Teknisi]
      │  • Filter: jarak, rating, harga, open now
      │  • List teknisi dengan jarak & harga mulai dari
      ▼
[Lihat Detail Teknisi]
      │  • 3 tab: Service | Review | About
      │  • Stats: jobs done, completion rate, rating
      │  • Daftar layanan + estimasi harga
      │  • Ulasan customer lain
      │  • Alamat workshop
      │
      ├──[Tombol CHAT]──► Bisa chat dulu sebelum order (tanya-tanya)
      │
      └──[Tombol BOOK NOW]──► lanjut ke bawah
```

---

### BAGIAN 2 — Buat Order

```
[Pilih Service & Atur Jadwal]
      │  • Pilih service method:
      │    - Pick-up   → teknisi datang ke lokasi customer
      │    - Drop-in   → customer bawa ke workshop teknisi
      │  • Lihat estimasi kemungkinan harga (dari profil teknisi)
      │  • Atur jadwal: pilih tanggal + slot waktu
      │  • Isi deskripsi keluhan
      │  • Isi/pilih alamat (bisa dari Saved Addresses)
      ▼
[Konfirmasi Order]
      │  • Ringkasan: teknisi, jadwal, service method, estimasi harga
      │  • ⚠️ BELUM ADA PEMBAYARAN DI SINI
      │  • Tap "Konfirmasi" → order masuk ke Firestore
      │  • Status: "pending"
      ▼
[Order Tracking — Menunggu Konfirmasi]
      │  • Status: Menunggu konfirmasi teknisi
      │  • Teknisi belum accept → kode verifikasi disembunyikan "------"
      │
      ├── Teknisi TOLAK ──► Order dibatalkan, notifikasi ke customer
      │
      └── Teknisi TERIMA ──► lanjut ke bawah
```

---

### BAGIAN 3 — Teknisi On The Way

```
[Dapat Kode Verifikasi 6 Digit]
      │  • Kode muncul setelah teknisi accept
      │  • Ada timer expiry kode
      │  • Customer simpan/tunjukkan kode ini ke teknisi nanti
      ▼
[Order Track: On The Way]
      │  • Status: Teknisi sedang menuju lokasi
      │  • Customer bisa track posisi teknisi (fitur GPS tracking)
      │  • Bisa chat dengan teknisi
      ▼
[Menunggu Teknisi — Proses Diagnosa]
      │  • Teknisi tiba → input kode → verifikasi sukses
      │  • Status: "diagnosing"
      │  • Customer menunggu hasil diagnosa dari teknisi
      ▼
[Terima Penawaran Harga dari Teknisi]
      │  • Teknisi kirim rincian biaya:
      │    - Ringkasan hasil diagnosa
      │    - Service fee
      │    - Daftar parts + harga per item
      │    - Total final
      │    - Catatan dari teknisi
      │
      ├── Customer TOLAK ──────────────────────────────────────┐
      │                                                         │
      └── Customer SETUJU ──► Status: "on_progress"            │
                                                               ▼
                                              [Bayar Diagnosis Fee Saja]
                                                    │  • Bayar biaya diagnosa
                                                    │  • Tunai / Non-tunai
                                                    ▼
                                              [Selesai — Kembali ke Home]
```

---

### BAGIAN 4 — Perbaikan & Selesai

```
[Menunggu Perbaikan]
      │  • Status: "on_progress"
      │  • Teknisi sedang memperbaiki
      │  • Info: repair di tempat atau dibawa pulang
      │  • Bisa chat dengan teknisi
      ▼
[Teknisi Selesai — Update Harga Final]
      │  • Teknisi input detail pekerjaan + harga final
      │  • Status: "done"
      │  • Customer menerima notifikasi
      ▼
[Melakukan Pembayaran]
      │  • Tampil total final dari teknisi
      │  • Pilih metode:
      │    - Tunai     → bayar langsung ke teknisi
      │    - Non-tunai → bayar via app (transfer/e-wallet)
      │
      ▼ [diamond: hasil pembayaran]
      │
      ├── GAGAL ──► Coba lagi / ganti metode pembayaran
      │
      └── BERHASIL ──► lanjut ke bawah
            │
            ▼
      [Receipt / Invoice]
            │  • Invoice # dengan rincian biaya
            │  • Metode pembayaran
            │  • Nama teknisi, tanggal, layanan
            │  • Bisa download PDF
            ▼
      [Beri Ulasan & Rating]
            │  • Bintang 1–5
            │  • Teks ulasan
            │  • Quick tags: Tepat waktu, Profesional, dll
            ▼
      [FINISH — Kembali ke Home] ⭕
```

---

## 🔵 TEKNISI FLOW

### BAGIAN 1 — Registrasi & Onboarding

```
[Daftar Akun]
      │
      ▼
[Isi Form & Biodata — 6 Steps]
      │
      │  Step 1 — Personal Info
      │    • Nama lengkap, nomor HP, gender, bio
      │
      │  Step 2 — Identity (KTP)
      │    • Upload foto KTP
      │    • Upload selfie dengan KTP
      │    • Input NIK
      │
      │  Step 3 — Lokasi & Jadwal
      │    • Kota/area
      │    • Nama & alamat workshop (opsional)
      │    • Service radius: 1-3km | 5km | 10km
      │    • Hari buka (pilih hari)
      │    • Jam operasional
      │
      │  Step 4 — Keahlian
      │    • Device categories (multi-select):
      │      Laptop | Smartphone | Appliance |
      │      AC & Cooling | TV & Display | Vehicles | Other
      │    • Service method: Pick-up | Drop-in
      │    • Pengalaman: <1thn | 1-2thn | 3-5thn | 5thn+
      │    • Upload sertifikasi (opsional)
      │
      │  Step 5 — Pricing
      │    • Set diagnosis fee (Rp)
      │      → ini yang dibayar customer jika tolak penawaran
      │
      │  Step 6 — Review & Submit
      │    • Cek semua data
      │    • Submit registrasi
      │
      ▼
[Kirim ke Admin untuk Verifikasi] ──────────────────────────┐
      │                                                       │
      │  (Sementara: auto-verified langsung)                 🔴 ADMIN
      ▼                                                       │ Verif / Decline
[Masuk ke Aplikasi Teknisi]  ◄──────────────────────────────┘
```

---

### BAGIAN 2 — Terima & Proses Order

```
[Technician Home]
      │  • Toggle online/offline
      │  • Stream order masuk (status: pending)
      ▼
[Lihat Incoming Request]
      │  • Notifikasi order baru masuk
      ▼
[Lihat Detail Order]
      │  • Info customer: nama, keluhan, alamat, jadwal
      │  • Service method yang dipilih customer
      │  • Estimasi pendapatan
      │
      ├──[Tombol CHAT]──► Bisa chat dengan customer dulu
      │
      ▼ [diamond: keputusan]
      │
      ├── CANCEL / TOLAK ──► 🔔 Notifikasi MERAH ke customer
      │                         Status: "cancelled"
      │                         Teknisi → FINISH ⭕
      │
      └── ACCEPT / TERIMA ──► 🔔 Notifikasi HIJAU ke customer
                                  Status: "confirmed"
                                  Generate kode 6 digit
                                  lanjut ke bawah
```

---

### BAGIAN 3 — Datang ke Lokasi & Verifikasi

```
[Datang ke Lokasi Customer]
      │  • Tombol "Navigate to Location" → buka maps
      │  • Lihat estimasi pendapatan bersih
      │  • Status: on the way
      ▼
[Input Kode Verifikasi]
      │  • Customer tunjukkan kode 6 digit
      │  • Teknisi input kode
      │
      ▼ [diamond: kode benar/salah?]
      │
      ├── SALAH ──► Input ulang kode (kembali ke form input)
      │
      └── BENAR ──► Status: "diagnosing"
                        lanjut ke bawah
```

---

### BAGIAN 4 — Diagnosa & Penawaran Harga

```
[Diagnosa Perangkat]
      │  • Teknisi periksa perangkat/kendaraan
      │  • Tentukan kerusakan
      ▼
[Input Penawaran Harga]
      │  • Input ringkasan diagnosa
      │  • Input service fee
      │  • Tambah parts + harga (bisa multiple)
      │  • Lihat live total kalkulasi
      │  • Tambah catatan untuk customer (opsional)
      │  • Info: "Diagnosis fee Rp X tetap berlaku jika ditolak"
      │  • Tap "Confirm" → kirim penawaran
      │  • Status: "awaiting_approval"
      ▼
[Menunggu Respons Customer]
      │  • "Menunggu respons pelanggan..."
      │  • Estimasi tunggu 5-10 menit
      │  • Bisa chat dengan customer
      │  • Info: jika disetujui → lanjut repair
      │           jika ditolak → hentikan, customer bayar diag fee
      │
      ▼ [diamond: respons customer]
      │
      ├── DITOLAK ──► Status: "diagnosis_only"
      │                Customer bayar diagnosis fee saja
      │                Teknisi selesai ⭕
      │
      └── DISETUJUI ──► Status: "on_progress"
                            lanjut ke bawah
```

---

### BAGIAN 5 — Kerjakan & Selesaikan

```
[Repair On Progress]
      │  • Pilih metode perbaikan:
      │    - Repair di tempat  → langsung dikerjakan di lokasi customer
      │    - Dibawa pulang     → teknisi bawa perangkat ke workshop
      │  • Bisa chat dengan customer
      ▼
[Pekerjaan Selesai]
      │  • Tap "Selesaikan Pekerjaan"
      ▼
[Update Order Detail & Input Harga Final]
      │  • Konfirmasi rincian pekerjaan
      │  • Input harga final (bisa sama atau beda dari estimasi)
      │  • Input info garansi (opsional)
      │  • Status: "done"
      │  • Customer mendapat notifikasi untuk bayar
      ▼
[Menunggu Konfirmasi Pembayaran dari Customer]
      │  • Tunggu customer melakukan pembayaran
      ▼
[Payment Accepted — Pekerjaan Selesai]
      │  • Modal: "Payment Accepted ✓"
      │  • Tampil ringkasan pendapatan
      │  • Tombol "Find Another Job"
      ▼
[Kembali ke Home Teknisi] ⭕
```

---

## 🔴 ADMIN FLOW (Diimplementasi Belakangan)

```
[Teknisi Submit Registrasi]
      │
      ▼
[Admin Panel — Lihat Pending Teknisi]
      │  • List teknisi yang menunggu verifikasi
      │  • Lihat data: KTP, selfie, sertifikasi, biodata
      │
      ▼ [diamond: keputusan]
      │
      ├── DECLINE ──► Status: "declined"
      │                Teknisi dapat notifikasi ditolak
      │                (bisa resubmit dengan data diperbaiki)
      │
      └── VERIF / APPROVE ──► Status: "verified"
                                  Teknisi aktif di platform
                                  Muncul di pencarian customer
```

---

## ⚡ Interaksi Antar Aktor (Panah Merah di Diagram)

Ini adalah titik-titik di mana Customer dan Teknisi saling berinteraksi secara real-time:

| Event | Dari | Ke | Yang Terjadi |
|---|---|---|---|
| Teknisi **ACCEPT** order | Teknisi | Customer | Notif hijau + kode 6 digit muncul di customer |
| Teknisi **CANCEL** order | Teknisi | Customer | Notif merah + order dibatalkan |
| Customer **tunjukkan kode** | Customer | Teknisi | Teknisi input kode → verifikasi |
| Teknisi **kirim penawaran** | Teknisi | Customer | Customer lihat harga + bisa approve/decline |
| Customer **setuju penawaran** | Customer | Teknisi | Teknisi mulai kerjakan |
| Customer **tolak penawaran** | Customer | Teknisi | Teknisi stop, customer bayar diag fee |
| Teknisi **selesai + input harga final** | Teknisi | Customer | Customer diminta bayar |
| Customer **bayar** | Customer | Teknisi | Teknisi dapat konfirmasi pembayaran |

---

## 📊 State Machine Status Booking (Lengkap)

```
                         ┌─ CANCEL ──────────────────────────────► cancelled
                         │
pending ──[Teknisi Accept]──► confirmed ──[Kode Benar]──► diagnosing
                                                               │
                                              ┌─[Teknisi Kirim Harga]─┘
                                              ▼
                                       awaiting_approval
                                              │
                              ┌───────────────┴───────────────┐
                              │                               │
                         [Ditolak]                       [Disetujui]
                              │                               │
                              ▼                               ▼
                        diagnosis_only                   on_progress
                              │                               │
                         [Bayar diag fee]           [Teknisi Selesai]
                              │                               │
                              ▼                               ▼
                           selesai                          done
                                                             │
                                                      [Customer Bayar]
                                                             │
                                                      [Beri Rating]
                                                             │
                                                          finish ⭕
```

---

## 🆕 Ringkasan: Yang Baru vs Yang Lama

| | Workflow Lama (v1) | Workflow Baru (v2) |
|---|---|---|
| **Registrasi teknisi** | Form singkat | 6-step onboarding lengkap |
| **Verifikasi teknisi** | Langsung aktif | Admin verif (sementara: auto) |
| **Sebelum order** | Langsung isi form | Pilih service method dulu |
| **Payment timing** | Di awal (checkout) | Di akhir (setelah selesai) |
| **Harga** | Estimasi saja | Teknisi input harga final aktual |
| **Diagnosa** | Tidak ada | Ada — teknisi diagnosa dulu |
| **Penawaran harga** | Tidak ada | Ada — customer bisa approve/tolak |
| **Diagnosis fee** | Tidak ada | Ada — bayar meski tolak penawaran |
| **Repair method** | Tidak dipilih | Pick-up atau Dibawa pulang |
| **Navigasi teknisi** | Tidak ada | Ada — navigate to location |
| **Receipt/Invoice** | Tidak ada | Ada — setelah bayar |
| **Garansi** | Tidak ada | Ada — input teknisi saat selesai |
| **Saved Addresses** | Tidak ada | Ada — customer simpan alamat |
| **Notifikasi** | Tidak ada (real-time stream saja) | Push notification (FCM) |
| **Status booking** | 5 status | 8 status |

---

*Dokumen ini adalah breakdown dari diagram "Workflow Nanti" (gambar tangan) + Figma Version 3.0*
*Untuk rencana implementasi lengkap → lihat REWORK_PLAN.md*
