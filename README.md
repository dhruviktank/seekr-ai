# Seekr AI 👻
Seekr AI is a modern, mobile application built with Flutter and Firebase. It features a deep-void aesthetic, real-time AI chat simulation, and secure user authentication.

## Features
Secure Authentication: Sign up and Log in powered by Firebase Auth and Firestore.

Persistent Profiles: User data (Full Name/Email) is retrieved from Firestore.

Chat History: A dedicated space to view past "Summonings" (Work in Progress).

Usage Limits: Built-in daily limit indicator (10/10) to manage AI energy.

State Management: Robust logic handling using the BLoC/Cubit pattern.

## Tech Stack
Frontend: Flutter

State Management: Flutter BLoC / Cubit

Backend: Firebase Authentication & Cloud Firestore

Language: Dart

## Application Flow
The application follows a linear security-first flow:

Splash/Wrapper: The AuthCubit checks if a user is already authenticated.

Authentication: * Login: Users enter credentials to enter the Void.

Register: New souls are added to the Firestore users collection.

Chat Dashboard (Main): The central hub for AI interaction.

History: Users can navigate here to see a log of past interactions (currently displays a "Void is Silent" empty state).

Profile Settings: Users can view their daily usage limits, toggle Spooky Mode, or "Leave the Void" (Logout).

## Installation & Setup
Prerequisites
Flutter SDK installed.

A Firebase project created in the Firebase Console.

Steps
Clone the repository:

Bash

git clone https://github.com/dhruviktank/seekr-ai.git
cd seekr_ai
Add Firebase Configuration:

Place your google-services.json in android/app/.

Place your GoogleService-Info.plist in ios/Runner/.

Install dependencies:

Bash

flutter pub get
Run the app:

Bash

flutter run
Release Build (APK)
To generate a signed release APK for Android:

Ensure your key.properties is configured in the android/ folder.

Run the build command:

Bash

flutter build apk --release
Locate the APK at build/app/outputs/flutter-apk/app-release.apk.

📝 Roadmap (Work in Progress)
[ ] Integration with different GenAI API for real-time responses.

[ ] Firestore Stream for Chat History synchronization.

[ ] Local caching for offline "Void" access.

[ ] Dynamic Spooky Mode theme switching (Light/Dark).