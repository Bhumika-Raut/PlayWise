import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Updated to reflect new handling

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // No need for routes anymore
    );
  }
}
