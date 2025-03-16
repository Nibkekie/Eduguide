import 'package:eduguide/homePage.dart';
import 'package:eduguide/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class authPage extends StatelessWidget {
  const authPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot){
          if (snapshot.hasData){
            //logged in
            return homePage();
          } else {
            //NOT logged in
            return loginPage();
          }
        })
    );
  }
}
