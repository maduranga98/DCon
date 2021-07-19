import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dconference/Introductions/IntroScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    // TODO: implement initState

    Timer(
        Duration(seconds: 3),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => IntroAuthScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img2.jpeg',
              height: 120,
            ),
            SizedBox(
              height: 20.0,
            ),
            SpinKitRipple(
              size: 80.0,
              color: Colors.blue[900],
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "Dcon is with",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            AnimatedTextKit(animatedTexts: [
              TyperAnimatedText('Secure',
                  textStyle: TextStyle(
                      fontSize: 30.0,
                      color: Colors.cyan,
                      fontStyle: FontStyle.italic)),
              TyperAnimatedText('Relaible',
                  textStyle: TextStyle(
                      fontSize: 30.0,
                      color: Colors.black,
                      fontStyle: FontStyle.italic)),
              TyperAnimatedText('Available',
                  textStyle: TextStyle(
                      fontSize: 30.0,
                      color: Colors.amber,
                      fontStyle: FontStyle.italic)),
              TyperAnimatedText('Familiar',
                  textStyle: TextStyle(
                      fontSize: 30.0,
                      color: Colors.red,
                      fontStyle: FontStyle.italic)),
            ]),
            Text(
              "App For Android",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
