# Seekr AI 👻
Seekr AI is a modern, mobile application built with Flutter and Firebase. It features a deep-void aesthetic, real-time AI chat simulation, and secure user authentication.
___
[Download SeekrAI Untill Checkpoint 1](https://drive.google.com/file/d/13oywENGPEeMpbpaWj9gJZmwA2th7rgQx/view?usp=sharing)
## Features
RAG Architecture: Unlike standard chatbots, Seekr AI performs real-time web searches to ground its responses in current facts.

Secure Authentication: Multi-layered security using Firebase Auth and JWT-protected FastAPI endpoints.

Persistent Souls: User profiles and chat history are synced across devices via Cloud Firestore.

Usage Governance: Built-in energy limits (10/10) to manage API consumption and user engagement.

Reactive UI: Clean, spooky state management powered by the BLoC/Cubit pattern.

## Tech Stack
Frontend (The Ritual)
Framework: Flutter (Android/iOS)

State Management: BLoC & Cubit

Networking: Dio (with JWT Interceptors)

Backend (The Void)
Framework: FastAPI (Python 3.10+)

AI Engine: Google Gemini 1.5 Flash (google-genai SDK)

Search Engine: Google Custom Search API

Database: Cloud Firestore (Admin SDK)

## Application Flow
Gateway: AuthCubit checks the session at startup.

Accession: Users login/register; Firebase issues a UID used for Firestore scoping.

The Summoning:

User sends a prompt from the Flutter app.

FastAPI receives the request and triggers a Search Service.

Search results are fed into Gemini as context.

The finalized response is stored in Firestore and streamed back to the user.

Chronicles: Users view past interactions retrieved directly from the "Void's" database.

## Installation & Setup
Prerequisites
Flutter SDK & Python 3.10+

Firebase Project (with Firestore and Auth enabled)

Google Cloud Console Project (with Custom Search API enabled)

Steps
Clone the repository:

Bash
```
git clone https://github.com/dhruviktank/seekr-ai.git
```
```
cd seekr_ai
```
Add Firebase Configuration:

Place your google-services.json in android/app/.

Place your GoogleService-Info.plist in ios/Runner/.

Install dependencies:

Backend Setup
```
cd server
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```
Create a .env file in /server:
```
GEMINI_API_KEY=your_key
FIREBASE_PROJECT_ID=your_id
GOOGLE_SEARCH_API_KEY=your_key
GOOGLE_SEARCH_CX=your_cx_id
```
Frontend Setup (The App)
```
cd ..
flutter pub get
```
Run the app:

Bash
```
flutter run
```
Release Build (APK)
To generate a signed release APK for Android:

Ensure your key.properties is configured in the android/ folder.

Run the build command:

Bash
```
flutter build apk --release
```
Locate the APK at build/app/outputs/flutter-apk/app-release.apk.

📝 Roadmap (Work in Progress)
[✓] Integration with different GenAI API for real-time responses.

[✓] Firestore Stream for Chat History synchronization.

[ ] Local caching for offline "Void" access.

[ ] Dynamic Spooky Mode theme switching (Light/Dark).
