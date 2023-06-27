import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_app/Screens/HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 3)).then((value) => {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        )
      });
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
            Text("XenonStack", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700),),
            SpinKitSpinningLines(
              color: Color.fromARGB(255, 102, 161, 209),
              size: 100.0,
            )
          ]
        ),
      ), 
      backgroundColor: Colors.white
    );
  }
}