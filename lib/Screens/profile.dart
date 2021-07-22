// @dart=2.9
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Screens/accountSetting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name, bio, url;
  Map<String, dynamic> userMap;
  String photoUrl = "";
  File imageFileAvatar;
  User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (!snapshot.exists) {
        return CircularProgressIndicator();
      }
      if (snapshot.exists) {
        setState(() {
          name = snapshot['name'];
          url = snapshot['photoUrl'];
          bio = snapshot['aboutMe'];
        });
      }
      if (name == null && url == null && bio == null) {
        return CircularProgressIndicator();
      } else {
        return CircularProgressIndicator();
      }
    });

    return (name == null && url == null && bio == null)
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title:
                  Text("User Profile", style: TextStyle(fontFamily: 'Molle')),
              backgroundColor: Colors.black,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: 0.5,
                                strokeWidth: 8.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[900]),
                              ),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(0.0),
                          ),
                          imageUrl: url,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 200.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(150)),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.deepOrangeAccent,
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Name:",
                            style: TextStyle(
                                fontSize: 30.0,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Fascinate'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              //decoration: BoxDecoration(color: Colors.amber),
                              // width: 300.0,
                              child: Text(
                            name,
                            style: TextStyle(
                                fontFamily: 'Uncial',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0),
                          )),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "bio:",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Fascinate'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            bio,
                            style: TextStyle(
                                fontFamily: 'Uncial',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AccountSetting()));
              },
            ),
          );
  }
}
