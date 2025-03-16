import 'package:eduguide/service/auth_service.dart';
import 'package:eduguide/service/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduguide/homePage.dart'; // Import your homePage

class CreateNamePage extends StatefulWidget {
  final String uid; // เพิ่มตัวแปร UID ที่รับมาจาก registPage

  const CreateNamePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<CreateNamePage> createState() => _CreateNamePageState();
}

class _CreateNamePageState extends State<CreateNamePage> {
  Uint8List? _image;
  String? _imageUrl; // เก็บ URL รูปภาพ
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService(); // Create instance of AuthService

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_image != null) {
        //อัปโหลดรูปภาพไปยัง Firebase Storage
        String imageName = "profile_${widget.uid}.jpg";
        _imageUrl = await _authService.uploadImageToStorage('profileImages', _image!);
      }
      // อัปเดตชื่อและ URL รูปภาพลง Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'name': _nameController.text,
        'imageUrl': _imageUrl,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homePage()), // ไปหน้า homePage
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFAA8EFF),
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Create name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  AssetImage('assets/images/Profile1.png'),
                            ),
                      Positioned(
                        bottom: -12,
                        right: 0,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      controller: _nameController, // ใส่ nameController
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Name account',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: _isLoading ? null : saveProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save',
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Image.asset(
                  'assets/images/LogoEGhome.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
