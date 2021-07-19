import 'dart:async';

import 'package:dconference/Screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading2 extends StatefulWidget {
  @override
  _Loading2State createState() => _Loading2State();
}

class _Loading2State extends State<Loading2> {
  @override
  void initState() {
    // TODO: implement initState

    Timer(
        Duration(seconds: 2),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SpinKitRipple(
            size: 80.0,
            color: Colors.blue[900],
          ),
        ],
      ),
    );
  }
}
