import 'package:fire_on_you/menu/main_menu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FireOnYouMain());
}

class FireOnYouMain extends StatelessWidget {
  const FireOnYouMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire On You',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainMenu(),
    );
  }
}
