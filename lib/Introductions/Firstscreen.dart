import 'dart:async';

import 'package:dconference/Screens/loadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    // TODO: implement initState

    Timer(
        Duration(seconds: 3),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      // height: 400.0,
      // width: 400.0,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 150,
              width: 150,
              child: Image(image: AssetImage('assets/s4.jpg')),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.black,
            highlightColor: Colors.white,
            child: Text(
              "D-Con",
              style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Ewert',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0),
            ),
          )
        ],
      ),
    ));
  }
}
