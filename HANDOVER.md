# ELECTROVICE — Developer Handover Document

> Dokumen ini adalah referensi lengkap aplikasi ELECTROVICE.
> Baca seluruh dokumen ini sebelum menyentuh kode apapun.
> Last updated: 2026-04-11

---

## Daftar Isi

1. [Tech Stack](#1-tech-stack)
2. [Gambaran Aplikasi](#2-gambaran-aplikasi)
3. [Struktur Folder](#3-struktur-folder)
4. [Booking Flow Lengkap](#4-booking-flow-lengkap)
5. [Firebase — Collections & Fields](#5-firebase--collections--fields)
6. [Security Rules](#6-security-rules)
7. [Composite Indexes](#7-composite-indexes)
8. [Semua Routes](#8-semua-routes)
9. [Arsitektur Controller](#9-arsitektur-controller)
10. [Fitur yang Sudah Ada](#10-fitur-yang-sudah-ada)
11. [Fitur yang Belum Ada (Pending)](#11-fitur-yang-belum-ada-pending)
12. [Aturan Penting (Do & Don't)](#12-aturan-penting-do--dont)
13. [Setup Environment](#13-setup-environment)

---

## 1. Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | GetX (`Rxn`, `RxList`, `Obx`, `GetView`, `fenix: true`) |
| Backend | Firebase Auth + Firestore |
| Maps | Mapbox (`mapbox_maps_flutter`) |
| Geo Query | `geoflutterfire_plus` (radius-based technician search) |
| Location | `geolocator` |
| Navigation | GetX Named Routes |

---

## 2. Gambaran Aplikasi

ELECTROVICE adalah platform marketplace servis elektronik & kendaraan yang menghubungkan **customer** (pengguna yang membutuhkan servis) dengan **teknisi** (penyedia jasa).

**2 Role Utama:**
- **Customer** — cari teknisi, buat booking, tracking order, chat, beri rating
- **Technician** — terima/tolak order, verifikasi kode, kerjakan, selesaikan

**Cara kerja singkat:**
1. Customer buka app → cari teknisi terdekat (radius 50km, geo-query Firestore)
2. Customer pilih teknisi → isi form → checkout → booking masuk Firestore
3. Teknisi terima notif order baru → accept → sistem generate kode 6 digit
4. Kode tampil di sisi customer → customer tunjukkan ke teknisi
5. Teknisi input kode → verifikasi → pengerjaan dimulai
6. Teknisi selesai → customer otomatis diarahkan ke halaman rating
7. Customer beri bintang + ulasan → rating teknisi dikalkulasi ulang

---

## 3. Struktur Folder

```
lib/
├── config/
│   ├── routes.dart             ← SEMUA route terdaftar di sini
│   ├── theme.dart
│   └── mapbox_config.dart      ← API key Mapbox (JANGAN commit ke public)
├── models/
│   ├── booking_document.dart   ← Model Firestore utama booking
│   ├── booking_model.dart      ← UI models (CheckoutSummary, TrackingData, dll)
│   ├── user_model.dart         ← UserModel + TechnicianProfile (nested)
│   └── technician_model.dart   ← UI models untuk technician pages
├── services/
│   ├── auth_service.dart       ← Firebase Auth + Firestore user CRUD
│   ├── booking_service.dart    ← Semua operasi booking Firestore
│   ├── chat_service.dart       ← Chat + ChatMessage model
│   └── technician_service.dart ← Geo-query + TechnicianOnlineModel
├── modules/
│   ├── auth/                   ← Login, Register, Signup
│   ├── booking/                ← Seluruh flow customer
│   │   ├── booking_controller.dart          ← Controller utama customer
│   │   ├── booking_technician_detail_page.dart
│   │   ├── booking_form_page.dart
│   │   ├── checkout_page.dart
│   │   ├── booking_tracking_page.dart
│   │   ├── booking_history_page.dart
│   │   └── review_page.dart
│   ├── chat/
│   │   ├── chat_controller.dart
│   │   └── chat_page.dart
│   ├── home/
│   │   ├── home_controller.dart
│   │   └── home_page.dart
│   ├── profile/
│   │   ├── profile_controller.dart
│   │   ├── profile_page.dart
│   │   └── profile_edit_page.dart
│   └── technician/             ← Seluruh flow teknisi
│       ├── technician_controller.dart       ← Controller utama teknisi
│       ├── technician_home_page.dart
│       ├── technician_list_page.dart        ← Search & filter teknisi
│       ├── technician_profile_page.dart
│       ├── technician_profile_edit_page.dart
│       ├── mapbox_location_picker_page.dart
│       ├── job_detail_page.dart
│       ├── verification_page.dart
│       ├── active_job_page.dart
│       └── job_summary_page.dart
└── widget/
    └── app_bottom_nav_bar.dart
```

---

## 4. Booking Flow Lengkap

### 4.1 Customer Flow

```
[Home Page]  /home
    │  • Greeting dengan nama user
    │  • Hero CTA card → ke TechnicianList
    │  • Search bar (tap → ke TechnicianList)
    │  • Grid 2×3 kategori: Handphone, Komputer, TV & Audio,
    │    Elektronik, AC/Kulkas, Kendaraan
    │  • Daftar "Teknisi Terdekat" (geo-query radius 10km)
    │
    ▼ tap kategori / hero card / search
[Technician List Page]  /customer/technician-list
    │  • Geo-query radius 50km dari GPS customer
    │  • Search bar real-time (nama / spesialisasi)
    │  • Filter chip: kategori (electronic/vehicle) + min rating
    │  • Sort by jarak (terdekat duluan)
    │  • Empty state + tombol "Reset Filter"
    │
    ▼ tap card teknisi
[Technician Detail Page]  /customer/technician-detail
    │  BACA: BookingController di-DELETE & dibuat BARU di sini
    │        agar arguments (TechnicianOnlineModel) terbaca
    │  • Nama, foto, rating, spesialisasi, pengalaman
    │  • Daftar estimasi harga per layanan
    │  • Review customer lain (dari Firestore, maks 10 terbaru)
    │  • Garansi kode verifikasi 6 digit
    │  • Alamat workshop
    │
    ▼ tap "Pesan Sekarang"
[Booking Form Page]  /customer/create-order
    │  • Dropdown damage type:
    │    screen | battery | hardware | water | camera | other
    │  • TextField deskripsi keluhan (WAJIB diisi)
    │  • TextField alamat customer (WAJIB diisi)
    │  • Tombol GPS → deteksi koordinat lat/lng
    │  • Date picker → pilih tanggal servis
    │  • Slot chips (load otomatis setelah pilih tanggal):
    │    08.00–10.00 | 10.00–12.00 | 12.00–14.00 |
    │    14.00–16.00 | 16.00–17.00
    │    → Slot "Penuh" = teknisi sudah ada booking di jam itu
    │    → Slot "Lewat" = jam sudah berlalu hari ini
    │    → Slot tersedia = putih, terpilih = hitam
    │
    ▼ tap "Lanjut ke Pembayaran"
[Checkout Page]  /customer/checkout
    │  • Ringkasan: damage type, jadwal (tanggal + jam), teknisi
    │  • Pilih metode bayar (saat ini: Tunai saja)
    │  • Estimasi harga dari profil teknisi
    │  • Service fee + parts fee + tax (semua bisa 0)
    │
    ▼ tap "Konfirmasi Pesanan"
    │  → createBooking() → Firestore bookings/{id}
    │  → status: "pending"
    │
    ▼ Get.offNamed (checkout di-pop dari stack)
[Order Tracking Page]  /customer/order-tracking
    │  • Stream real-time dari Firestore (status berubah otomatis)
    │  • 5 Step tracker:
    │    1. Menunggu Konfirmasi Teknisi   ← current: pending
    │    2. Teknisi di Jalan              ← current: confirmed
    │    3. Verifikasi Kode 6 Digit       ← current: confirmed
    │    4. Sedang Diperbaiki             ← current: on_progress
    │    5. Selesai                       ← current: done
    │  • Kode 6 digit muncul SETELAH teknisi accept
    │    (status pending → kode disembunyikan "------")
    │  • Tombol "Message" → ChatPage
    │  • Banner "Beri Ulasan" muncul jika status=done & belum rating
    │
    ▼ OTOMATIS setelah status berubah jadi "done" (600ms delay)
    │  (hanya jika current route = /customer/order-tracking)
[Review Page]  /review
    │  • Card teknisi: nama, kategori, badge "SELESAI"
    │  • 5 bintang interaktif (label: Sangat Buruk → Luar Biasa!)
    │  • TextField ulasan teks bebas
    │  • Quick tags: Tepat waktu, Ramah, Profesional,
    │    Penjelasan Jelas, Bersih & Rapi, Harga Sesuai
    │  → submitReview() → update bookings/{id}
    │  → recalculate avg rating → update technicians_online/{uid}
    │
    ▼ Get.offAllNamed → Home
```

### 4.2 Technician Flow

```
[Technician Home Page]  /technician/home
    │  • Stream real-time order masuk (status: pending)
    │  • Toggle online/offline
    │  • "Current Assignment" card jika ada order confirmed/on_progress
    │
    ▼ ada order masuk → tap card / "Terima"
[Job Detail Page]  /technician/job-detail
    │  • Info customer: nama, alamat, kategori, damage type,
    │    deskripsi keluhan, jadwal, estimasi harga
    │  • Tombol Terima → acceptOrder()
    │  • Tombol Tolak → declineOrder() → status: cancelled
    │
    ▼ tap "Terima"
    │  → acceptBooking() → status: "confirmed"
    │  → sistem generate kode 6 digit random (100000–999999)
    │  → kode disimpan di bookings/{id}.verificationCode
    │  → codeExpiryAt = now + 2 jam
    │
[Verification Page]  /technician/verification
    │  • Input 6 digit kode dari customer
    │  → verifyCode() → cek kode + expiry
    │  → status: "on_progress"
    │  → codeVerifiedAt = serverTimestamp
    │
    ▼ kode valid
[Active Job Page]  /technician/active-job
    │  • Info pekerjaan aktif
    │  • Tombol chat ke customer
    │  • Tombol "Selesaikan Pekerjaan"
    │
    ▼ tap "Selesai"
    │  → markAsDone() → status: "done"
    │  → return BookingDocument (untuk ditampilkan di summary)
    │
[Job Summary Page]  /technician/job-summary
    │  • Nama customer, kategori, jenis kerusakan
    │  • Alamat, waktu selesai, estimasi harga (format Rupiah)
    │  • Metode pembayaran
    │
    ▼ tap "Kembali ke Beranda" → Get.offAllNamed(technicianHome)
```

### 4.3 Chat Flow

```
Tracking Page (customer) ATAU Active Job Page (teknisi)
    │
    ▼ tap tombol "Message/Chat"
    │  → ensureChatExists() jika chat doc belum ada
    │  → Get.toNamed('/chat', arguments: {chatId, otherPartyName, ...})
[Chat Page]  /chat
    │  • Stream pesan real-time dari chats/{bookingId}/messages
    │  • Bubble biru (#A5B8FB) = pesan sendiri
    │  • Bubble putih = pesan lawan bicara
    │  • Date separator: HARI INI / KEMARIN / dd MMM yyyy
    │  • Input: camera button (belum aktif) + TextField + send
    │  • markAsRead() dipanggil saat page dibuka
```

### 4.4 Status State Machine

```
                 ┌─ declineOrder ──────────────────────────────┐
                 │                                              ▼
pending ──acceptOrder──► confirmed ──verifyCode──► on_progress ──markAsDone──► done
                                                                                 │
                                                                          submitReview
                                                                         (customerRating
                                                                          tersimpan)
```

---

## 5. Firebase — Collections & Fields

### 5.1 Collection: `users`

Dokumen ID = Firebase Auth UID

```
users/{uid}
├── uid            : String         — sama dengan document ID
├── email          : String
├── name           : String
├── role           : String         — "customer" | "technician"
├── photoUrl       : String?        — URL foto profil
├── phone          : String?        — nomor HP
├── createdAt      : Timestamp
├── updatedAt      : Timestamp?
└── technicianProfile : Map?        — hanya ada jika role = "technician"
    ├── category       : String     — "electronic" | "vehicle"
    ├── bio            : String
    ├── specialty      : String     — contoh: "Teknisi HP & Laptop"
    ├── rating         : double     — rata-rata bintang (0.0–5.0)
    ├── totalRatings   : int        — jumlah review yang masuk
    ├── totalJobs      : int
    ├── yearsExperience: int
    ├── successRate    : int        — persentase (default 100)
    ├── serviceRadius  : double     — radius layanan dalam km
    ├── isAvailable    : bool
    └── photoUrl       : String?
```

**Data yang dikumpulkan saat Register:**
- email, password (Auth), name, role
- Jika teknisi: technicianProfile dibuat kosong secara otomatis

**Data yang dikumpulkan saat Edit Profile (Customer):**
- name, phone

**Data yang dikumpulkan saat Edit Profile (Teknisi):**
- name, technicianProfile.category, .specialty, .bio, .yearsExperience, .serviceRadius

---

### 5.2 Collection: `technicians_online`

Dokumen ID = Firebase Auth UID teknisi. Dipakai untuk geo-query mencari teknisi terdekat.

```
technicians_online/{uid}
├── uid              : String
├── name             : String
├── specialty        : String
├── category         : String       — "electronic" | "vehicle"
├── isAvailable      : bool
├── workshopAddress  : String
├── photoUrl         : String?
├── location         : Map          — GeoFirePoint format
│   ├── geopoint     : GeoPoint     — koordinat lat/lng
│   └── geohash      : String       — untuk geo-query
├── accreditations   : List<String> — sertifikasi/keahlian
├── serviceEstimates : List<Map>    — estimasi harga per layanan
│   └── {service: String, minPrice: int, maxPrice: int}
├── serviceRadius    : double       — radius layanan (km)
├── rating           : double       — avg rating (auto-update setelah review)
├── totalJobs        : int
├── totalRatings     : int          — auto-update setelah review
├── createdAt        : Timestamp
└── updatedAt        : Timestamp
```

**Catatan penting:**
- Collection ini di-update SETIAP kali teknisi save profile edit
- `rating` dan `totalRatings` di-update otomatis oleh `submitReview()`
- `merge: true` selalu dipakai agar rating tidak tertimpa

**Data yang dikumpulkan dari customer saat searching:**
- Koordinat GPS customer (untuk kalkulasi jarak) — TIDAK disimpan ke Firestore

---

### 5.3 Collection: `bookings`

Dokumen ID = auto-generated Firestore ID

```
bookings/{bookingId}
├── bookingId        : String       — sama dengan document ID
├── userId           : String       — UID customer
├── userName         : String       — nama customer (snapshot, bukan realtime)
├── technicianId     : String       — UID teknisi
├── technicianName   : String       — nama teknisi (snapshot)
├── technicianPhotoUrl: String?     — foto teknisi (snapshot)
├── category         : String       — "electronic" | "vehicle"
├── description      : String       — keluhan dari customer (wajib diisi)
├── damageType       : String       — "screen"|"battery"|"hardware"|
│                                    "water"|"camera"|"other"
├── scheduledAt      : Timestamp    — tanggal & jam slot yang dipilih
├── paymentMethod    : String       — "cash"|"gopay"|"qris"|"bank_transfer"
├── estimatedPrice   : int          — Rupiah, 0 = diskusi di lokasi
├── userAddress      : String       — alamat servis customer
├── latitude         : double?      — GPS customer (opsional)
├── longitude        : double?      — GPS customer (opsional)
├── status           : String       — "pending"|"confirmed"|
│                                    "on_progress"|"done"|"cancelled"
├── verificationCode : String?      — 6 digit (null saat pending)
├── codeExpiryAt     : Timestamp?   — kode expired setelah 2 jam
├── codeVerifiedAt   : Timestamp?   — kapan kode berhasil diverifikasi
├── customerRating   : int?         — 1–5 bintang (null = belum review)
├── customerReview   : String?      — teks ulasan customer
├── createdAt        : Timestamp
└── updatedAt        : Timestamp
```

**Lifecycle field berdasarkan status:**

| Status | Field yang berubah |
|--------|-------------------|
| `pending` | createdAt, updatedAt (semua field terisi kecuali kode) |
| `confirmed` | status, verificationCode, codeExpiryAt, updatedAt |
| `on_progress` | status, codeVerifiedAt, updatedAt |
| `done` | status, updatedAt |
| `cancelled` | status, updatedAt |
| Setelah rating | customerRating, customerReview, updatedAt |

---

### 5.4 Collection: `chats`

Dokumen ID = **bookingId** (1 booking = 1 chat room, konvensi ini JANGAN diubah)

```
chats/{chatId}                      ← chatId = bookingId
├── bookingId        : String
├── participants     : List<String>  — [customerId, technicianId]
├── customerName     : String
├── technicianName   : String
├── customerPhotoUrl : String?
├── technicianPhotoUrl: String?
├── lastMessage      : String        — preview pesan terakhir
├── lastMessageAt    : Timestamp
├── lastSenderId     : String
└── createdAt        : Timestamp

chats/{chatId}/messages/{messageId}  ← subcollection
├── senderId         : String        — UID pengirim
├── senderName       : String
├── text             : String        — isi pesan
├── isRead           : bool          — false = belum dibaca
└── createdAt        : Timestamp
```

**Catatan:**
- `ensureChatExists()` dipanggil sebelum membuka ChatPage
- `sendMessage()` menggunakan `batch.set(..., SetOptions(merge: true))` — aman meskipun parent doc belum ada
- `markAsRead()` memfilter senderId client-side untuk menghindari composite index tambahan

---

### 5.5 Data yang Dikumpulkan Per Fitur

| Fitur | Data yang Dikumpulkan |
|---|---|
| Register Customer | email, password, name, role |
| Register Teknisi | email, password, name, role + technicianProfile kosong |
| Google Sign-In | email, displayName, photoUrl (dari Google), role |
| Edit Profile Customer | name, phone |
| Edit Profile Teknisi | name, specialty, category, bio, yearsExperience, serviceRadius, workshopAddress, location (lat/lng), accreditations, serviceEstimates |
| Buat Booking | userId, userName, technicianId, technicianName, category, description, damageType, scheduledAt, paymentMethod, estimatedPrice, userAddress, latitude?, longitude? |
| Accept Order (Teknisi) | verificationCode (6 digit), codeExpiryAt (+2 jam) |
| Verifikasi Kode | codeVerifiedAt, status → on_progress |
| Selesaikan Order | status → done |
| Submit Review | customerRating (1-5), customerReview (teks), recalculate technician avg rating |
| Kirim Chat | senderId, senderName, text, createdAt, isRead=false |

---

## 6. Security Rules

Rules Firebase Firestore yang sudah dikonfigurasi:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // users — hanya bisa baca/ubah data sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // technicians_online — semua user login bisa baca, hanya owner yang bisa write
    match /technicians_online/{techId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == techId;
    }

    // bookings — owner (customer atau teknisi) bisa baca
    // booking yang sudah dirating bisa dibaca publik (untuk tampil di review list)
    match /bookings/{bookingId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.technicianId == request.auth.uid ||
        resource.data.customerRating != null
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.technicianId == request.auth.uid
      );
    }

    // chats — hanya participant yang bisa baca/tulis
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;

      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

---

## 7. Composite Indexes

Index yang WAJIB sudah dibuat di Firebase Console:

| Collection | Fields | Order |
|---|---|---|
| `bookings` | `userId` ASC, `status` ASC, `createdAt` DESC | Untuk stream active booking customer |
| `bookings` | `userId` ASC, `createdAt` DESC | Untuk stream riwayat booking |
| `bookings` | `technicianId` ASC, `status` ASC, `createdAt` DESC | Untuk stream order masuk teknisi |
| `bookings` | `technicianId` ASC, `status` ASC, `updatedAt` DESC | Untuk fetch reviews teknisi |
| `chats/{chatId}/messages` | `createdAt` ASC | Untuk stream pesan chat |

---

## 8. Semua Routes

| Route Constant | Path | Page | Controller |
|---|---|---|---|
| `AppRoutes.login` | `/login` | `LoginPage` | — |
| `AppRoutes.register` | `/register` | `RegisterPage` | — |
| `AppRoutes.signup` | `/signup` | `SignupPage` | — |
| `AppRoutes.home` | `/home` | `HomePage` | `HomeController`, `ProfileController` |
| `AppRoutes.profile_page` | `/profile` | `ProfilePage` | `ProfileController` |
| `AppRoutes.profileEdit` | `/profile/edit` | `ProfileEditPage` | `ProfileController` |
| `AppRoutes.technicianList` | `/customer/technician-list` | `TechnicianListPage` | — (stateful widget) |
| `AppRoutes.technicianDetail` | `/customer/technician-detail` | `BookingTechnicianDetailPage` | `BookingController` (DELETE+PUT baru) |
| `AppRoutes.createOrder` | `/customer/create-order` | `BookingFormPage` | `BookingController` (reuse) |
| `AppRoutes.checkout` | `/customer/checkout` | `CheckoutPage` | `BookingController` (reuse) |
| `AppRoutes.orderTracking` | `/customer/order-tracking` | `BookingTrackingPage` | `BookingController` (reuse) |
| `AppRoutes.orderHistory` | `/customer/order-history` | `BookingHistoryPage` | `BookingController` (reuse) |
| `AppRoutes.review` | `/review` | `ReviewPage` | — |
| `AppRoutes.chat` | `/chat` | `ChatPage` | `ChatController` (DELETE+PUT baru) |
| `AppRoutes.technicianHome` | `/technician/home` | `TechnicianHomePage` | `TechnicianController` (fenix) |
| `AppRoutes.technicianProfile` | `/technician/profile` | `TechnicianProfilePage` | `TechnicianController` (fenix) |
| `AppRoutes.technicianProfileEdit` | `/technician/profile/edit` | `TechnicianProfileEditPage` | `TechnicianController` (fenix) |
| `AppRoutes.jobDetail` | `/technician/job-detail` | `JobDetailPage` | `TechnicianController` (fenix) |
| `AppRoutes.verification` | `/technician/verification` | `VerificationPage` | `TechnicianController` (fenix) |
| `AppRoutes.activeJob` | `/technician/active-job` | `ActiveJobPage` | `TechnicianController` (fenix) |
| `AppRoutes.jobSummary` | `/technician/job-summary` | `JobSummaryPage` | `TechnicianController` (fenix) |
| `AppRoutes.mapboxLocationPicker` | `/mapbox-location-picker` | `MapboxLocationPickerPage` | — |

---

## 9. Arsitektur Controller

### BookingController (customer)

- Diinstansiasi **BARU** di `technicianDetail` route: `Get.delete<BookingController>(force: true)` lalu `Get.put(BookingController())`
- Route selanjutnya (`createOrder`, `checkout`, `orderTracking`, `orderHistory`) **reuse** controller yang sama: `if (!Get.isRegistered<BookingController>()) Get.put(BookingController())`
- JANGAN put/lazyPut BookingController di route mana pun selain `technicianDetail`
- Controller menerima `TechnicianOnlineModel` dari `Get.arguments` di `onInit()`
- Stream `activeBooking` mendengarkan status booking real-time dan auto-navigate ke ReviewPage

### TechnicianController

- Menggunakan `fenix: true` — controller TIDAK dihapus saat halaman di-pop
- 1 instance shared di semua halaman teknisi
- `selectedOrder` = booking yang sedang dibuka di job detail / verification
- `activeOrder` = booking dengan status confirmed/on_progress (yang sedang dikerjakan)
- Setelah `completeJob()`, return `BookingDocument` untuk dikirim ke `jobSummary` via `Get.arguments`

### ChatController

- Diinstansiasi **BARU** setiap kali ChatPage dibuka: `Get.delete<ChatController>(force: true)`
- Membaca args: `chatId`, `otherPartyName`, `otherPartyPhotoUrl`, `bookingDoc`
- Stream pesan dari `chats/{chatId}/messages`

---

## 10. Fitur yang Sudah Ada

| No | Fitur | Halaman |
|---|---|---|
| 1 | Auth: Register + Login email/password | `login_page`, `register_page`, `signup_page` |
| 2 | Auth: Google Sign-In | `login_page` |
| 3 | Role-based routing (customer vs technician) | `main.dart` / auth guard |
| 4 | Home page: geo-nearby technicians (radius 10km) | `home_page` |
| 5 | Home page: 6 kategori layanan (grid 2×3) | `home_page` |
| 6 | Technician list: search real-time + filter kategori + filter rating | `technician_list_page` |
| 7 | Technician detail page: info lengkap + reviews dari Firestore | `booking_technician_detail_page` |
| 8 | Booking form: damage type, deskripsi, alamat, GPS | `booking_form_page` |
| 9 | Booking form: slot jadwal 2 jam (08-17), cek konflik teknisi | `booking_form_page` |
| 10 | Checkout page | `checkout_page` |
| 11 | Order tracking real-time: 5 step tracker | `booking_tracking_page` |
| 12 | Kode verifikasi 6 digit (generate saat accept, expiry 2 jam) | `verification_page` |
| 13 | Chat real-time customer ↔ teknisi | `chat_page`, `chat_controller` |
| 14 | Rating & review (1-5 bintang + teks + quick tags) | `review_page` |
| 15 | Auto-navigate ke review page saat order selesai | `booking_controller.dart` stream listener |
| 16 | Recalculate avg rating teknisi setelah review | `booking_service.dart` `submitReview()` |
| 17 | Booking history customer | `booking_history_page` |
| 18 | Review banner di tracking page (jika belum rating) | `booking_tracking_page` |
| 19 | Edit profile customer (nama, HP) | `profile_edit_page` |
| 20 | Edit profile teknisi (lengkap + Mapbox location picker) | `technician_profile_edit_page` |
| 21 | Job summary page (data real dari BookingDocument) | `job_summary_page` |
| 22 | Teknisi accept/decline order | `job_detail_page` |
| 23 | Active job page dengan tombol selesai | `active_job_page` |

---

## 11. Fitur yang Belum Ada (Pending)

Urutan prioritas pengerjaan yang disarankan:

| Prioritas | Fitur | Catatan |
|---|---|---|
| 1 | **Photo Upload** | Firebase Storage belum dikonfigurasi. Dibutuhkan di: booking form (foto kerusakan), profile foto teknisi. Gunakan `firebase_storage` + `image_picker` |
| 2 | **Payment Integration** | `PaymentMethod` enum sudah ada (cash, gopay, qris, bank_transfer) tapi checkout hanya handle cash. Perlu Midtrans SDK atau deep link ke e-wallet |
| 3 | **Push Notifications (FCM)** | Teknisi perlu notif saat ada order masuk. Customer perlu notif saat teknisi accept. Gunakan `firebase_messaging` |
| 4 | **Cancellation Flow** | Customer belum bisa cancel booking dari sisi UI. `cancelBooking()` sudah ada di `booking_service.dart` tapi belum ada tombol di tracking page |
| 5 | **Real-time GPS Tracking** | Tampilkan posisi teknisi di peta saat status confirmed/on_progress. Perlu update lokasi teknisi periodik ke Firestore |
| 6 | **Technician Earnings History** | Teknisi belum bisa lihat riwayat pekerjaan + total penghasilan |
| 7 | **Admin Panel** | Verifikasi teknisi, monitoring booking, manajemen user |

---

## 12. Aturan Penting (Do & Don't)

### AMAN dilakukan:
- Tambah/ubah UI widget di halaman manapun
- Tambah field baru ke Firestore (backward compatible karena `as String? ?? ''`)
- Tambah route baru di `routes.dart`
- Ubah label/teks/warna

### JANGAN lakukan tanpa memahami dulu:
- ❌ **Jangan ubah nama field Firestore** (`userId`, `technicianId`, `status`, `scheduledAt`, dll) — akan break semua query
- ❌ **Jangan ubah nilai string `BookingStatus.*`** (`"pending"`, `"confirmed"`, `"on_progress"`, `"done"`) — data di Firestore pakai string ini
- ❌ **Jangan ubah konvensi chatId = bookingId** — seluruh sistem chat bergantung pada ini
- ❌ **Jangan `Get.put(BookingController())` di route selain `technicianDetail`** — akan reset state booking yang sedang berjalan
- ❌ **Jangan hapus `fenix: true` dari TechnicianController** — controller akan mati saat pop halaman
- ❌ **Jangan tambah index baru Firestore tanpa cek existing index** — bisa duplikat atau conflict
- ❌ **Jangan ubah `merge: true` di `updateTechnicianProfile()`** — akan menghapus field `rating` dan `totalJobs`

### Urutan aman untuk menambah fitur:
1. Baca file yang akan diubah dulu
2. Pahami data flow dari Firestore sampai UI
3. Tambahkan field baru di model (jika perlu)
4. Update Security Rules jika akses berubah
5. Test di emulator/device sebelum push

---

## 13. Setup Environment

### Prasyarat
- Flutter SDK (channel stable)
- Firebase project sudah ada (lihat `google-services.json`)
- Mapbox account + API key

### File konfigurasi
- `android/app/google-services.json` — Firebase Android config
- `ios/Runner/GoogleService-Info.plist` — Firebase iOS config
- `lib/config/mapbox_config.dart` — Mapbox API key

### Install dependencies
```bash
flutter pub get
```

### Jalankan aplikasi
```bash
flutter run
```

### Branch convention
- `main` — production/stable
- `sulthan` — branch aktif (current working branch)
- Buat branch baru per fitur: `feature/photo-upload`, `feature/push-notif`, dll
- Commit convention: `feat:`, `fix:`, `refactor:`, `chore:`

---

*Dokumen ini harus diupdate setiap kali ada fitur baru yang selesai.*
