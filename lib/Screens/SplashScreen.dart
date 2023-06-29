import 'package:flutter/material.dart' show AssetImage, BuildContext, Color, Colors, Column, FontWeight, Image, Key, MainAxisAlignment, MaterialPageRoute, Navigator, Scaffold, SizedBox, State, StatefulWidget, Text, TextStyle, Widget;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_app/Screens/HomeScreen.dart' show HomeScreen;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 4)).then((value) => 
        Navigator.of(context).popAndPushNamed('/home')
      );
    }
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Image(image: AssetImage('assets/logo.png'), width: 120,),
            Text("XenonStack", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700,color: Colors.black)),
            SpinKitCircle(
              color: Colors.black,
              size: 70.0,
            )
          ],
        ),
      ), 
      backgroundColor: Colors.white
    );
  }
}