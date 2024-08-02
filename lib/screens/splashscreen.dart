// lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart'; // Adjust the import according to your file structure
import 'home.dart'; // Adjust the import according to your file structure

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(seconds: 5), () {
        print("Timer completed, navigating to Login Screen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageHeight = MediaQuery.of(context).size.height;
    final pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color.fromRGBO(62, 92, 67, 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: pageHeight * 0.30,
                  width: pageWidth * 0.60,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/fleet-tracker-high-resolution-logo-transparent.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: null /* add child content here */,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
