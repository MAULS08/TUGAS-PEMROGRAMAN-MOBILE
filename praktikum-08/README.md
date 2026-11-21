# Praktikum Flutter - Model User dan Admin

## Identitas dan ID NIM
NIM yang digunakan: **20240801195**  
Tiga digit terakhir: **195**. Mengikuti pola perhitungan ID pada contoh soal (penjumlahan memakai tiga digit asli):
- ID User untuk POST = 1499 + 195 = **1694**
- ID Admin = 792 + 195 = **987**

> Catatan: instruksi soal menyebut angka tengah digeser ke belakang dan memberi N=354 untuk akhiran 345, tetapi contoh perhitungan ID tetap memakai 345. Implementasi ini mengikuti contoh perhitungan ID. Jika dosen meminta rumus memakai N hasil pergeseran (159), ubah ID Admin menjadi 951 dan sesuaikan konstanta ID User sesuai arahan dosen.

## Struktur file utama

```text
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   └── admin.dart
└── services/
    ├── user_service.dart
    ├── admin_service.dart
    └── api_service.dart
```

`api_service.dart` dipertahankan sebagai alias kompatibilitas untuk praktikum sebelumnya. Implementasi CRUD User berada di `user_service.dart`.

## Implementasi

### Model
- `User` memiliki `id`, `name`, `email`, dan `city`. Kota dibaca dari `address.city` pada JSONPlaceholder.
- `Admin` memiliki `id`, `name`, `email`, dan `department`, serta factory `Admin.fromJson()`.

### Service User
- `getUsers()` mengambil daftar User.
- `getUser(id)` mengambil detail User.
- `createUser(name, email)` menambahkan User dengan ID 1694.
- `updateUser(id, name, email)` memperbarui nama dan email (PUT).
- `patchUser(id, name)` memperbarui nama (PATCH); tombol pada tampilan menambahkan teks ` - Flutter Developer`.
- `deleteUser(id)` menghapus User.

Data User disimpan secara lokal pada file JSON di perangkat atau SharedPreferences pada web, mengikuti implementasi praktikum sebelumnya.

### Service Admin
- `getAdmins()` mengambil data awal dari endpoint JSONPlaceholder `/users`, mengonversinya menjadi Admin, dan menyimpan salinan lokal.
- `getAdmin(id)` mencari satu Admin berdasarkan ID.
- `deleteAdmin(id)` menghapus Admin dari penyimpanan lokal.
- Satu data Admin dengan ID 987 disediakan untuk pengujian ID berdasarkan NIM.

**Catatan API:** JSONPlaceholder adalah API simulasi. Perubahan POST/PUT/PATCH/DELETE di server JSONPlaceholder tidak disimpan permanen. Karena itu operasi User pada project ini menggunakan penyimpanan lokal seperti praktikum sebelumnya, sedangkan data Admin disimpan di SharedPreferences agar penghapusan tetap terlihat setelah aplikasi dimuat ulang.

## Tampilan aplikasi
Aplikasi memiliki dua tab:
1. **User**: daftar User, detail, tambah (POST), ubah (PUT), ubah nama (PATCH), dan hapus (DELETE).
2. **Admin**: daftar Admin, detail Admin berdasarkan ID, dan hapus Admin.

## Cara menjalankan
1. Ekstrak ZIP project.
2. Buka folder project `api` di VS Code atau Android Studio.
3. Jalankan `flutter pub get`.
4. Jalankan aplikasi dengan `flutter run`.
5. Pastikan perangkat/emulator atau browser memiliki koneksi internet untuk pengambilan data awal dari JSONPlaceholder. Jika tidak tersedia, data fallback digunakan.

## Skenario pengujian dan screenshot
Ambil screenshot langsung dari aplikasi setelah dijalankan. Screenshot tidak dibuat-buat dan perlu disesuaikan dengan hasil aktual pada perangkat.

| No. | Pengujian | Langkah | Hasil yang diharapkan |
|---|---|---|---|
| 1 | GET User | Buka tab User | Daftar User tampil |
| 2 | POST User | Tekan ikon tambah, isi nama dan email | User baru dengan ID 1694 tampil |
| 3 | Detail User | Tekan Detail pada salah satu User | ID, nama, email, dan kota tampil |
| 4 | PUT User | Tekan PUT, ubah nama/email, simpan | Nama dan email berubah |
| 5 | PATCH User | Tekan PATCH | Nama ditambah ` - Flutter Developer` |
| 6 | DELETE User | Tekan ikon hapus dan konfirmasi | User hilang dari daftar |
| 7 | GET Admin | Buka tab Admin | Daftar Admin tampil, termasuk ID 987 |
| 8 | Detail Admin | Pilih Admin lalu Lihat detail | ID, nama, email, department tampil |
| 9 | DELETE Admin | Pilih Hapus Admin lalu konfirmasi | Admin hilang dari daftar dan tetap terhapus setelah refresh |

## Penjelasan hasil praktikum (laporan singkat)
Pada praktikum ini, aplikasi Flutter dikembangkan dengan memisahkan Model dan Service untuk data User dan Admin. Model User digunakan untuk mengubah JSON menjadi objek yang memiliki atribut id, name, email, dan city. Model Admin dibuat pada file `admin.dart` dengan atribut id, name, email, dan department serta fungsi `Admin.fromJson()`.

Pengambilan data dilakukan melalui method GET pada masing-masing service. `UserService` menyediakan operasi GET, POST, PUT, PATCH, dan DELETE. Penambahan User menggunakan ID 1694 sesuai perhitungan NIM. PUT digunakan untuk memperbarui nama dan email, sedangkan PATCH digunakan untuk menambahkan teks ` - Flutter Developer` pada nama User. DELETE menghapus User berdasarkan ID.

Untuk Admin, `AdminService` menyediakan method `getAdmins()`, `getAdmin(id)`, dan `deleteAdmin(id)`. Tampilan aplikasi dibuat menjadi dua tab, yaitu User dan Admin. Pengguna dapat melihat daftar dan detail data, melakukan pengelolaan CRUD User, serta menghapus Admin berdasarkan ID. Pengujian dilakukan melalui setiap tombol pada aplikasi sesuai tabel skenario pengujian di atas.

Hasil akhir yang diharapkan adalah daftar User dan Admin dapat ditampilkan, detail dapat dibuka berdasarkan ID, perubahan User dapat terlihat pada daftar, dan data Admin yang dihapus tidak muncul kembali setelah aplikasi dimuat ulang. Lampirkan screenshot aktual untuk daftar User, daftar Admin, detail, serta hasil POST/PUT/PATCH/DELETE pada laporan pengumpulan.
