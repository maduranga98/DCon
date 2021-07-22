// @dart=2.9
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  TextEditingController nickname = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  String name = "";
  String aboutme = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final _picker = ImagePicker();

  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

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
    uploadImageToFirebace();
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
    });
  }

  void updateData() {
    nickNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });
    try {
      print(nickname.text);
      print(aboutMeController.text);
      print(photoUrl);

      User user = FirebaseAuth.instance.currentUser;
      setState(() {
        String ename = nickname.text;
        String eame = aboutMeController.text;
        FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'name': ename,
          'aboutMe': eame,
          'createAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'photoUrl': photoUrl,
        });
      });
    } catch (e) {
      print("Errors :$e");
    }
  }

  User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          photoUrl = snapshot["photoUrl"];
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        titleSpacing: 5.0,
        backgroundColor: Colors.blue[900],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // profile Avatar
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
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 200.0,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(150)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
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
                                child: Container(
                                  child: Image.file(
                                    imageFileAvatar,
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
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
                          ? SpinKitCircle(
                              color: Colors.black,
                              size: 25.0,
                            )
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
                          onChanged: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get()
                                .then((DocumentSnapshot snapshot) {
                              if (snapshot.exists) {
                                setState(() {
                                  name = snapshot["name"];
                                  value = name;
                                  print(value);
                                });
                                return Container(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                        letterSpacing: 4.0,
                                        color: Colors.blue[900]),
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 10.0, bottom: 5.0, top: 10.0),
                                );
                              }
                            });
                          },
                          focusNode: nickNameFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    Container(
                      child: Text(
                        name,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
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
                          onChanged: (value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get()
                                .then((DocumentSnapshot snapshot) {
                              if (snapshot.exists) {
                                setState(() {
                                  aboutme = snapshot["aboutMe"];
                                  value = aboutme;
                                  print(value);
                                });
                                return Container(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                        letterSpacing: 4.0,
                                        color: Colors.blue[900]),
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 10.0, bottom: 5.0, top: 10.0),
                                );
                              }
                            });
                          },
                          focusNode: aboutMeFocusNode,
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
                  child: RaisedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text(
                      "Update",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Colors.black87,
                    highlightColor: Colors.grey,
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    onPressed: updateData,
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),
        ],
      ),
    );
  }
}
