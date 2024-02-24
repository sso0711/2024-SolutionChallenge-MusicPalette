import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_palette/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //var user = LoginService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(69, 111, 141, 1),
        primaryColorLight: const Color.fromARGB(240, 20, 34, 43),
        focusColor: Colors.black,
      ),
    );
  }
}
