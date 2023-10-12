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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: LoginWidget(),
        ),
      ),
    );
  }
}

//stf
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    // how to check when a user is connected
    // design pattern - singleton
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("USER: ${user.uid}");
      }
    });

    TextEditingController login = TextEditingController();
    TextEditingController password = TextEditingController();

    setState(() {
      login.text = "";
      password.text = "";
    });
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "login",
              ),
              controller: login,
            )),
        Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
              controller: password,
              obscureText: true,
            )),
        TextButton(
            onPressed: () async {
              try {
                final user = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: login.text, 
                        password: password.text
                    );
                print("${user.user?.uid}");
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  print("Your password is weak");
                } else if (e.code == "email-already-in-use"){
                  print("The email is already taken");
                }
              }
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Sign up")),
        TextButton(onPressed: () {}, child: const Text("Log in")),
        TextButton(onPressed: () {}, child: const Text("Add record")),
        TextButton(onPressed: () {}, child: const Text("Query")),
      ],
    );
  }
}
