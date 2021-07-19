import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/LMS/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreatedRooms extends StatefulWidget {
  @override
  _CreatedRoomsState createState() => _CreatedRoomsState();
}

class _CreatedRoomsState extends State<CreatedRooms> {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        
        title: Text(
          "Created Rooms",
          style: TextStyle(fontSize: 15, fontFamily: 'Fascinate',letterSpacing: 3.0),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('classroom')
            .where("creator", isEqualTo: user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: SpinKitHourGlass(
              color: Colors.blue,
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
                                  creatorID: documnet['creator'],
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
