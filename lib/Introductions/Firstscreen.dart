// @dart=2.9
import 'dart:async';

import 'package:dconference/Introductions/IntroScreen.dart';
import 'package:dconference/Screens/loadingScreen.dart';
import 'package:dconference/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        Duration(seconds: 5),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Forward())));
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

class Forward extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        // ignore: missing_required_param
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: "D-Con",
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    if (user != null) {
      return IntroAuthScreen();
    }
    return LoginScreen();
  }
}
