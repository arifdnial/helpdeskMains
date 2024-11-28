import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhujq4YGdkljGS5_TeUbAi0jVjg29oxfI',
    appId: '1:837678178526:android:b294401c2596d7dca3224f',
    messagingSenderId: '837678178526',
    projectId: 'ehelpdesk-85982',
    storageBucket: 'ehelpdesk-85982.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'Your iOS API Key', // Replace with the actual iOS API key
    appId: 'Your iOS App ID', // Replace with the actual iOS App ID
    messagingSenderId: '837678178526',
    projectId: 'ehelpdesk-85982',
    storageBucket: 'ehelpdesk-85982.appspot.com',
    iosBundleId: 'com.example.helpdeskmains', // Update as needed
  );
}
