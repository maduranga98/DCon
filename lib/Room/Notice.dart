// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class Notice extends StatefulWidget {
  final String roomname;
  final String userId;
  final String creatorId;

  Notice(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorId});
  @override
  _NoticeState createState() =>
      _NoticeState(roomname: roomname, userId: userId, creatorId: creatorId);
}

class _NoticeState extends State<Notice> {
  final String roomname;
  final String userId;
  final String creatorId;

  _NoticeState(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorId});
  TextEditingController notice = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return userId == creatorId
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              title: Text("Announcement"),
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("classroom")
                  .doc(roomname)
                  .collection("notice")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: SpinKitPulse(
                    color: Colors.red,
                  ));
                }
                return ListView(
                  children: snapshot.data.docs.map<Widget>((documnet) {
                    return Card(
                        color: Color(0xFF550066c),
                        child: ListTile(
                          title: Text(
                            documnet['context'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat("dd MMM -hh:mm:aa").format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(documnet['date']))),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                            ),
                          ),
                        ));
                  }).toList(),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add_comment),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          height: 350,
                          width: 200,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter the Notice",
                                    hintStyle: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blue[900]),
                                  ),
                                  controller: notice,
                                  maxLines: 10,
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
                                                        BorderRadius.circular(
                                                            16)),
                                                elevation: 0,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: 100,
                                                          bottom: 16,
                                                          left: 16,
                                                          right: 16),
                                                      margin: EdgeInsets.only(
                                                          top: 16),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(17),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 10.0,
                                                              offset: Offset(
                                                                  0.0, 10.0),
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
                                                            ("You successfully publish the notice"),
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
                                                              child: Text(
                                                                  "Confirm"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                String name;
                                                                setState(() {
                                                                  name = notice
                                                                      .text;
                                                                  print(name);
                                                                });

                                                                try {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "classroom")
                                                                      .doc(
                                                                          roomname)
                                                                      .collection(
                                                                          "notice")
                                                                      .doc()
                                                                      .set({
                                                                    "context":
                                                                        name,
                                                                    "date": DateTime
                                                                            .now()
                                                                        .microsecondsSinceEpoch
                                                                        .toString(),
                                                                  });
                                                                } catch (e) {
                                                                  print(
                                                                      "Erroe:$e"); // TODO
                                                                }
                                                                notice.clear();
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
                                                        backgroundImage:
                                                            AssetImage(
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
            ),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              title: Text("Announcement"),
            ),
            //if ekak dala current user = nam creator id ekak pennana nathan thawa ekak
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("classroom")
                  .doc(roomname)
                  .collection("notice")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data.docs.map<Widget>((documnet) {
                    return Card(
                        color: Color(0xFF550066c),
                        child: ListTile(
                          title: Text(
                            documnet['context'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat("dd MMM -hh:mm:aa").format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(documnet['date']))),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                            ),
                          ),
                        ));
                  }).toList(),
                );
              },
            ));
  }
}
