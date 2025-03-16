import 'package:eduguide/firstscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.inter(),  // ใช้ Inter สำหรับ bodyMedium
        headlineLarge: GoogleFonts.itim(), // ใช้ Itim สำหรับ headlineLarge
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700), // Inter ตัวหนาสำหรับ title
      ),
    ),
    debugShowCheckedModeBanner: false,
    home: FirstScreen(),
  ));
}
