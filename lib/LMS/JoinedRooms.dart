import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/LMS/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class JoinedRooms extends StatefulWidget {
  @override
  _JoinedRoomsState createState() => _JoinedRoomsState();
}

class _JoinedRoomsState extends State<JoinedRooms> {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Joined Rooms",
          style: TextStyle(
              fontSize: 15, fontFamily: 'Fascinate', letterSpacing: 3.0),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rooms')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: SpinKitHourGlass(
              color: Colors.blue[900],
            ));
          }
          return ListView(
            children: snapshot.data.docs.map((documnet) {
              return GestureDetector(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainScreen(
                                  roomname: documnet['roomname'],
                                  userId: user.uid,
                                  creatorID: null,
                                )));
                  },
                  title: Text(documnet['roomname']),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  subtitle: Divider(
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
