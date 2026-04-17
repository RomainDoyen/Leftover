# Firebase Setup Instructions

Follow these steps to connect Leftover Roulette to Firebase.

## 1. Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project", name it **leftover-roulette**
3. Disable Google Analytics (optional)
4. Click "Create project"

## 2. Enable Services

### Firestore
1. In Firebase Console → Build → Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select region: `europe-west1` (or nearest to you)

### Authentication
1. In Firebase Console → Build → Authentication
2. Click "Get started"
3. Enable **Anonymous** provider ← required for shopping list without login
4. Enable **Email/Password** provider
5. Enable **Google** provider (requires SHA-1 for Android)

## 3. Run FlutterFire CLI

```bash
# Make sure you're logged in to Firebase
firebase login

# From project root:
export PATH="$PATH:/home/romain/flutter/bin"
export PATH="$PATH:/home/romain/.pub-cache/bin"
flutterfire configure --project=leftover-roulette
```

Select: **Android** + **iOS**

This generates `lib/firebase_options.dart` automatically.

## 4. Enable Firebase in main.dart

In `lib/main.dart`, uncomment:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

## 5. Enable Firebase in repository_providers.dart

In `lib/core/providers/repository_providers.dart` (created in Task 7), change:
```dart
const _useFirebase = false; // → change to true
```

## 6. Seed Firestore

```bash
cd scripts
npm install
# Download service account key from Firebase Console > Settings > Service accounts
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node seed_firestore.js
```
