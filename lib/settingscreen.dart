import 'package:eduguide/service/auth_service.dart';
import 'package:eduguide/service/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduguide/homePage.dart'; // Import your homePage

class settingscreen extends StatefulWidget {
  final String uid; // เพิ่มตัวแปร UID ที่รับมาจาก registPage

  const settingscreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<settingscreen> createState() => _settingscreenState();
}

class _settingscreenState extends State<settingscreen> {
  Uint8List? _image;
  String? _imageUrl; // เก็บ URL รูปภาพ
  String? _userName; // เก็บชื่อผู้ใช้
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isEditingName = false; // ตัวแปรบอกว่ากำลังแก้ไขชื่ออยู่หรือไม่
  final AuthService _authService = AuthService(); // Create instance of AuthService

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ดึงข้อมูลผู้ใช้เมื่อเปิดหน้าจอ
  }

  // ดึงข้อมูลผู้ใช้จาก Firestore
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.get('name');
          _imageUrl = userDoc.get('imageUrl');
          _nameController.text = _userName ?? ''; // ตั้งค่าชื่อเริ่มต้นใน TextField
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

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
        _isEditingName = false; // ปิดโหมดแก้ไขชื่อ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFAA8EFF),
      appBar: AppBar( // เพิ่ม AppBar
        backgroundColor: Color(0xFFAA8EFF), // สีเดียวกับพื้นหลัง
        elevation: 0, // เอาเงาออก
        leading: IconButton( // เพิ่มปุ่มย้อนกลับ
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pop(context); // ย้อนกลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0), // ลดระยะห่างจากขอบบน
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Edit Profile', // เปลี่ยนเป็น Edit Profile
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
                          : _imageUrl != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(_imageUrl!),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: _isEditingName
                              ? TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: 'Name account',
                                  ),
                                )
                              : Text(
                                  _userName ?? 'No Name', // แสดงชื่อผู้ใช้ หรือ 'No Name' ถ้าไม่มีชื่อ
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                        IconButton(
                          icon: Icon(_isEditingName ? Icons.close : Icons.edit), // เปลี่ยนไอคอนตามสถานะ
                          onPressed: () {
                            setState(() {
                              _isEditingName = !_isEditingName;
                              if (!_isEditingName) {
                                _nameController.text = _userName ?? '';
                              }
                            });
                          },
                        ),
                      ],
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
