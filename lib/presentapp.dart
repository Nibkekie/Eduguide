import 'package:eduguide/authPage.dart';
import 'package:eduguide/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Pagepresentapp(),
  ));
}

class Pagepresentapp extends StatelessWidget {
  const Pagepresentapp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 165, 139, 255), // สีพื้นหลัง
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/owl.png',
              height: 250,
            ),
            SizedBox(height: 20), // เพิ่มระยะห่างระหว่างรูปกับข้อความ
            Text(
              'Welcom to EduGuide appication', // ข้อความใต้รูป
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // สีข้อความ
              ),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความ
            Text(
              'A course review community to help you make an informed decision about enrolling.',
              textAlign: TextAlign.center, // จัดข้อความให้อยู่กลาง
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white, // สีข้อความ
              ),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความ
            ElevatedButton(
              onPressed: () {
                //ไปหน้าlogin
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => authPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 244, 110), // เปลี่ยนสีพื้นหลังปุ่ม
                foregroundColor: Color.fromARGB(255, 165, 139, 255), // เปลี่ยนสีข้อความ
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15), // กำหนดขนาดปุ่ม
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(40), // กำหนดมุมโค้งของปุ่ม
                ),
              ),
              child: Text(
                "Get Started",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // ปรับขนาดและความหนาของข้อความ
              ),
            ),
          ],
        ),
      ),
    );
  }
}
