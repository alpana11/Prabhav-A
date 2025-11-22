import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApJb9lPzjM6l_wY1zJ_jHXkZ3kY8vP5qE',
    appId: '1:123456789012:android:abcdef123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: 'prabhav-efbd2',
    storageBucket: 'prabhav-efbd2.appspot.com',
  );
}
