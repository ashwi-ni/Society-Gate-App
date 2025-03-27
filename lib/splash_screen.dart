import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding/onboarding_view.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 3),
            () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnboardingView())));
  }
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.deepOrange,
      body: Container(
        // Assign the Container to the body of the Scaffold
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg4.jpg"),
            fit: BoxFit.cover,

          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
          Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
           // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 40,
                color: Colors.black,
              ),
              SizedBox(width: 10), // Add some space between icon and text
              Text(
                'Sevengen\n-- Society --',
                style: TextStyle(
                  fontFamily: 'gilroy_heavy',
                  color: Colors.black,
                  fontSize: 40,
                ),
              ),
            ],
          ),
          ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}