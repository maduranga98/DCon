import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Room/PDFVIewer.dart';
import 'package:dconference/services/Model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsPage extends StatefulWidget {
  final String roomname;
  final String userId;
  final String creatorID;
  DocumentsPage(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorID});
  @override
  _DocumentsPageState createState() => _DocumentsPageState(
      roomname: roomname, creatorID: creatorID, userId: userId);
}

class _DocumentsPageState extends State<DocumentsPage> {
  final String roomname;
  final String userId;
  final String creatorID;
  _DocumentsPageState(
      {Key key,
      @required this.roomname,
      @required this.userId,
      @required this.creatorID});
  List<Modal> itemList = List();
  final mainReference = FirebaseDatabase.instance.reference().child('room0');
  TextEditingController comment = TextEditingController();
  File file;
  String fileUrl = "";
  Future getFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result.files.single.path);
      uploadFileToFirebace();
    } else {
      uploadFileToFirebace();
    }
  }

  void documentFileUpload(String str) {
    mainReference
        .child(roomname)
        .set({"PDF": str, "FileName": "My New Book"}).then(
            (v) => print("Store Successfully"));
  }

  Future uploadFileToFirebace() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child("classroom").child(roomname);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot storageTaskSnapshot = await uploadTask;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      print(downloadUrl);
      fileUrl = downloadUrl;
      documentFileUpload(fileUrl);
      // User user = FirebaseAuth.instance.currentUser;
      setState(() {
        FirebaseFirestore.instance
            .collection("classroom")
            .doc(roomname)
            .collection('Documents')
            .doc()
            .set({
          'fileUrl': fileUrl,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'content': comment.text
        });
      });
    });
  }

//************************************************************need to add caption *********************//
  @override
  Widget build(BuildContext context) {
    return userId == creatorID
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              title: Text("Documents"),
              centerTitle: true,
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("classroom")
                    .doc(roomname)
                    .collection("Documents")
                    .orderBy("timestamp", descending: true)
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
                      return Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: GestureDetector(
                          onTap: () {
                            String passsData = documnet['fileUrl'];

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerpage(
                                    file: passsData,
                                  ),
                                ));
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage("assets/qw.jpg"),
                                        fit: BoxFit.cover)),
                              ),
                              Center(
                                child: Container(
                                  height: 140,
                                  child: Card(
                                    margin: EdgeInsets.all(18),
                                    elevation: 7.0,
                                    child: Center(
                                      child: Text(documnet['content']),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.file_upload),
              onPressed: () async {
                //getFile();
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          color: Colors.black45,
                          height: 300,
                          width: 300,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Enter the comment here*',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    hintText: "Enter the comment here*",
                                    hintStyle: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blue[900]),
                                  ),
                                  controller: comment,
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                SizedBox(
                                  width: 320.0,
                                  child: RaisedButton(
                                    color: Color(0xFF1BC0C5),
                                    child: Text(
                                      "Select the PDF file",
                                      style: TextStyle(
                                          fontFamily: 'Drsugiyama',
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          letterSpacing: 3.0),
                                    ),
                                    onPressed: () {
                                      return getFile();
                                      setState(() {
                                        fileUrl = comment.text;
                                        print(fileUrl);
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                SizedBox(
                                  width: 320.0,
                                  // ignore: deprecated_member_use
                                  child: RaisedButton(
                                      color: Color(0xFF1BC0C5),
                                      child: Text(
                                        "Upload",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Drsugiyama',
                                            letterSpacing: 3.0,
                                            fontSize: 25.0),
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
                                                                fontSize: 30.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Pinyon'),
                                                          ),
                                                          SizedBox(
                                                            height: 16.0,
                                                          ),
                                                          Text(
                                                            ("You successfully upload the file"),
                                                            style: TextStyle(
                                                                fontSize: 20.0,
                                                                fontFamily:
                                                                    'Molle'),
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
                                                                  // name =
                                                                  //     roomName.text;
                                                                  print(name);
                                                                });

                                                                comment.clear();
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
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              title: Text("Documents"),
              centerTitle: true,
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("classroom")
                    .doc(roomname)
                    .collection("Documents")
                    .orderBy("timestamp", descending: true)
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
                      return Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: GestureDetector(
                          onTap: () {
                            String passsData = documnet['fileUrl'];

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerpage(
                                    file: passsData,
                                  ),
                                ));
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage("assets/qw.jpg"),
                                        fit: BoxFit.cover)),
                              ),
                              Center(
                                child: Container(
                                  height: 140,
                                  child: Card(
                                    margin: EdgeInsets.all(18),
                                    elevation: 7.0,
                                    child: Center(
                                      child: Text(documnet['content']),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
          );
  }

  // void openPDF(BuildContext context, File file) => Navigator.of(context)
  //     .push(MaterialPageRoute(builder: (context) => PDFViewerpage(file: file)));
}
