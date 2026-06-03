// ============================================================
// FIREBASE SETUP INSTRUCTIONS
// ============================================================
// 1. Go to https://console.firebase.google.com/ and create a project.
// 2. Register your Android app (package: com.example.caretutors_notes_app)
//    and iOS app (bundle ID: com.example.caretutersNotesApp).
// 3. Install the FlutterFire CLI:
//      dart pub global activate flutterfire_cli
// 4. Run from your project root:
//      flutterfire configure
//    This auto-generates this file with your real credentials.
// 5. Enable Email/Password sign-in in Firebase Console → Authentication.
// 6. Create Firestore database in Firebase Console → Firestore Database.
// 7. Set Firestore security rules (starter):
//    rules_version = '2';
//    service cloud.firestore {
//      match /databases/{database}/documents {
//        match /users/{uid} {
//          allow read, write: if request.auth.uid == uid;
//        }
//        match /notes/{noteId} {
//          allow read, write: if request.auth.uid == resource.data.userId;
//          allow create: if request.auth != null;
//        }
//      }
//    }
// ============================================================
// PLACEHOLDER — Replace this file by running: flutterfire configure
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace all placeholder values below with your actual Firebase config.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCugg7gPuCCbe24pYfCv0-fCw8oX6K6YM4',
    appId: '1:481338386862:android:37f85221d228a706b4803f',
    messagingSenderId: '481338386862',
    projectId: 'caretutors-notes-app-3060b',
    storageBucket: 'caretutors-notes-app-3060b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiMYgceJ-vuDQPxKH4xUizGt8mWH05hp0',
    appId: '1:481338386862:ios:f92bacc2d878a043b4803f',
    messagingSenderId: '481338386862',
    projectId: 'caretutors-notes-app-3060b',
    storageBucket: 'caretutors-notes-app-3060b.firebasestorage.app',
    iosBundleId: 'com.swapon.caretutorsNotesApp',
  );

}