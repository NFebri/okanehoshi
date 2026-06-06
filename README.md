# E-Wallet

Aplikasi mobile e-wallet berbasis **Flutter** dengan state management **BLoC** dan **Clean Architecture**. Proyek ini merupakan studi kasus klien mobile yang terhubung ke [Backend E-Wallet API (Laravel 13 & React 19)](https://github.com/NFebri/e-wallet).

---

## 🏛️ Desain Arsitektur & Struktur Direktori

Aplikasi ini menggunakan perpaduan **Clean Architecture** dan **Feature-First Structure** untuk mempermudah skalabilitas proyek dan kolaborasi tim:

```
lib/
├── main.dart                          # Entry point aplikasi
├── app.dart                           # Setup GoRouter & Global BlocProviders
├── core/                              # === INFRASTRUKTUR BERSAMA (SHARED) ===
│   ├── constants/                     # Konfigurasi API & aplikasi
│   ├── network/                       # Dio Client, Interceptors, Exceptions, & Retry
│   ├── router/                        # GoRouter declarative routing
│   ├── theme/                         # Styling & Color palette modern fintech
│   └── widgets/                       # Reusable UI premium components (AppButton, AppTextField, dll)
└── features/                          # === MODUL FITUR UTAMA ===
    ├── auth/                          # Pendaftaran, login, & kelola token
    ├── dashboard/                     # Tampilan utama & ringkasan saldo
    ├── topup/                         # Transaksi isi saldo
    ├── transfer/                      # Transaksi kirim saldo ke pengguna lain
    └── transaction/                   # Riwayat transaksi lengkap paginated
```

### Stack Teknologi Utama:
*   **State Management**: `flutter_bloc`
*   **HTTP Client**: `dio` (ditambah dengan kustomisasi interceptors)
*   **Penyimpanan Lokal**: `flutter_secure_storage` (terenkripsi)
*   **Navigasi**: `go_router` (declarative navigation)

---

## 🛠️ Langkah Instalasi & Penggunaan

### 1. Prasyarat
Pastikan Anda sudah menginstal:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi `>=3.12.1`)
*   [Android SDK](https://developer.android.com/studio) (untuk emulator/device Android)
*   Layanan REST API Laravel yang berjalan di localhost / VPS.

### 2. Kloning & Mengunduh Dependency
Jalankan perintah berikut di terminal Anda:
```bash
git clone https://github.com/NFebri/okanehoshi.git
cd okanehoshi
flutter pub get
```

### 3. Konfigurasi Endpoint API
Buka berkas `lib/core/constants/api_constants.dart` dan sesuaikan IP backend API Anda:
```dart
class ApiConstants {
  // Gunakan 'http://10.0.2.2:8000/api' jika menggunakan emulator Android resmi bawaan SDK
  static const String baseUrl = 'http://10.0.2.2:8000/api';
}
```

### 4. Menjalankan Aplikasi
Hubungkan emulator atau perangkat fisik Anda, lalu jalankan:
```bash
flutter run
```
