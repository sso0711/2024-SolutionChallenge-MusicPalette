import 'package:flutter/material.dart';
import 'package:music_palette/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(69, 111, 141, 1),
        primaryColorLight: const Color.fromARGB(240, 20, 34, 43),
        focusColor: Colors.black,
      ),
    );
  }
}
