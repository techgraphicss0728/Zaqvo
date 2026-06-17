# Zaqvo Delivery App

Flutter app for delivery partners (Android & iOS). Consumes Zaqvo Backend API.

## Setup

```bash
flutter pub get
# Optional: copy .env.example to .env and set API_BASE_URL (defaults to http://localhost:8000/api/v1)
cp .env.example .env
```

To ship a custom base URL in release, add `.env` under `flutter:` `assets:` in `pubspec.yaml` and keep a `.env` file in the project root for builds.

## Run

- Debug: `flutter run`
- Build APK: `flutter build apk`
- Build iOS: `flutter build ios`

## Structure

- `lib/core/` — config, theme, API client
- `lib/features/` — auth, deliveries, profile
- `lib/shared/` — widgets, models
