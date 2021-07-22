// @dart=2.9
import 'package:dconference/Calls/calls.dart';
import 'package:dconference/Introductions/Firstscreen.dart';
import 'package:dconference/Introductions/IntroScreen.dart';
import 'package:dconference/Screens/homescreen.dart';
import 'package:dconference/Screens/loadingScreen.dart';
import 'package:dconference/Screens/realhome.dart';
import 'package:dconference/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        ),
      ],
      child: MaterialApp(
        title: "D-Con",
        home: RealHome(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
