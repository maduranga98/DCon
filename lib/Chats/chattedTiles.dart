// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Chats/chat.dart';
import 'package:dconference/Chats/chatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ChattedTiles extends StatefulWidget {
  @override
  _ChattedTilesState createState() => _ChattedTilesState();
}

class _ChattedTilesState extends State<ChattedTiles> {
  @override
  User user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        title: Text(
          "D-Con Chat",
          style: TextStyle(fontFamily: 'Molle'),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Chatting()));
              })
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection("chatting")
            .orderBy("timestamp", descending: true)
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
                            builder: (context) => Chat(
                                  receiverId: documnet['chattingWith'],
                                  receiverName: documnet['name'],
                                  receiverAvvatar: documnet['url'],
                                )));
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    // ignore: missing_required_param
                    backgroundImage:
                        CachedNetworkImageProvider(documnet['url']),
                  ),
                  title: Text(
                    documnet['name'],
                    style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Molle'),
                  ),
                  subtitle: Text(
                    "Last Online:" +
                        DateFormat("hh:mm:aa").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(documnet['timestamp']))),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pinyon'),
                  ),
                  trailing: Icon(Icons.chat, color: Colors.blue[900]),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
