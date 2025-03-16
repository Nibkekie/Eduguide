import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eduguide/Component/HomeComponent.dart';
import 'package:eduguide/Component/ProfileComponent.dart';
import 'package:eduguide/Component/SearchComponent.dart';
import 'package:eduguide/reviewPage.dart';
import 'package:eduguide/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduguide/settingscreen.dart';
import 'package:eduguide/qnada.dart'; // Import qnada.dart

class homePage extends StatefulWidget {
  homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? _userName;
  String? _userImageUrl;
  int _selectedIndex = 0;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print('Error in Google sign out: $e');
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginPage()),
    );
  }

  // List of widgets for the bottom navigation bar
  List<Widget> _pages = [
    HomeComponent(),
    SearchComponent(),
    ProfileComponent(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) {
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.get('name');
          _userImageUrl = userDoc.get('imageUrl');
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _userName != null ? "Hi, $_userName" : "Hi, User",
        leading: _userImageUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(_userImageUrl!),
                radius: 25,
                onBackgroundImageError: (exception, stackTrace) {
                  print("Error loading image: $exception");
                })
            : CircleAvatar(
                backgroundImage: AssetImage('assets/images/Profile1.png'),
                radius: 25,
              ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.white),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            settingscreen(uid: user!.uid)));
              } else if (value == 'logout') {
                signUserOut();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 165, 139, 255),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: Color.fromARGB(255, 255, 244, 110),
          ),
        ),
        activeIcon: Icons.close,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 165, 139, 255)),
        backgroundColor: Color.fromARGB(255, 255, 244, 110),
        buttonSize: Size(58, 58),
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
              elevation: 0,
              child: Icon(
                Icons.contact_support,
                color: Color.fromARGB(255, 255, 244, 110),
              ),
              labelWidget: Text(
                "Q&A ",
                style: TextStyle(color: Color.fromARGB(255, 165, 139, 255)),
              ),
              backgroundColor: Color.fromARGB(255, 165, 139, 255),
              shape: CircleBorder(),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => QandA()));
              }),
          SpeedDialChild(
              elevation: 0,
              child: Icon(
                Icons.create_rounded,
                color: Color.fromARGB(255, 255, 244, 110),
              ),
              labelWidget: Text(
                "Reveiw ",
                style: TextStyle(color: Color.fromARGB(255, 165, 139, 255)),
              ),
              backgroundColor: Color.fromARGB(255, 165, 139, 255),
              shape: CircleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Reviewpage(
                      onReviewPosted: () {
                        // This is an empty callback because we don't need to refresh here.
                        // HomeComponent will handle the refresh.
                        print("Review posted from homePage");
                      },
                    ),
                  ),
                );
              }),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color.fromARGB(255, 255, 244, 110),
        color: Color.fromARGB(255, 255, 244, 110),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 26, color: Color.fromARGB(255, 165, 139, 255)),
          Icon(Icons.search,
              size: 26, color: Color.fromARGB(255, 165, 139, 255)),
          Icon(Icons.person,
              size: 26, color: Color.fromARGB(255, 165, 139, 255)),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _pages[_selectedIndex], // Display the selected page
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  const CustomAppBar(
      {super.key, required this.title, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 165, 139, 255),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        leading: leading,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 30);
}
