// @dart=2.9
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dconference/Room/Documents.dart';
import 'package:dconference/Room/Notice.dart';
import 'package:dconference/Room/groupchat.dart';
import 'package:dconference/Room/members.dart';
import 'package:flutter/material.dart';

//******************room screen eka  (room eka athule screen eka)************* */
class MainScreen extends StatefulWidget {
  final String roomname;
  final String userId;
  final String creatorID;

  MainScreen(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorID});

  @override
  _MainScreenState createState() => _MainScreenState(
      roomname: roomname, userId: userId, creatorID: creatorID);
}

class _MainScreenState extends State<MainScreen> {
  final String roomname;
  final String userId;
  final String creatorID;

  _MainScreenState(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorID});
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: Text(roomname),
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
              icon: Icon(Icons.file_present),
              title: Text("Documents"),
              inactiveColor: Colors.white,
              activeColor: Colors.amberAccent),
          BottomNavyBarItem(
              icon: Icon(Icons.announcement_outlined),
              title: Text("Notice"),
              inactiveColor: Colors.white,
              activeColor: Colors.amberAccent),
          BottomNavyBarItem(
              icon: Icon(Icons.group_outlined),
              title: Text("Members"),
              inactiveColor: Colors.white,
              activeColor: Colors.amberAccent),
          BottomNavyBarItem(
              icon: Icon(Icons.chat),
              title: Text("Chat"),
              inactiveColor: Colors.white,
              activeColor: Colors.amberAccent),
        ],
      ),
    );
  }

  Widget buildPages() {
    switch (index) {
      case 0:
        return DocumentsPage(
          roomname: roomname,
          creatorID: creatorID,
          userId: userId,
        );
      case 1:
        return Notice(
          roomname: roomname,
          userId: userId,
          creatorId: creatorID,
        );
      case 2:
        return Members(
          roomname: roomname,
          creatorID: creatorID,
          userId: userId,
        );
      case 3:
        return GroupChat(
          roomname: roomname,
          userId: userId,
        );
    }
  }
}
