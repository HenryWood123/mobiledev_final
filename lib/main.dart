import 'package:flutter/material.dart';
import 'package:mobiledev_final/screens/home.dart';
import 'package:mobiledev_final/screens/splashscreen.dart';
import 'package:mobiledev_final/screens/userinfo.dart';
import 'package:mobiledev_final/screens/vehiclepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with the SplashScreen
    );
  }
}
