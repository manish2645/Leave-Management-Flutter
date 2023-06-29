import 'package:flutter/material.dart' show BuildContext, MaterialApp, ModalRoute, StatelessWidget, Widget, runApp;
import 'package:form_app/Screens/FileViewerScreen.dart';
import 'package:form_app/Screens/HomeScreen.dart' show HomeScreen;
import 'Screens/SplashScreen.dart' show SplashScreen;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routes of the App',
      initialRoute: '/',
      routes: {
          '/':(context) => const SplashScreen(),
          '/home':(context) => const HomeScreen(),
      },
    );
  }
}
