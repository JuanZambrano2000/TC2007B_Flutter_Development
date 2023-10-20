import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
to add multidex support:
flutter run --debug
y
 */
Future<void> main() async {
  // since firebase uses native bindings we need to ensure those are ready
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
          child: LoginWidget(),
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;
    // how to check when a user is connected in realtime
    // design pattern - singleton
    // https://en.wikipedia.org/wiki/Singleton_pattern
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("USER: ${user.uid}");
      } else {
        print("SIGNED OUT");
      }
    });

    // lets add some states!
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
                labelText: 'Login',
              ),
              controller: login,
            )),
        Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              controller: password,
              obscureText: true,
            )),
        TextButton(
            onPressed: () async {
              try {
                final user = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: login.text, password: password.text);
                print("USER CREATED: ${user.user?.uid}");
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  print("your password is weak and so are you.");
                } else if (e.code == 'email-already-in-use') {
                  print("account exists.");
                }
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Sign up")),
        TextButton(
            onPressed: () async {
              try {
                final user = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: login.text, password: password.text);
                print("USER LOGGED IN: ${user.user?.uid}");
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Log in")),
        TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Log out")),
        TextButton(
            onPressed: () async {
              // create an object that will be translated into a document
              // remember - firestore has a structure in which collections contain documents
              // documents are similar to records in a relational db
              final puppy = <String, dynamic>{
                "name": "Killer",
                "breed": "Chihuahueño",
                "age": 1.0
              };

              // add user into firestore collection
              db.collection("puppies").add(puppy).then(
                  (DocumentReference doc) =>
                      print("new document created: ${doc.id}"));
            },
            child: const Text("Add record")),
        TextButton(
            onPressed: () async {
              await db.collection("puppies").get().then((value) {
                for (var doc in value.docs) {
                  print("DOCUMENT: ${doc.data()}");
                }
              });
            },
            child: const Text("Query")),
      ],
    );
  }
}
