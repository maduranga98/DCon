import 'dart:ffi';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/LMS/CreatedRooms.dart';
import 'package:dconference/LMS/JoinedRooms.dart';
import 'package:dconference/LMS/MainScreen.dart';
import 'package:dconference/LMS/SearchRooms.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

//***********************DLMS Dash board page************* */
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController roomName = TextEditingController();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("D-LMS", style: TextStyle(fontFamily: 'Molle')),
          centerTitle: true,
        ),
        body: buildPages(),
        bottomNavigationBar: BottomNavyBar(
          backgroundColor: Colors.blue[900],
          selectedIndex: index,
          itemCornerRadius: 16,
          onItemSelected: (index) => setState(() => this.index = index),
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
                icon: Icon(Icons.room_preferences_outlined),
                title: Text("Created"),
                inactiveColor: Colors.white,
                activeColor: Colors.amberAccent),
            BottomNavyBarItem(
                icon: Icon(Icons.room_preferences_rounded),
                title: Text("Joined"),
                inactiveColor: Colors.white,
                activeColor: Colors.amberAccent),
            BottomNavyBarItem(
                icon: Icon(Icons.search),
                title: Text("Search"),
                inactiveColor: Colors.white,
                activeColor: Colors.amberAccent),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[900],
          hoverColor: Colors.amber,
          focusColor: Colors.black,
          splashColor: Colors.white70,
          child: Icon(
            Icons.add,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      height: 200,
                      width: 200,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter the class room name",
                                hintStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blue[900]),
                              ),
                              controller: roomName,
                            ),
                            SizedBox(
                              width: 320.0,
                              // ignore: deprecated_member_use
                              child: RaisedButton(
                                  color: Color(0xFF1BC0C5),
                                  child: Text(
                                    "Create",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);

                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 100,
                                                      bottom: 16,
                                                      left: 16,
                                                      right: 16),
                                                  margin:
                                                      EdgeInsets.only(top: 16),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              17),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 10.0,
                                                          offset:
                                                              Offset(0.0, 10.0),
                                                        )
                                                      ]),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        ("Success"),
                                                        style: TextStyle(
                                                            fontSize: 24.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      SizedBox(
                                                        height: 16.0,
                                                      ),
                                                      Text(
                                                        ("You successfully created the class room"),
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 24.0,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child:
                                                            // ignore: deprecated_member_use
                                                            FlatButton(
                                                          child:
                                                              Text("Confirm"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            String name;
                                                            setState(() {
                                                              name =
                                                                  roomName.text;
                                                              print(name);
                                                            });
                                                            try {
                                                              User user =
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser;
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "classroom")
                                                                  .doc(name)
                                                                  .set({
                                                                "creator":
                                                                    user.uid,
                                                                "roomname": name
                                                              });
                                                            } catch (e) {
                                                              print(
                                                                  "Firebase Error:$e");
                                                              // TODO
                                                            }

                                                            roomName.clear();
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  left: 16,
                                                  right: 16,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    radius: 60,
                                                    backgroundImage: AssetImage(
                                                        "assets/XLpr.gif"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
        ));
  }

  Widget buildPages() {
    switch (index) {
      case 0:
        return CreatedRooms();
      case 1:
        return JoinedRooms();
      case 2:
        return SearchRooms();
    }
  }
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;
  const CustomDialog(
      {this.title, this.description, this.buttonText, this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 100, bottom: 16, left: 16, right: 16),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Align(
                alignment: Alignment.bottomRight,
                // ignore: deprecated_member_use
                child: FlatButton(
                  child: Text("Confirm"),
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => MainScreen(roomname: roomname)));
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 60,
            backgroundImage: AssetImage("assets/XLpr.gif"),
          ),
        )
      ],
    );
  }
}
