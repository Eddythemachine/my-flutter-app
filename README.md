# iNote

A Flutter app for secure note access and authentication, built with Firebase and a modern Material 3 interface. The project currently focuses on a polished authentication flow and an authenticated dashboard shell, with the foundation in place for note-oriented features.

## Overview

iNote is a Firebase-powered Flutter starter app that demonstrates:

- Email/password sign up and sign in
- Email verification flow
- Route-based navigation and auth gating
- Dark, responsive dashboard UI
- Clean separation between screens, services, and theme logic

This project is a strong foundation for a personal notes application or productivity app and is designed to be easy to extend.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Running the App](#running-the-app)
- [Current Status](#current-status)
- [Development](#development)
- [License](#license)

## Features

- Email and password registration
- Email and password sign-in
- Firebase email verification workflow
- Auth-aware navigation and protected routes
- Modern dark gradient UI with Material 3 styling
- Animated transitions between authentication and dashboard screens
- Reusable auth service layer for Firebase logic
- Notes dashboard scaffold ready for future note features

## Tech Stack

- Flutter
- Dart
- Firebase Core
- Firebase Authentication
- Firebase Analytics
- Cloud Firestore package (included for future persistence)
- Material 3 UI

## Project Structure

```text
flutter_application_1/
├── android/                 # Android-specific Firebase and app config
├── ios/                     # iOS app configuration
├── lib/
│   ├── main.dart            # App entry point and route configuration
│   ├── firebase_options.dart
│   ├── app.dart             # App composition entry (if used)
│   ├── notes/
│   │   └── note.dart        # Notes dashboard view and logout flow
│   ├── src/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   └── view/
│       ├── login_view.dart
│       ├── register_view.dart
│       └── verify_email_view.dart
├── analysis_options.yaml
├── firebase.json
├── pubspec.yaml
├── README.md
└── web/
```

## Prerequisites

Before running the project, make sure you have:

- Flutter SDK installed and configured
- A Firebase project created in the [Firebase Console](https://console.firebase.google.com/)
- Android, iOS, and/or Web Firebase config files generated for your app

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/Eddythemachine/my-flutter-app.git
cd my-flutter-app
```

2. Install dependencies:

```bash
flutter pub get
```

## Firebase Setup

Configure Firebase for the project:

```bash
flutterfire configure
```

This creates or updates the Firebase configuration used by the app, including `lib/firebase_options.dart`.

Then enable the required sign-in method in the Firebase Console:

1. Open your Firebase project
2. Go to Authentication
3. Select Sign-in method
4. Enable Email/Password

## Running the App

Start the app locally:

```bash
flutter run
```

If you want to test a specific platform:

```bash
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

## Current Status

This project is currently a functional auth starter with a dashboard shell. It includes:

- user registration
- login
- email verification prompt
- protected routes after sign-in
- dark theme and UI scaffolding

The app is ready for further extension into a full notes experience with CRUD, local storage, or Cloud Firestore integration.

## Development

Useful commands during development:

```bash
flutter analyze
flutter test
```

If you'd like to format the project before committing:

```bash
dart format .
```

## License

This project does not currently declare a license. If you plan to publish or share the app publicly, consider adding an open-source license such as MIT.
