# FitPilot

A polished Flutter web fitness dashboard with responsive navigation, workout planning, progress metrics, hydration controls, and nutrition panels.

## Run

```sh
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

## Structure

```text
lib/
  main.dart
  front/
    front.dart
    modules/
      user/
        home/
          home_module.dart
          presentation/
            pages/
            widgets/
      admin/
        dashboard/
          presentation/
            pages/
  backend/
    backend.dart
    modules/
```

## Verify

```sh
flutter analyze
flutter test
flutter build web
```
