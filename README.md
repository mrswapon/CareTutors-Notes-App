# CareTutors Notes App

A personal notes manager built with Flutter, Firebase, and Riverpod. Users can register, log in, and manage their private notes — stored in real time with Cloud Firestore.

---

## Screenshots

> _Add screenshots to an `assets/screenshots/` folder and update the paths below._

| Splash | Login | Register | Home | Add Note |
|--------|-------|----------|------|----------|
| ![Splash](assets/screenshots/splash.png) | ![Login](assets/screenshots/login.png) | ![Register](assets/screenshots/register.png) | ![Home](assets/screenshots/home.png) | ![Add Note](assets/screenshots/add_note.png) |

---

## Features

- **Splash Screen** — Branded animated entry screen shown on first launch
- **Authentication** — Email & password sign-up and login via Firebase Auth
- **My Notes** — Real-time list of all personal notes, newest first
- **Add Note** — Create notes with a title and multiline description
- **Delete Note** — Long-press any note card to delete with confirmation
- **Auto-redirect** — Already logged-in users skip straight to Home; logged-out users are blocked from protected routes
- **Persistent session** — Firebase Auth persists the user session across app restarts

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | Riverpod (`hooks_riverpod` + `flutter_hooks`) |
| Navigation | GoRouter |
| Backend | Firebase Authentication + Cloud Firestore |
| Local Storage | SharedPreferences |
| Fonts | Google Fonts — Poppins |
| Date Formatting | intl |

---

## Project Architecture

Clean Architecture with a feature-first folder structure:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Brand palette — primary: #FF4C00
│   │   └── app_strings.dart       # All UI text strings
│   ├── router/
│   │   └── app_router.dart        # GoRouter with auth-aware redirect
│   └── theme/
│       └── app_theme.dart         # Material 3 theme — Poppins, rounded UI
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart      # Firebase Auth + Firestore user save
│   │   ├── domain/
│   │   │   └── auth_provider.dart        # Riverpod providers & AuthController
│   │   └── presentation/
│   │       ├── login_page.dart
│   │       └── register_page.dart
│   ├── notes/
│   │   ├── data/
│   │   │   └── notes_repository.dart     # Firestore CRUD + real-time stream
│   │   ├── domain/
│   │   │   ├── note_model.dart           # NoteModel with fromFirestore / toMap
│   │   │   └── notes_provider.dart       # Riverpod providers & NotesController
│   │   └── presentation/
│   │       ├── home_page.dart
│   │       └── add_note_page.dart
│   └── splash/
│       └── presentation/
│           └── splash_page.dart
├── firebase_options.dart
└── main.dart
```

---

## State Management

| Provider | Type | Responsibility |
|---|---|---|
| `authRepositoryProvider` | `Provider` | Singleton `AuthRepository` instance |
| `authStateProvider` | `StreamProvider<User?>` | Watches Firebase auth state — `null` means signed out |
| `authControllerProvider` | `StateNotifierProvider` | Handles `signIn`, `register`, `signOut` with loading & error state |
| `notesRepositoryProvider` | `Provider` | Singleton `NotesRepository` instance |
| `notesProvider` | `StreamProvider<List<NoteModel>>` | Real-time Firestore stream for the current user's notes |
| `notesControllerProvider` | `StateNotifierProvider` | Handles `addNote` and `deleteNote` with loading & error state |

---

## Navigation Routes

| Route | Page | Auth required |
|---|---|---|
| `/splash` | `SplashPage` | No |
| `/login` | `LoginPage` | No |
| `/register` | `RegisterPage` | No |
| `/home` | `HomePage` | Yes — redirects to `/login` if signed out |
| `/add-note` | `AddNotePage` | Yes — redirects to `/login` if signed out |

---

## Firestore Data Model

**`users/{uid}`**
```
{
  name:      string,
  email:     string,
  createdAt: timestamp
}
```

**`notes/{noteId}`**
```
{
  title:       string,
  description: string,
  userId:      string,
  createdAt:   timestamp
}
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A Firebase project with **Email/Password** auth and **Cloud Firestore** enabled
- [Firebase CLI](https://firebase.google.com/docs/cli) and [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

### 1. Clone the repository

```bash
git clone https://github.com/mrswapon/CareTutors-Notes-App.git
cd CareTutors-Notes-App
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Connect Firebase

If `firebase_options.dart` is not present or you need to link your own project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates `lib/firebase_options.dart` with your project's credentials.

### 4. Set Firestore security rules

In the Firebase Console → **Firestore Database → Rules**, apply:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    match /notes/{noteId} {
      allow read, update, delete: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### 5. Run the app

```bash
flutter run
```

---

## Dependencies

```yaml
# Firebase
firebase_core: ^3.3.0
firebase_auth: ^5.1.4
cloud_firestore: ^5.2.1

# State Management
flutter_riverpod: ^2.5.1
hooks_riverpod: ^2.5.1
flutter_hooks: ^0.20.5

# Navigation
go_router: ^14.2.7

# Storage
shared_preferences: ^2.3.1

# UI & Utilities
google_fonts: ^6.2.1
intl: ^0.19.0
```

---

## Contributing

1. Fork the repository
2. Create a feature branch — `git checkout -b feat/your-feature`
3. Commit with conventional messages — `feat: add dark mode support`
4. Open a pull request

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

**Swapon** — [@mrswapon](https://github.com/mrswapon)
