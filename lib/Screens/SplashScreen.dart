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
            Image(image: AssetImage('assets/logo.png'), width: 100,),
            Text("XenonStack Pvt Ltd", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),),
            SpinKitWaveSpinner(
              color: Color.fromARGB(255, 59, 153, 25),
              size: 80.0,
            )
          ]
        ),
      ), 
      backgroundColor: Color.fromARGB(255, 182, 228, 255), 
    );
  }
}