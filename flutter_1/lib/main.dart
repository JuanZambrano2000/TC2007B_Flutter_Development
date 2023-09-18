import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// Widget:
// Very similar to "composable"
// bulding block for UI on Flutter
// Widgets can aggregate - build new widgets with smaller widgets
// a widget class MUST extend another widget

// Each widget is defined by its own class
// very important - they must have a build method somewhere

// 2 types of widgets
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // constant constructors
  // prefered for performance reasons
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My First Flutter App!",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const StatelessExample(),
    );
  }
}

// 2 main types of widgets
// 1. stateful
// 2. stateless

// stateless - interface will not change, doesn't matter
// What happens with data
class StatelessExample extends StatelessWidget {
  const StatelessExample({super.key});

  @override
  Widget build(BuildContext context) {
    // we're using a scaffold

    // important to keerp in mind for column -
    // column is static in content
    // if we need dynamic behaviour
    return Scaffold(
      appBar: AppBar(
        title: const Text("HEY GUYS"),
      ),
      body: Column(
        children: [
          const Text("Hey guys"),
          const Text("this text is inside this a column"),
          const Text("super cool era"),
          Image.network(
              "https://www.isabeleats.com/wp-content/uploads/2020/11/chilaquiles-verdes-small-8-127x191.jpg")
        ],
      ),
    );
  }
}

// stateful - widget that can swap interfaces
// each interface is represented through a state
class StatefulExample extends StatefulWidget {
  const StatefulExample({super.key});

  @override
  State<StatefulExample> createState() => _StatefulExampleState();
}

//within the states we have the same build method
class _StatefulExampleState extends State<StatefulExample> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
