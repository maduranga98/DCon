import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Introductions/IntroScreen.dart';
import 'package:dconference/services/auth.dart';
import 'package:dconference/services/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nickname = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String name = "";
  String aboutme = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  bool loading = false;
  final _picker = ImagePicker();

  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  Future getImage() async {
    PickedFile image = await _picker.getImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        this.imageFileAvatar = File(image.path);
        isLoading = true;
        print(imageFileAvatar);
      });
    } else {
      print("Image Not get");
    }
  }

  Future uploadImageToFirebace() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child("Profile").child(fileName);
    UploadTask uploadTask = ref.putFile(imageFileAvatar);
    TaskSnapshot storageTaskSnapshot = await uploadTask;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      photoUrl = downloadUrl;
      User user = FirebaseAuth.instance.currentUser;
      setState(() {
        FirebaseFirestore.instance
            .collection("profiles")
            .doc(user.uid)
            .set({'photoUrl': photoUrl, 'uid': user.uid});
      });
      setState(() {
        FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'name': nickname.text,
          'uid': user.uid,
          'aboutMe': aboutMeController.text,
          'createAt': DateTime.now().microsecondsSinceEpoch.toString(),
          'chattingWith': null,
          'photoUrl': photoUrl
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
        titleSpacing: 3.0,
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Stack(
                    children: [
                      (imageFileAvatar == null)
                          ? (photoUrl != "")
                              ? Material(
                                  // display old image
                                  child: Center(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: 0.5,
                                            strokeWidth: 8.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue[900]),
                                          ),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        padding: EdgeInsets.all(0.0),
                                      ),
                                      imageUrl: photoUrl,
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(200.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Center(
                                  child: Icon(Icons.account_circle,
                                      size: 200.0, color: Colors.grey),
                                )
                          : Material(
                              // display new iamge
                              child: Center(
                                child: Image.file(
                                  imageFileAvatar,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            size: 100.0,
                            color: Colors.white54.withOpacity(0.3),
                          ),
                          onPressed: getImage,
                          padding: EdgeInsets.all(0.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.grey,
                          iconSize: 200.0,
                        ),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20.0),
                ),
                // input Fields
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isLoading
                          ? SpinKitWave(
                              color: Colors.blue,
                              size: 30.0,
                            )
                          // ? Center(
                          //     child: CircularProgressIndicator(
                          //       strokeWidth: 2.0,
                          //       valueColor: AlwaysStoppedAnimation<Color>(
                          //           Colors.lightBlueAccent),
                          //     ),
                          //   )
                          : Container(),
                    ),

                    //username
                    Container(
                      child: Text(
                        "Profile Name:",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),

                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          controller: nickname,
                          decoration: InputDecoration(
                            hintText: "e.g Ravi Jey",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          focusNode: nickNameFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    // aboutMe
                    Container(
                      child: Text(
                        "About Me:",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),

                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "e.g Hey there! I am using Dcon Chat",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: aboutMeController,
                          focusNode: aboutMeFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    // email
                    Container(
                      child: Text(
                        "Email:",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),

                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "e.g example@example.com",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: emailController,
                          focusNode: emailFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    Container(
                      child: Text(
                        "Password:",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),

                    //password
                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "********",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          obscureText: true,
                          controller: passwordController,
                          focusNode: passwordFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),

                //Buttons

                Container(
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    child: Text(
                      "Update",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Colors.black87,
                    highlightColor: Colors.grey,
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    onPressed: () {
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();
                      if (email.isEmpty) {
                        print("Email id Empty");
                      } else {
                        if (password.isEmpty) {
                          print("Password is empty");
                        } else {
                          try {
                            context
                                .read<AuthService>()
                                .signUp(email, password)
                                .then((value) async {
                              User user = FirebaseAuth.instance.currentUser;
                              uploadImageToFirebace();
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.uid)
                                  .collection("emsils")
                                  .doc()
                                  .set({
                                'email': email,
                                'password': password,
                              });
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Loading()));

                            nickNameFocusNode.unfocus();
                            aboutMeFocusNode.unfocus();
                            emailFocusNode.unfocus();
                            passwordFocusNode.unfocus();
                          } catch (e) {
                            print("LoginError:($e)");
                          }
                        }
                      }
                    },
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
