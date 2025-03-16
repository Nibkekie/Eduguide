import 'package:eduguide/forgotPasswordPage.dart';
import 'package:eduguide/homePage.dart';
import 'package:eduguide/registPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context) ; 
      Navigator.push(context, MaterialPageRoute(builder: (context) => homePage(),)) ; 

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //พื้นหลังสีม่วงพาสเทล
      color: Color.fromARGB(255, 165, 139, 255), // สีม่วงพาสเทล
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.only(top: 30, bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/Profile1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Material(
                  color: Colors.transparent, // สีพื้นหลังโปร่งใส
                  child: Form(
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
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
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
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            forgotPasswordPage()));
                              },
                              child: Text('Forgot Password?',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signUserIn();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 244, 110),
                            foregroundColor: Color.fromARGB(255, 165, 139, 255),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text('Login'),
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                signInWithGoogle();
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    Color.fromARGB(255, 255, 244, 110),
                                child: Icon(Icons.mail_outline,
                                    color: Color.fromARGB(255, 165, 139, 255)),
                              ),
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Color.fromARGB(255, 255, 244, 110),
                              child: Icon(Icons.facebook,
                                  color: Color.fromARGB(255, 165, 139, 255)),
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Color.fromARGB(255, 255, 244, 110),
                              child: Icon(Icons.apple,
                                  color: Color.fromARGB(255, 165, 139, 255)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Not a member?',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => registPage()));
                                },
                                child: Text('Register now',
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 255, 244, 110))),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
