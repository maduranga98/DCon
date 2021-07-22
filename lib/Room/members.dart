// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Chats/chat.dart';
import 'package:dconference/Room/addmembers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Members extends StatefulWidget {
  final String roomname;
  final String userId;
  final String creatorID;

  Members(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorID});
  @override
  _MembersState createState() =>
      _MembersState(roomname: roomname, userId: userId, creatorID: creatorID);
}

class _MembersState extends State<Members> {
  final String roomname;
  final String userId;
  final String creatorID;

  _MembersState(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorID});
  @override
  Widget build(BuildContext context) {
    return userId == creatorID
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.black,
              title: Text("Members"),
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("classroom")
                  .doc(roomname)
                  .collection("Members")
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: SpinKitPulse(
                    size: 50.0,
                    color: Colors.red,
                  ));
                }
                return ListView(
                  children: snapshot.data.docs.map<Widget>((documnet) {
                    return Card(
                        color: Colors.brown,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[900],
                            // ignore: missing_required_param
                            backgroundImage:
                                CachedNetworkImageProvider(documnet['url']),
                          ),
                          title: Text(
                            documnet['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                        ));
                  }).toList(),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.group_add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Addmembers(
                              roomname: roomname,
                            )));
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.black,
              title: Text("Members"),
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("classroom")
                  .doc(roomname)
                  .collection("Members")
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: SpinKitPulse(
                    size: 50.0,
                    color: Colors.red,
                  ));
                }
                return ListView(
                  children: snapshot.data.docs.map<Widget>((documnet) {
                    return Card(
                        color: Colors.brown,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[900],
                            // ignore: missing_required_param
                            backgroundImage:
                                CachedNetworkImageProvider(documnet['url']),
                          ),
                          title: Text(
                            documnet['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                          // subtitle: Text(
                          //   DateFormat("dd MMM -hh:mm:aa").format(
                          //       DateTime.fromMillisecondsSinceEpoch(
                          //           int.parse(documnet['date']))),
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontWeight: FontWeight.bold,
                          //     fontStyle: FontStyle.italic,
                          //     fontSize: 10,
                          //   ),
                          // ),
                        ));
                  }).toList(),
                );
              },
            ),
          );
  }
}
