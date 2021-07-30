import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'CallogPage.dart';

class Calls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dconn Group Video Calling',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.blue[900],
          fontFamily: 'Fascinate',
        ),
        home: MyHomePage());
  }
}
