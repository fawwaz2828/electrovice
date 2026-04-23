<p align="center">
  <img src="assets/images/ELECTROVICE_LOGO_HD.png" alt="ElectroVice Logo" width="260"/>
</p>

<p align="center">On-Demand Electronics Repair Booking Platform</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-3.0.0--beta-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/platform-Android-green?style=flat-square&logo=android"/>
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter"/>
  <img src="https://img.shields.io/badge/Firebase-enabled-yellow?style=flat-square&logo=firebase"/>
  <img src="https://img.shields.io/badge/status-beta-red?style=flat-square"/>
</p>

---

<p align="center">
  <img src="https://github.com/user-attachments/assets/96e43433-7d41-497a-89f4-50828eaaafce" width="55%" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/e0a05edd-c8d9-4041-9167-fd46e782b86c" width="26%" />
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/c0a96d19-86ca-4a74-b8c0-1d157d9b517d" width="26%" />
</p>

---

## About

**ElectroVice** is a mobile application that connects customers with verified electronics repair technicians. Customers can browse nearby technicians, book a repair session, track the technician in real-time, and complete payment — all in one app.

> ⚠️ This app is currently in **beta**. Payment gateway integration and some features are still under active development.

---

## Download

<p>
  <a href="https://drive.google.com/file/d/1zm-E2LG7FZbFuc2shs6mZhUYXUN0l5u5/view?usp=drive_link">
    <img src="https://img.shields.io/badge/Download%20APK-v3.0.0--beta-black?style=for-the-badge&logo=android"/>
  </a>
</p>

---

## Key Features

- **Browse Nearby Technicians** — Find verified repair technicians based on your location
- **Multi-Category Repair** — Smartphone, Laptop, Appliance, AC & Cooling, TV & Display, Vehicle
- **Real-Time Order Tracking** — Track technician location live via map during service
- **6-Digit Verification Code** — Secure service start confirmation between customer and technician
- **In-App Chat** — Communicate directly with technicians before and during booking
- **Repair Cost Estimation** — Transparent pricing with itemized parts and service fees
- **Push Notifications** — Stay updated on every booking status change
- **Rating & Review** — Leave feedback after each completed repair
- **Force Update** — Automatic version check on launch to keep all users up to date

---

## 🧰 Technology Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Mapbox](https://img.shields.io/badge/Mapbox-000000?style=for-the-badge&logo=mapbox&logoColor=white)

**Frontend**
- **Flutter**: Cross-platform UI toolkit for building natively compiled Android applications
- **GetX**: State management, dependency injection, and routing
- **Mapbox**: Interactive maps for real-time technician location tracking

**Backend & Services**
- **Firebase Firestore**: Real-time NoSQL database for bookings, chats, and user data
- **Firebase Auth**: Secure user authentication
- **Firebase Cloud Messaging**: Push notifications for order status updates
- **Firebase Storage**: Cloud storage for profile photos and repair documentation

---

## Project Structure

```
lib/
├── config/          # Routes & app configuration
├── models/          # Data models
├── modules/         # Feature modules (auth, booking, chat, etc.)
├── services/        # Firebase & API services
└── widget/          # Shared UI components
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Firebase project with `google-services.json` configured
- Mapbox access token

### Run Locally

```bash
# Clone repository
git clone https://github.com/your-username/electrovice.git
cd electrovice

# Install dependencies
flutter pub get

# Run app
flutter run
```

> Make sure to add your own `google-services.json` (Android) and set your Mapbox token before running.

---

## User Roles

| Role | Description |
|---|---|
| **Customer** | Browse technicians, place bookings, track repairs, pay & review |
| **Technician** | Receive orders, verify arrival, submit repair cost, complete job |
| **Admin** | Manage technician verification and platform oversight |

---

## 👨‍💻 Contributors

This project was developed by **LaBuLaDa** for a private client:

- **Sulthan Syafiq Raihan** — Hustler (Project Lead & Firebase Integration)
- **Fawwaz Akbar Wibowo** — Hipster (Frontend Developer, UI/UX Designer & QA Tester)
- **Syahrun Nasai Ichwan** — Hacker (Frontend Developer & Idea Originator)

**Client:** Maziza Kamalia

---

## License

&copy; 2025 LaBuLaDa. All Rights Reserved.

This project is proprietary and built for a private client. Unauthorized use, distribution, or modification is not permitted.
