# ELECTROVICE — Rework Plan v2.0

> Dokumen ini menjelaskan perubahan besar yang akan dilakukan pada aplikasi ELECTROVICE,
> berdasarkan Workflow Nanti (diagram tangan) dan desain Figma Version 3.0.
> Baca dokumen ini sebelum menyentuh kode apapun di rework ini.
> Last updated: 2026-04-11

---

## Daftar Isi

1. [Ringkasan Perubahan](#1-ringkasan-perubahan)
2. [Workflow Baru — Customer](#2-workflow-baru--customer)
3. [Workflow Baru — Technician](#3-workflow-baru--technician)
4. [Workflow Admin (Sementara)](#4-workflow-admin-sementara)
5. [Screens Baru dari Figma](#5-screens-baru-dari-figma)
6. [Perubahan Firestore Schema](#6-perubahan-firestore-schema)
7. [Perubahan UI Theme](#7-perubahan-ui-theme)
8. [Rencana Implementasi (Urutan Prioritas)](#8-rencana-implementasi-urutan-prioritas)
9. [Yang TIDAK Berubah](#9-yang-tidak-berubah)

---

## 1. Ringkasan Perubahan

| Aspek | Sebelum (v1) | Sesudah (v2) |
|---|---|---|
| **Registrasi Teknisi** | Form sederhana (nama, kategori, bio) | 6-step onboarding (KTP, selfie, sertifikasi, lokasi, pricing) |
| **Verifikasi Teknisi** | Langsung aktif setelah register | Admin verifikasi dulu (sementara: auto-verified) |
| **Booking Flow** | Customer isi form → checkout → bayar → teknisi datang | Customer pesan → teknisi datang → diagnosa → kirim penawaran → customer approve → bayar |
| **Payment Timing** | Di awal (checkout sebelum teknisi datang) | Di akhir (setelah pekerjaan selesai) |
| **Harga** | Estimasi saja dari profil teknisi | Harga aktual dari teknisi setelah diagnosa (service fee + parts) |
| **Diagnosis Fee** | Tidak ada | Ada — biaya diagnosa tetap dibayar meski customer tolak penawaran |
| **Service Method** | Tidak dipilih | Customer pilih: teknisi datang ke rumah (Pick-up) atau bawa ke workshop (Drop-in) |
| **Receipt/Invoice** | Tidak ada | Ada — customer dapat invoice setelah bayar |
| **Navigasi Teknisi** | Tidak ada | Ada — teknisi bisa navigate ke lokasi customer via maps |
| **Warranty** | Tidak ada | Ada — tampil di detail history |
| **Saved Addresses** | Tidak ada | Ada — customer bisa simpan alamat |
| **Promo Code** | Tidak ada | Ada (UI sudah di Figma) |
| **UI Theme** | Hitam-putih (sudah ada) | Hitam-putih konsisten (beberapa screen masih biru/light — harus diseragamkan) |

---

## 2. Workflow Baru — Customer

```
[Role Selection / Entry]
    │  • Pilih: "I am a Customer" atau "I am a Technician"
    │  • Tombol Continue → Login/Register sesuai role
    ▼

[Customer Login]  /login
    │  • Email + Password
    │  • Google Sign-In
    │  • Link ke Register
    │  • Link Forgot Password
    ▼

[User Home & Discovery]  /home  ← REWORK UI
    │  • Hero Map Section — tampilkan teknisi sekitar (Mapbox)
    │  • "12 active specialists available now"
    │  • Active Job Banner (muncul jika ada order aktif)
    │  • Kategori: TV & Audio, Computers, Appliances, Vehicles
    │  • Featured Specialists (nearby)
    │  • Bottom Nav: Home | History | Profile | ORDER
    ▼

[Search & Filter Results]  /customer/technician-list  ← REWORK UI
    │  • Filter chips: Distance | Rating | Price Range | Open Now
    │  • Kartu teknisi: nama, jarak, rating, "From Rp X"
    │  • Tombol "Book Now" per kartu
    ▼

[Technician Detail]  /customer/technician-detail  ← REWORK UI
    │  • Stats bento: jobs done | completion rate | avg rating
    │  • Accreditations (sertifikasi)
    │  • Service Estimates (estimasi harga per layanan)
    │  • Workshop info + alamat
    │  • Reviews (dari customer lain)
    │  • Bottom bar: "Book Now"
    ▼ tap "Book Now"

[Booking Form — Pilih Service]  /customer/create-order  ← REWORK
    │  • Pilih service method: Pick-up (teknisi ke rumah) | Drop-in (bawa ke workshop)
    │  • Pilih device category
    │  • Deskripsi keluhan
    │  • Alamat (manual atau dari Saved Addresses)
    │  • GPS auto-detect
    │  • Pilih tanggal & slot waktu
    │  • Lihat estimasi harga + kemungkinan harga
    ▼ tap "Lanjut"

[Checkout / Order Confirmation]  /customer/checkout  ← REWORK
    │  • Ringkasan: teknisi, jadwal, service method
    │  • Estimasi biaya (belum final — akan dikonfirmasi teknisi)
    │  • TIDAK ADA PEMBAYARAN DI SINI
    │  • Tombol "Konfirmasi Pesanan"
    ▼ konfirmasi → status: "pending"

[Order Tracking — Menunggu Konfirmasi]  /customer/order-tracking  ← REWORK
    │  • Status: Menunggu konfirmasi teknisi
    │  • Teknisi accept → status: "confirmed"
    │  • Kode 6 digit muncul setelah teknisi accept
    ▼ teknisi accept → status: "confirmed"

[Order Tracking — On The Way]
    │  • Status: Teknisi sedang menuju lokasi
    │  • Tombol chat ke teknisi
    ▼ teknisi tiba → input kode → status: "diagnosing"

[Order Tracking — Diagnosa]  ← STATUS BARU
    │  • Status: Teknisi sedang mendiagnosa
    │  • Menunggu penawaran harga dari teknisi
    ▼ teknisi kirim penawaran → status: "awaiting_approval"

[Pricing Estimation & Offer — Customer View]  ← SCREEN BARU
    │  • Tampil ringkasan diagnosa dari teknisi
    │  • Rincian biaya: Service Fee + Parts (nama + harga per item)
    │  • Total estimasi
    │  • Catatan dari teknisi
    │  • 2 tombol:
    │    - "Setuju" → status: "on_progress"
    │    - "Tolak" → status: "diagnosis_only" (bayar diagnosis fee saja)
    ▼

[Kasus A: Customer Setuju]
    │  → status: "on_progress"
    │  → teknisi mulai perbaikan
    ▼

[Order Tracking — Repair In Progress]
    │  • Status: Sedang diperbaiki
    │  • Info: repair di tempat atau dibawa pulang
    │  • Tombol chat
    ▼ teknisi selesai → status: "done"

[Melakukan Pembayaran]  ← SCREEN BARU (setelah selesai)
    │  • Tampil total final dari teknisi
    │  • Pilih metode bayar: Tunai | Non-tunai
    │  • Konfirmasi pembayaran
    ▼

[Invoice / Payment Proof]  /customer/invoice  ← SCREEN BARU
    │  • Payment Success
    │  • Invoice # dengan rincian biaya
    │  • Download PDF (opsional)
    ▼

[Review Page]  /review
    │  • Beri bintang 1-5
    │  • Teks ulasan + quick tags
    ▼ Get.offAllNamed → Home

[Kasus B: Customer Tolak Penawaran]
    │  → status: "diagnosis_only"
    │  → customer hanya bayar diagnosis fee
    │  → tampil halaman bayar diagnosis fee saja
    ▼ selesai → Home
```

---

## 3. Workflow Baru — Technician

```
[Daftar Akun — Technician Onboarding 6 Steps]  ← REWORK BESAR
    │
    │  Step 1: Personal Info
    │    • Nama lengkap
    │    • Nomor HP
    │    • Gender
    │    • Bio singkat
    │
    │  Step 2: Identity Verification
    │    • Upload foto KTP
    │    • Upload selfie dengan KTP
    │    • NIK (Nomor Induk Kependudukan)
    │
    │  Step 3: Location
    │    • Kota/Area
    │    • Nama workshop (opsional)
    │    • Alamat workshop
    │    • Service radius: 1-3km | up to 5km | 10km
    │    • Hari buka (M/T/W/T/F/S/S)
    │    • Jam operasional (09:00 – 18:00)
    │
    │  Step 4: Skills
    │    • Device categories (multi-select):
    │      Laptop | Smartphone | Home appliance |
    │      AC & Cooling | TV & Display | Vehicles | Other
    │    • Service method: Pick-up | Drop-in
    │    • Years of experience: <1yr | 1-2yr | 3-5yr | 5yr+
    │    • Upload sertifikasi (opsional, JPG/PNG max 5MB)
    │
    │  Step 5: Pricing
    │    • Diagnosis fee (Rp) — biaya awal diagnosa
    │
    │  Step 6: Review & Submit
    │    • Tampil ringkasan semua data
    │    • Tombol "Submit Registration"
    │    → status akun: "pending_verification"
    │
    ▼ (sementara: auto-verified, nanti butuh admin approve)

[Technician Home]  /technician/home  ← REWORK UI
    │  • Toggle online/offline
    │  • Stream order masuk (status: pending)
    │  • Card "Current Assignment" jika ada order aktif
    │  • Bottom Nav: Job | Quote | History | Profile
    ▼ ada order masuk

[Job Detail (Technician View)]  /technician/job-detail  ← REWORK UI
    │  • Info customer: nama, keluhan, alamat, jadwal
    │  • Service method yang dipilih customer
    │  • Estimasi pendapatan
    │  • Tombol Chat
    │  • Tombol "Terima" → acceptOrder()
    │  • Tombol "Tolak" → declineOrder()
    ▼ tap "Terima" → status: "confirmed", generate kode 6 digit

[Navigasi ke Lokasi]  ← FITUR BARU
    │  • Map dengan rute ke lokasi customer
    │  • "Navigasi ke Lokasi" → buka maps
    │  • Estimasi pendapatan bersih card
    ▼ tiba di lokasi

[Job Detail & Verification]  /technician/verification  ← REWORK
    │  • Input kode 6 digit dari customer
    │  • Verifikasi → status: "diagnosing"
    ▼ kode valid

[Diagnosa & Input Penawaran Harga]  /technician/pricing  ← SCREEN BARU
    │  • Input ringkasan diagnosa (teks)
    │  • Input service fee
    │  • Tambah parts (nama part + harga, bisa multiple)
    │  • Live total kalkulasi otomatis
    │  • Catatan untuk customer
    │  • Info: "Biaya diagnosa Rp X tetap berlaku jika ditolak"
    │  • Tombol "Confirm" → kirim penawaran → status: "awaiting_approval"
    ▼

[Pending Approval (Technician)]  /technician/pending-approval  ← SCREEN BARU
    │  • "Menunggu respons pelanggan..."
    │  • Estimasi waktu tunggu: 5-10 menit
    │  • Ringkasan biaya yang dikirim
    │  • Tombol Chat ke customer
    │  • Info:
    │    - Jika disetujui → langsung mulai perbaikan
    │    - Jika ditolak → hentikan, customer bayar diagnosis fee saja
    ▼

[Kasus A: Customer Setuju → status: "on_progress"]

[Active Job Page]  /technician/active-job  ← REWORK
    │  • Info pekerjaan aktif
    │  • Pilih repair method: Dibawa Pulang | Repair di Tempat
    │  • Tombol Chat
    │  • Tombol "Selesaikan Pekerjaan"
    ▼ tap selesai → status: "done"

[Complete Job]  /technician/complete-job  ← REWORK
    │  • Modal "Payment Accepted" saat customer sudah bayar
    │  • Tombol "Find Another Job" → kembali ke Home
    ▼

[Kasus B: Customer Tolak → status: "diagnosis_only"]
    │  → Teknisi hentikan pekerjaan
    │  → Customer bayar diagnosis fee saja
    ▼ selesai → Home Teknisi
```

---

## 4. Workflow Admin (Sementara)

```
RENCANA AKHIR:
  Teknisi submit registrasi → Admin panel → Verif / Decline

SEMENTARA (sebelum admin panel jadi):
  Teknisi submit registrasi → status otomatis "verified"
  → Teknisi langsung bisa aktif

IMPLEMENTASI SEMENTARA:
  - Field `verificationStatus` di Firestore: "pending" | "verified" | "declined"
  - Saat submit onboarding → langsung set verificationStatus: "verified"
  - Nanti ketika admin panel dibuat → ubah logika ini
```

---

## 5. Screens Baru dari Figma

Berdasarkan analisis Figma Version 3.0 (58 screens total):

### Screen Baru yang Perlu Dibuat

| Screen | Route Baru | Keterangan |
|---|---|---|
| Role Selection / Entry | `/` atau `/entry` | Welcome screen pilih role |
| OTP Verification | `/otp` | 6-digit OTP dengan custom keypad + timer |
| Forgot Password | `/forgot-password` | Reset password via email |
| Technician Onboarding Step 1 | `/technician/onboarding/personal` | Personal info |
| Technician Onboarding Step 2 | `/technician/onboarding/identity` | KTP + selfie upload |
| Technician Onboarding Step 3 | `/technician/onboarding/location` | Lokasi + jadwal |
| Technician Onboarding Step 4 | `/technician/onboarding/skills` | Keahlian + sertif |
| Technician Onboarding Step 5 | `/technician/onboarding/pricing` | Diagnosis fee |
| Technician Onboarding Step 6 | `/technician/onboarding/review` | Review & submit |
| Pricing Estimation & Offer (Technician) | `/technician/pricing` | Input diagnosa + harga |
| Pending Approval (Technician) | `/technician/pending-approval` | Tunggu customer |
| Pricing Offer (Customer View) | `/customer/offer` | Approve/decline penawaran |
| Diagnosis Fee Page | `/customer/diagnosis-fee` | Bayar jika tolak penawaran |
| Payment Page | `/customer/payment` | Bayar setelah selesai |
| Invoice / Payment Proof | `/customer/invoice` | Receipt setelah bayar |
| Detail History & Warranty | `/customer/history-detail` | Detail history + garansi |
| Saved Addresses | `/customer/saved-addresses` | Kelola alamat tersimpan |
| Navigate to Location (Technician) | bagian dari job detail | Peta navigasi ke customer |

### Screen yang Di-rework UI-nya (Sudah Ada, Perlu Update)

| Screen | Yang Berubah |
|---|---|
| Home Page (Customer) | Map hero section, active job banner, UI theme |
| Search & Filter | Filter chips baru (Price range, Open Now) |
| Technician Detail | Bento stats card, layout baru |
| Booking Form | Tambah service method picker |
| Checkout | Hilangkan payment — hanya konfirmasi order |
| Order Tracking | Tambah status baru (diagnosing, awaiting_approval) |
| Technician Home | UI baru, bottom nav baru |
| Job Detail (Teknisi) | Tambah navigasi map, earnings card |
| Active Job | Tambah pilihan repair method |

---

## 6. Perubahan Firestore Schema

### 6.1 Collection `users` — Tambahan Field

```
users/{uid}
└── technicianProfile : Map
    ├── ... (field lama tetap ada)
    ├── verificationStatus : String   — "pending" | "verified" | "declined"  ← BARU
    ├── ktpImageUrl        : String?  — URL foto KTP di Storage                ← BARU
    ├── selfieImageUrl     : String?  — URL selfie + KTP di Storage            ← BARU
    ├── certificationUrls  : List<String>?  — URL sertifikasi                  ← BARU
    ├── diagnosisFee       : int      — biaya diagnosa (Rp)                    ← BARU
    ├── serviceMethod      : List<String>   — ["pickup", "dropoff"]            ← BARU
    ├── availableDays      : List<String>   — ["mon","tue","wed",...]          ← BARU
    ├── openTime           : String   — "09:00"                                ← BARU
    └── closeTime          : String   — "18:00"                                ← BARU
```

### 6.2 Collection `bookings` — Tambahan & Perubahan Field

```
bookings/{bookingId}
├── ... (field lama tetap ada)
├── serviceMethod      : String    — "pickup" | "dropoff"           ← BARU
├── diagnosisFee       : int       — biaya diagnosa dari profil teknisi ← BARU
│
│   — Field diagnosa (diisi teknisi setelah cek) —
├── diagnosisSummary   : String?   — ringkasan hasil diagnosa       ← BARU
├── serviceFee         : int?      — biaya jasa teknisi (final)     ← BARU
├── parts              : List<Map>? — daftar parts                  ← BARU
│   └── {name: String, price: int}
├── totalFinalPrice    : int?      — total akhir setelah diagnosa   ← BARU
├── technicianNotes    : String?   — catatan teknisi ke customer    ← BARU
│
│   — Field approval —
├── offerSentAt        : Timestamp? — kapan teknisi kirim penawaran ← BARU
├── offerResponseAt    : Timestamp? — kapan customer respond        ← BARU
├── offerAccepted      : bool?      — true=setuju, false=tolak      ← BARU
│
│   — Field payment —
├── paymentCompletedAt : Timestamp? — kapan pembayaran selesai      ← BARU
├── warrantyInfo       : String?    — info garansi dari teknisi     ← BARU
│
└── status : String    — DIPERLUAS:
    │  "pending"           — menunggu konfirmasi teknisi
    │  "confirmed"         — teknisi accept, on the way
    │  "diagnosing"        — teknisi tiba, sedang diagnosa  ← BARU
    │  "awaiting_approval" — penawaran dikirim ke customer  ← BARU
    │  "on_progress"       — customer setuju, sedang dikerjakan
    │  "done"              — pekerjaan selesai
    │  "diagnosis_only"    — customer tolak, bayar diag fee ← BARU
    │  "cancelled"         — dibatalkan
```

### 6.3 Collection `saved_addresses` — BARU

```
saved_addresses/{addressId}
├── userId     : String
├── label      : String    — "Rumah" | "Kantor" | custom
├── address    : String
├── latitude   : double
├── longitude  : double
└── createdAt  : Timestamp
```

---

## 7. Perubahan UI Theme

### Masalah Sekarang
Beberapa screen di Figma masih menggunakan tema berbeda:
- "Chat with Technician" → `Light` theme (putih)
- Beberapa customer screen → aksen biru (#0160FF)
- Technician screens → sudah dark/hitam

### Target Theme
**Hitam-Putih Konsisten** dengan modifikasi dari desain awal:

| Elemen | Warna |
|---|---|
| Background utama | `#000000` atau `#0A0A0A` |
| Surface/Card | `#1A1A1A` atau `#111111` |
| Text utama | `#FFFFFF` |
| Text sekunder | `#9E9E9E` |
| Accent / CTA | `#FFFFFF` (tombol putih di atas background hitam) |
| Border / Divider | `#2A2A2A` |
| Success state | `#22C55E` (hijau dari Figma — sudah oke) |
| Error state | `#EF4444` |

> ⚠️ **Catatan**: Seragamkan semua screen ke theme ini.
> Chat page yang sekarang "Light" → jadikan dark juga.

---

## 8. Rencana Implementasi (Urutan Prioritas)

### Phase 1 — Fondasi (Lakukan Dulu)
- [ ] **Firebase Storage setup** — dibutuhkan untuk upload KTP, selfie, sertifikasi
- [ ] **Tambah field baru di Firestore schema** (status baru, parts, dll)
- [ ] **Update theme** — seragamkan warna ke hitam-putih di `theme.dart`
- [ ] **Role Selection / Entry screen** — welcome screen baru

### Phase 2 — Technician Onboarding (Prioritas Tinggi)
- [ ] Step 1: Personal Info page
- [ ] Step 2: Identity (KTP + selfie upload)
- [ ] Step 3: Location + jadwal (reuse Mapbox picker yang sudah ada)
- [ ] Step 4: Skills + sertifikasi upload
- [ ] Step 5: Diagnosis fee input
- [ ] Step 6: Review & Submit
- [ ] Auto-verified logic (sementara sebelum admin panel)

### Phase 3 — Diagnosis Flow (Perubahan Terbesar)
- [ ] Update `booking_service.dart` — tambah method baru:
  - `sendDiagnosisOffer()` — teknisi kirim penawaran
  - `respondToOffer()` — customer setuju/tolak
  - `completePayment()` — tandai sudah bayar
- [ ] Pricing Estimation screen (technician side)
- [ ] Pending Approval screen (technician side)
- [ ] Offer View screen (customer side — approve/decline)
- [ ] Update status state machine di BookingController

### Phase 4 — Payment & Invoice
- [ ] Payment screen (pilih metode bayar, muncul setelah done)
- [ ] Invoice / Receipt screen
- [ ] Diagnosis Fee only screen (jika customer tolak)

### Phase 5 — UI Rework Screens yang Ada
- [ ] Home page customer (map hero, active job banner)
- [ ] Search & filter (filter chips baru)
- [ ] Technician detail (bento stats card)
- [ ] Booking form (tambah service method)
- [ ] Checkout (hilangkan payment form)
- [ ] Order tracking (status baru)
- [ ] Technician home (UI baru)
- [ ] Job detail technician (map navigasi + earnings)
- [ ] Chat page (dark theme)

### Phase 6 — Fitur Tambahan
- [ ] Saved Addresses
- [ ] OTP Verification (jika diperlukan untuk email verify)
- [ ] Forgot Password
- [ ] Warranty info di history detail
- [ ] Promo Code section
- [ ] Notification (FCM) — teknisi dapat notif, customer dapat notif

### Phase 7 — Admin Panel (Belakangan)
- [ ] Web admin panel (Flutter Web atau terpisah)
- [ ] List teknisi pending verification
- [ ] Approve / Decline dengan alasan
- [ ] Update `verificationStatus` di Firestore

---

## 9. Yang TIDAK Berubah

Fitur-fitur berikut **tidak perlu diubah** (hanya mungkin UI-nya disesuaikan tema):

| Fitur | Keterangan |
|---|---|
| Firebase Auth (email + Google) | Tetap sama |
| Geo-query teknisi terdekat (geoflutterfire_plus) | Tetap sama |
| Kode verifikasi 6 digit | Tetap ada, logika sama |
| Chat real-time | Logika sama, hanya UI theme berubah |
| Rating & Review system | Tetap sama |
| Mapbox location picker | Tetap dipakai di onboarding teknisi |
| GetX routing & state management | Tetap sama |
| Booking history | Tetap ada, tambah detail history |
| Toggle online/offline teknisi | Tetap ada |

---

## Catatan Penting untuk Developer

1. **Jangan hapus field lama di Firestore** — tambah field baru saja, pakai `merge: true`
2. **Status state machine berubah** — update semua listener yang bergantung pada status lama
3. **Technician onboarding adalah flow baru** — register page lama untuk teknisi diganti total
4. **Payment BUKAN di checkout lagi** — checkout sekarang hanya konfirmasi order
5. **Admin panel belum ada** — gunakan `verificationStatus: "verified"` otomatis untuk sementara
6. **Firebase Storage belum dikonfigurasi** — ini harus diselesaikan PERTAMA sebelum onboarding teknisi bisa jalan

---

*Dokumen ini dibuat berdasarkan: Workflow diagram (gambar tangan) + analisis Figma Version 3.0 (58 screens, file: Electrovica)*
*Figma File ID: JybvgagvxA5yqdGLsASKsl*
