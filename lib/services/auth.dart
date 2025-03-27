
import 'package:colorful_circular_progress_indicator/colorful_circular_progress_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:society_gate_app/screens/homescreen.dart';

import '../authentication/login_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,AsyncSnapshot<User?> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
                child: ColorfulCircularProgressIndicator(
                  colors: [Colors.blue, Colors.red, Colors.amber, Colors.green],
                  strokeWidth: 5,
                  indicatorHeight: 40,
                  indicatorWidth: 40,
                ));
          }
          if(snapshot.hasData){
            return  HomeScreen();
          }else{
            return const LoginScreen();
          }
        },

      ),
    );
  }
}
