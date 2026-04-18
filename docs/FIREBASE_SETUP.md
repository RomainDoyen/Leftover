# Firebase Setup Instructions

Follow these steps to connect Leftover to Firebase.

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
3. Enable **Email/Password** provider
4. Enable **Google** provider (requires SHA-1 for Android)

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

## 6. Firestore Security Rules

In Firebase Console → Firestore → Rules, use:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /recipes/{recipeId} {
      // Any signed-in user can read or create recipes (AI-generated ones are saved here).
      allow read:   if request.auth != null;
      allow create: if request.auth != null;
      // Only service accounts (backend/seed scripts) can update or delete.
      allow update, delete: if false;
    }

    match /users/{userId}/shoppingLists/{document=**} {
      // Users can only access their own shopping list.
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /users/{userId}/history/{document=**} {
      // Users can only access their own recipe history.
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## 7. Seed Firestore

```bash
cd scripts
npm install
# Download service account key from Firebase Console > Settings > Service accounts
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node seed_firestore.js
```
