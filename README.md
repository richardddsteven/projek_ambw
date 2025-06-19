# Medical Booking App

A Flutter mobile application for booking medical appointments with doctors across various specialties. The app uses Supabase for backend services and database.

## Features

- View list of doctors by specialty
- Doctor profiles with details and ratings
- Book appointments with date and time selection
- View upcoming and past appointments
- Cancel scheduled appointments

## Screenshots

The app is designed with a clean and modern UI similar to the shared design mockup.

## Setup Instructions

### Prerequisites

- Flutter SDK (version ^3.7.0)
- Supabase account
- VS Code or Android Studio

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Set up Supabase:
   - Log in to your Supabase account at https://app.supabase.io
   - Go to your project: https://hjhwpeokoztuaifxgfky.supabase.co   - If you're setting up for the first time, run the SQL commands found in `supabase_schema.sql`
   - If you encounter "relation already exists" errors, use `update_supabase.sql` instead  
   - **PENTING**: Untuk memperbaiki semua masalah termasuk RLS dan autentikasi, jalankan SQL dari file `fix_all_issues.sql` di SQL Editor Supabase
   - File ini akan:
     - Mengatur RLS policy untuk tabel users dan appointments
     - Membuat trigger untuk otomatis menambahkan user ke tabel public.users saat registrasi
     - Menyinkronkan data pengguna yang sudah ada
   - You can check your table structure with `check_tables.sql` to diagnose any issues
   
### Troubleshooting RLS & Auth Issues

Jika Anda mengalami masalah seperti:
- "PostgresException(message: new row violates row-level security policy for table "users", code: 42501)" saat registrasi
- "AuthApiException(message: Invalid login credentials, statusCode: 400)" saat login
- Masalah konfirmasi email yang tidak bisa diakses (link localhost di email)

Ikuti langkah-langkah ini:

1. Sign in ke Supabase Dashboard
2. Buka SQL Editor
3. Jalankan script `fix_all_issues.sql` yang memperbaiki:
   - Kebijakan RLS untuk tabel users dan appointments
   - Menambahkan trigger database untuk membuat profil user otomatis
   - Menyinkronkan data pengguna yang sudah ada
4. Jika mengalami masalah dengan konfirmasi email, jalankan script `fix_email_confirmation.sql` yang:
   - Menonaktifkan kebutuhan konfirmasi email
   - Otomatis mengkonfirmasi semua email yang sudah terdaftar
   - Memperbaiki kebijakan RLS untuk akses data
5. Coba register dengan email baru
6. Jika masih ada masalah, pastikan tidak ada konflik kebijakan RLS dengan:
   - Buka Authentication > Policies di Supabase
   - Pastikan tabel users memiliki policy untuk INSERT, SELECT, UPDATE dengan kondisi auth.uid() = id

### Database Schema

The application uses the following tables:

#### Users
- `id`: UUID (primary key)
- `name`: VARCHAR (user's full name)
- `email`: VARCHAR (unique)
- `photo_url`: VARCHAR (optional profile picture URL)
- `created_at`: TIMESTAMP
- `updated_at`: TIMESTAMP

#### Doctors
- `id`: UUID (primary key)
- `name`: VARCHAR (doctor's full name)
- `specialty`: VARCHAR (area of medical specialty)
- `photo_url`: VARCHAR (profile picture URL)
- `experience`: INTEGER (years of experience)
- `about`: TEXT (doctor's biography)
- `rating`: DECIMAL (doctor's rating out of 5)
- `created_at`: TIMESTAMP
- `updated_at`: TIMESTAMP

#### Appointments
- `id`: UUID (primary key)
- `user_id`: UUID (foreign key to users)
- `doctor_id`: UUID (foreign key to doctors)
- `appointment_date`: TIMESTAMP (scheduled date and time)
- `type`: VARCHAR (type of consultation)
- `notes`: TEXT (optional notes for the appointment)
- `status`: VARCHAR (scheduled, completed, or cancelled)
- `created_at`: TIMESTAMP
- `updated_at`: TIMESTAMP

### Running the App

1. Run the app using `flutter run`
2. The app uses dummy data by default if Supabase tables haven't been set up

## Authentication

The app now includes full authentication functionality:

- User registration with email, password, and name
- Login with email and password
- Automatic user profile creation in the `users` table
- Session management and persistence
- Logout functionality
- Profile management

### Authentication Troubleshooting

If you encounter issues with authentication:

1. Make sure you've run the `fix_all_issues.sql` script in Supabase SQL Editor
2. Check that the `users` table has the correct structure
3. Verify RLS policies are correctly set up
4. Refer to the detailed guide in `supabase_auth_guide.md`

For a more secure implementation in production, you would also add:
- Email verification
- Password reset functionality
- Social authentication (Google, Facebook, etc.)
- Refresh token handling
- User registration
- Email/password or social login
- Secure authentication with Supabase Auth

## Project Structure

```
lib/
  ├── models/           # Data models
  ├── screens/          # UI screens
  ├── services/         # API and backend services
  ├── utils/            # Utilities and helpers
  ├── widgets/          # Reusable UI components
  └── main.dart         # App entry point
```

## Future Enhancements

- User authentication and registration
- Doctor availability calendar
- Payment integration
- Notifications for appointment reminders
- Video consultation functionality
- Reviews and ratings system
