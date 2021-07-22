// @dart=2.9
import 'package:dconference/Screens/signUp.dart';
import 'package:dconference/services/auth.dart';
import 'package:dconference/services/loading.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  String email = '';
  String error = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/2-01.png'), fit: BoxFit.cover)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        validator: (value) =>
                            value.isEmpty ? 'Enter an email' : null,
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0),
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      child: TextFormField(
                        controller: passwordController,
                        validator: (value) => value.length < 8
                            ? ' Enter a password 8+ chars long'
                            : null,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0),
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width / 3,
                      color: Colors.black54,
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        child: Text(
                          "LOG IN",
                          style: TextStyle(color: Colors.deepOrange[100]),
                        ),
                        onPressed: () async {
                          final String email = emailController.text.trim();
                          final String password =
                              passwordController.text.trim();
                          if (_formKey.currentState.validate()) {
                            print(email);
                            print(password);
                            dynamic result = await context
                                .read<AuthService>()
                                .login(email, password);
                            if (result != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Loading()));
                            } else {
                              setState(() {
                                return error = "please Enter valied Email";
                              });
                            }
                          }

                          // if (email.isEmpty) {
                          //   return Text("Email id Empty");
                          // } else {
                          //   if (password.isEmpty) {
                          //     return Text("Password is empty");
                          //   } else {
                          //     dynamic result = await context
                          //         .read<AuthService>()
                          //         .login(email, password);
                          //
                          //   }
                          // }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 35,
                        ),
                        Text(
                          "Don't have an account?",
                          style:
                              TextStyle(color: Colors.blue[900], fontSize: 15),
                        ),
                        FlatButton(
                          child: Text("SIGN UP",
                              style: TextStyle(color: Colors.deepPurple[900])),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUp()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
