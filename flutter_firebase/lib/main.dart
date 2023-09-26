import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ctrl+shift+p create a new project in visual studio
//npm install -g firebase-tools
//firebase login
//dart pub global activate flutterfire_cli
//flutterfire configure
//flutter pub add firebase_core

// I will be using - auth & firestore
//flutter pub add firebase_auth
//flutter pub add cloud_firestore
//flutterfire configure

Future<void> main() async {
  // SInce firebase uses native bindings we need to ensure those are ready
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
