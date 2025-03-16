import 'dart:typed_data';
import 'package:eduguide/service/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eduguide/CreateNamePage.dart';
import 'package:eduguide/loginPage.dart';


class registPage extends StatefulWidget {
  const registPage({super.key});

  @override
  State<registPage> createState() => _registPageState();
}

class _registPageState extends State<registPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      if (passwordController.text == confirmPasswordController.text) {
          UserCredential authResult = await _auth.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          User? signedInUser = authResult.user;
          if (signedInUser != null) {
            await _firestore.collection('users').doc(signedInUser.uid).set({
              'email': emailController.text,
              'password': passwordController.text,
              //Don't have name and picture yet
            });
            if (!mounted) return;
            Navigator.pop(context); //Move here
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateNamePage(uid: signedInUser.uid)), //ส่ง UID มา
            );
          }
        } else {
        print('Passwords don\'t match');
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
        Navigator.pop(context); // Close the loading indicator
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child:
              Text('Register', style: TextStyle(color: Colors.white)),
        ),
        actions: [Icon(Icons.help, color: Colors.white)],
        backgroundColor: Color.fromARGB(255, 165, 139, 255),
      ),
      backgroundColor: Color.fromARGB(255, 165, 139, 255),
      body: Container(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              Center(
                  child: Text(
                'Create accout',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              )),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      autofocus: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.mail, color: Colors.white),
                        labelText: ' Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'กรุณากรอก email';
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock, color: Colors.white),
                        labelText: ' Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'กรุณากรอกรหัสยืนยัน';
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUserUp();
                        }
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Color.fromARGB(255, 165, 139, 255)),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:Color.fromARGB(255, 255, 244, 110)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
