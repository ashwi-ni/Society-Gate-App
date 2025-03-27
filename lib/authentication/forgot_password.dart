
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Forgot Password'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          const SizedBox(height: 40,),
          ElevatedButton(

              onPressed: () {
                auth.sendPasswordResetEmail(email: emailController.text).then(
                        (value){Utils.toastMessage('We have send you email to recover password, please check the email');}

                ).onError((error, stackTrace) => Utils.toastMessage(error.toString()),
                );},
              child: const Text(
                'ENTER',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
              ),

              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                  backgroundColor: Colors.black // Adjust the padding as needed
              )

          )
        ],
      ),
    );
  }
}

