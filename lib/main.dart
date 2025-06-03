import 'package:flutter/material.dart';
import 'package:petcare_tubes/login_screen.dart'; // Import LoginScreen
import 'package:petcare_tubes/home_screen.dart'; // Import HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Set LoginScreen sebagai halaman pertama
    );
  }
}
