# Event Planner — Flutter

A cross-platform mobile app for creating and managing personal events, with user accounts and offline storage in a local **SQLite** database. Built for the *Mobile Programming* course at Konya Technical University.

## Features

- **User accounts:** register, log in, update username and password, log out
- **Per-user events:** each user only sees their own events
- **Create events** with a title, description, image (from a URL, with live preview), date and location
- **Event list** on the home screen, persisted across app restarts
- **Event detail page** opened with a **Hero animation** from the list image
- **Delete events** with a confirmation dialog

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart 3), Material 3 |
| Storage | SQLite via `sqflite` (singleton `DatabaseHelper`, parameterized queries) |
| Other packages | `path`, `intl` |

## Database Schema

```text
users  (id, username, password)
events (id, userId, title, content, imagePath, eventDate, location)
```

## Getting Started

```bash
git clone https://github.com/ardactin/flutter-event-planner.git
cd flutter-event-planner
flutter pub get
flutter run
```

Run the tests with `flutter test`.

## Project Structure

```text
lib/main.dart        # App, DatabaseHelper and all screens
test/widget_test.dart
android/ ios/ web/ windows/ linux/ macos/   # Platform runners
```

## Known Limitations & Next Steps

- **Location picker is simulated:** the map dialog fills in sample coordinates; integrating `google_maps_flutter` is the next step.
- **Passwords are stored in plain text** in the local database; they should be hashed (e.g. with `crypto`) before any real use.
- All screens live in `main.dart`; splitting them into `screens/`, `models/` and `data/` folders would improve maintainability.
