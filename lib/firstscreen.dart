import 'dart:async';

import 'package:eduguide/presentapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  //หน่วงเวลา
  @override
  void initState() {
    super.initState
    ();

    Timer(
        Duration(seconds: 3),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Pagepresentapp())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //พื้นหลังสีม่วงพาสเทล
      color: Color.fromARGB(255, 165, 139, 255), // สีม่วงพาสเทล
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/LogoEG.png',
            height: 200,
          ),
          const SizedBox(
            height: 10,
          ),
          const SpinKitSpinningLines(color: Colors.white)
        ],
      ),
    );
  }
}