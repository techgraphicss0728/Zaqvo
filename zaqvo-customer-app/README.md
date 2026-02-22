# Zaqvo Customer App

Flutter app for customers (Android & iOS). Consumes Zaqvo Backend API.

## Setup

```bash
flutter pub get
cp .env.example .env   # Set API_BASE_URL
```

## Run

- Debug: `flutter run`
- Release: `flutter run --release`
- Build APK: `flutter build apk`
- Build iOS: `flutter build ios`

## Structure

- `lib/core/` — config, theme, constants, API client
- `lib/features/` — auth, home, orders, profile
- `lib/shared/` — widgets, models, services
