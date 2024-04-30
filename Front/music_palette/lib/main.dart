import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_palette/home_screen.dart';

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();

  Future<String> delaying() {
    return Future.delayed(const Duration(seconds: 3), () => "");
  }

  await delaying();

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
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        primaryColorLight: const Color.fromARGB(235, 255, 255, 255),
        focusColor: const Color.fromARGB(237, 0, 0, 0),
      ),
    );
  }
}
