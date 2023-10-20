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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User created successfully')));
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'The password provided is too weak, just like you.')));
                  } else if (e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'The account already exists for that email.')));
                  } else if (e.code == 'invalid-email') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('The email address is badly formatted.')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Create account")),
          TextButton(
              onPressed: () async {
                try {
                  final user = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: login.text, password: password.text);
                  if (user != null) {
                    print("USER LOGGED IN: ${user.user?.uid}");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuActivity()));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Sign in")),
        ],
      ),
    );
  }
}

class MenuActivity extends StatefulWidget {
  @override
  _MenuActivityState createState() => _MenuActivityState();
}

class _MenuActivityState extends State<MenuActivity> {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Activity')),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('animals').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(
                child: Text(
                    "There are no animals registered, register the first one"));
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) =>
                buildListItem(context, snapshot.data!.docs[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => DetailActivity()))),
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Text(document['name']),
      trailing: IconButton(
          icon: Icon(Icons.info),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DetailActivity(animalDocument: document)))),
    );
  }
}

class DetailActivity extends StatefulWidget {
  final DocumentSnapshot? animalDocument;

  DetailActivity({this.animalDocument});

  @override
  _DetailActivityState createState() => _DetailActivityState();
}

class _DetailActivityState extends State<DetailActivity> {
  final db = FirebaseFirestore.instance;

  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.animalDocument?['name'] ?? '');
    ageController = TextEditingController(
        text: widget.animalDocument?['age']?.toString() ?? '');
    weightController = TextEditingController(
        text: widget.animalDocument?['weight']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Activity')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age')),
            TextField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Weight')),
            ElevatedButton(onPressed: registerAnimal, child: Text('Register'))
          ],
        ),
      ),
    );
  }

  void registerAnimal() {
    double? age = double.tryParse(ageController.text);
    double? weight = double.tryParse(weightController.text);

    if (age == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Age and weight must be numerical')));
      return;
    }

    final animal = {'name': nameController.text, 'age': age, 'weight': weight};

    if (widget.animalDocument == null) {
      db.collection('animals').add(animal);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New animal registered successfully')));
    } else {
      db.collection('animals').doc(widget.animalDocument!.id).update(animal);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Animal details updated successfully')));
    }

    Navigator.pop(context);
  }
}
