# Zaqvo Delivery App

Flutter app for delivery partners (Android & iOS). Consumes Zaqvo Backend API.

## Setup

```bash
flutter pub get
cp .env.example .env   # Set API_BASE_URL
```

## Run

- Debug: `flutter run`
- Build APK: `flutter build apk`
- Build iOS: `flutter build ios`

## Structure

- `lib/core/` — config, theme, API client
- `lib/features/` — auth, deliveries, profile
- `lib/shared/` — widgets, models
