import 'package:flutter/material.dart';
import 'package:miniprojectflutter/screens/SignInScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Set the background color for the entire app
        scaffoldBackgroundColor: const Color.fromARGB(255, 115, 20, 132),
      ),
      home: const SignInScreen(),
    );
  }
}
