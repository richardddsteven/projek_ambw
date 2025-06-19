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
   - Go to your project: https://hjhwpeokoztuaifxgfky.supabase.co
   - If you're setting up for the first time, run the SQL commands found in `supabase_schema.sql`
   - If you encounter "relation already exists" errors, use `update_supabase.sql` instead
   - If you get "violates row-level security policy" errors, run `fix_rls_policies.sql` to fix the RLS settings
   - You can check your table structure with `check_tables.sql` to diagnose any issues
   - Make sure the test user with ID 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1' exists in the users table

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

This version uses a default user ID. In a production app, you would implement:
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
