// @dart=2.9
import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Screens/fullphoto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class GroupChat extends StatefulWidget {
  final String roomname;
  final String userId;
  GroupChat({
    Key key,
    @required this.roomname,
    @required this.userId,
  });
  @override
  _GroupChatState createState() =>
      _GroupChatState(roomname: roomname, userId: userId);
}

class _GroupChatState extends State<GroupChat> {
  final String roomname;
  final String userId;
  _GroupChatState({
    Key key,
    @required this.roomname,
    @required this.userId,
  });

  @override
  User user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            // child: CircleAvatar(
            //   backgroundColor: Colors.black,
            //   backgroundImage: CachedNetworkImageProvider(url),
            // ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "'${roomname}' Group Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 3.0,
        centerTitle: true,
      ),
      body: GChattingScreen(
        roomname: roomname,
        userId: userId,
      ),
    );
  }
}

class GChattingScreen extends StatefulWidget {
  final String roomname;
  final String userId;

  GChattingScreen({
    Key key,
    @required this.roomname,
    @required this.userId,
  });
  @override
  _GChattingScreenState createState() =>
      _GChattingScreenState(roomname: roomname, userId: userId);
}

class _GChattingScreenState extends State<GChattingScreen> {
  final String roomname;
  final String userId;
  _GChattingScreenState({
    Key key,
    @required this.roomname,
    @required this.userId,
  });
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final ScrollController StickerScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  String name, url;
  var listMessage;
  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  final _picker = ImagePicker();
  String imageUrl;
  @override
  Void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    //  chatId= user.uid;

    isDisplaySticker = false;
    isLoading = false;
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        // hide the sticker when keypad appers
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          name = snapshot['name'];
          url = snapshot['photoUrl'];
        });
      } else {
        return CircularProgressIndicator();
      }
    });
    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: [
          Column(
            children: [
              createListMessages(),
              // show stickers
              (isDisplaySticker ? createSticker() : Container()),
              createInput()
            ],
          ),
          createLoading(),
        ],
      ),
    );
  }

  createListMessages() {
    return Flexible(
        child: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("classroom")
          .doc(roomname)
          .collection("chat")
          .orderBy("timestamp", descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          listMessage = snapshot.data.docs;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              if (snapshot.data.docs[index].data()['idForm'] == userId) {
                return Row(
                  children: [
                    snapshot.data.docs[index].data()["type"] == 0
                        //textR
                        ? Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data.docs[index].data()["content"],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Uncial'),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    DateFormat("hh:mm").format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(snapshot.data.docs[index]
                                                .data()["timestamp"]))),
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                )
                              ],
                            ),
                            padding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20.0 : 3.0,
                                right: 10.0),
                          )

                        //image mzg
                        : snapshot.data.docs[index].data()["type"] == 1
                            ? Container(
                                child: Container(
                                  color: Colors.grey[700],
                                  height: 230,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // ignore: deprecated_member_use
                                      FlatButton(
                                        child: Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.blue[900]),
                                              ),
                                              width: 200.0,
                                              height: 200.0,
                                              padding: EdgeInsets.all(70.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Material(
                                              child: Image.asset(
                                                "assets/image_not_available.jpg",
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                              clipBehavior: Clip.hardEdge,
                                            ),
                                            imageUrl: snapshot.data.docs[index]
                                                .data()["content"],
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FullPhoto(
                                                          url: snapshot.data
                                                                  .docs[index]
                                                                  .data()[
                                                              "content"])));
                                        },
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          DateFormat("hh:mm").format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(snapshot
                                                      .data.docs[index]
                                                      .data()["timestamp"]))),
                                          style:
                                              TextStyle(color: Colors.white60),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                margin: EdgeInsets.only(
                                    bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                    right: 10.0),
                              )
                            :
                            //stickers
                            Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                        "assets/${snapshot.data.docs[index].data()['content']}.gif",
                                        width: 100.0,
                                        height: 100.0,
                                        fit: BoxFit.cover),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        DateFormat("hh:mm").format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(snapshot
                                                    .data.docs[index]
                                                    .data()["timestamp"]))),
                                        style: TextStyle(
                                            color: Colors.white60,
                                            backgroundColor: Colors.grey[700]),
                                      ),
                                    )
                                  ],
                                ),
                                margin: EdgeInsets.only(
                                    bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                    right: 10.0),
                              ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                );
              } else {
                return Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          isLastMsgLeft(index)
                              ? Material(
                                  // display receiver profile image
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blue[900]),
                                      ),
                                      width: 35.0,
                                      height: 35.0,
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                    imageUrl:
                                        snapshot.data.docs[index].data()['url'],
                                    width: 35.0,
                                    height: 35.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Container(
                                  child: Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.blue[900]),
                                        ),
                                        width: 35.0,
                                        height: 35.0,
                                        padding: EdgeInsets.all(10.0),
                                      ),
                                      imageUrl: snapshot.data.docs[index]
                                          .data()['url'],
                                      width: 35.0,
                                      height: 35.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                ),
                          //display Messages
                          snapshot.data.docs[index].data()["type"] == 0
                              //text
                              ? Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data.docs[index]
                                            .data()['name'],
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Molle'),
                                      ),
                                      Text(
                                        snapshot.data.docs[index]
                                            .data()["content"],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Uncial'),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          DateFormat("hh:mm").format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(snapshot
                                                      .data.docs[index]
                                                      .data()["timestamp"]))),
                                          style:
                                              TextStyle(color: Colors.white60),
                                        ),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                      15.0, 10.0, 15.0, 10.0),
                                  width: 200.0,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[850],
                                      borderRadius: BorderRadius.circular(8.0)),
                                  margin:
                                      EdgeInsets.only(left: 10.0, bottom: 1.5),
                                )
                              :
                              //image mzg
                              snapshot.data.docs[index].data()["type"] == 1
                                  ? Container(
                                      height: 250.0,
                                      color: Colors.grey[850],
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data.docs[index]
                                                .data()['name'],
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Molle'),
                                          ),
                                          // ignore: missing_required_param
                                          FlatButton(
                                            child: Material(
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    Container(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.blue[900]),
                                                  ),
                                                  width: 200.0,
                                                  height: 200.0,
                                                  padding: EdgeInsets.all(70.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Material(
                                                  child: Image.asset(
                                                    "assets/image_not_available.jpg",
                                                    width: 200.0,
                                                    height: 180.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8.0)),
                                                  clipBehavior: Clip.hardEdge,
                                                ),
                                                imageUrl: snapshot
                                                    .data.docs[index]
                                                    .data()["content"],
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                              clipBehavior: Clip.hardEdge,
                                            ),
                                            onPressed: () {
                                              print(snapshot.data.docs[index]
                                                  .data()["content"]);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullPhoto(
                                                              url: snapshot.data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "content"])));
                                            },
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              DateFormat("hh:mm").format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      int.parse(snapshot
                                                              .data.docs[index]
                                                              .data()[
                                                          "timestamp"]))),
                                              style: TextStyle(
                                                  color: Colors.white60),
                                            ),
                                          ),
                                        ],
                                      ),
                                      margin: EdgeInsets.only(left: 10.0),
                                    )
                                  :
                                  //stickers
                                  Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                              "assets/${snapshot.data.docs[index].data()['content']}.gif",
                                              width: 100.0,
                                              height: 100.0,
                                              fit: BoxFit.cover),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                                DateFormat("hh:mm").format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        int.parse(snapshot.data
                                                                .docs[index]
                                                                .data()[
                                                            "timestamp"]))),
                                                style: TextStyle(
                                                    color: Colors.white60,
                                                    backgroundColor:
                                                        Colors.grey[850])),
                                          ),
                                        ],
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: isLastMsgRight(index)
                                              ? 20.0
                                              : 10.0,
                                          right: 10.0),
                                    ),
                        ],
                      ),
                      isLastMsgLeft(index)
                          ? Container(
                              child: Text(
                                DateFormat("dd MMM, yyyy -hh:mm:aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(snapshot.data.docs[index]
                                            .data()["timestamp"]))),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                              margin: EdgeInsets.only(
                                  left: 50.0, top: 50.0, bottom: 5.0),
                            )
                          : Container()
                    ],
                  ),
                );
              }
            },
            itemCount: snapshot.data.docs.length,
            reverse: true,
            controller: listScrollController,
          );
        }
      },
    ));
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idForm"] == userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idForm"] != userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  createSticker() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // first row
            Row(
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi1", 2),
                    child: Image.asset(
                      "assets/mimi1.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi2", 2),
                    child: Image.asset(
                      "assets/mimi2.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi3", 2),
                    child: Image.asset(
                      "assets/mimi3.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),

            //second row

            Row(
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi4", 2),
                    child: Image.asset(
                      "assets/mimi4.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi5", 2),
                    child: Image.asset(
                      "assets/mimi5.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi6", 2),
                    child: Image.asset(
                      "assets/mimi6.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),

            // third row

            Row(
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi7", 2),
                    child: Image.asset(
                      "assets/mimi7.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi8", 2),
                    child: Image.asset(
                      "assets/mimi8.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi9", 2),
                    child: Image.asset(
                      "assets/mimi9.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            //fourth row
            Row(
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi10", 2),
                    child: Image.asset(
                      "assets/mimi10.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi11", 2),
                    child: Image.asset(
                      "assets/mimi11.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi12", 2),
                    child: Image.asset(
                      "assets/mimi12.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            //fifth row
            Row(
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => onSendMessage("mimi13", 2),
                    child: Image.asset(
                      "assets/mimi13.gif",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    )),
                // ignore: deprecated_member_use
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.blue[900], width: 0.5))),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  createLoading() {
    return Positioned(
        child: isLoading ? CircularProgressIndicator() : Container());
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          //pick images button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.blueAccent,
                onPressed: gettingImage,
              ),
            ),
          ),
          //emoji button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.blueAccent,
                onPressed: gettingStiker,
              ),
            ),
          ),
          //pick images button

          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.blue[900], fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: Colors.grey)),
                //focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send_sharp),
                color: Colors.blue[900],
                onPressed: () => {onSendMessage(textEditingController.text, 0)},
              ),
            ),
          )
        ],
      ),
    );
  }

  void gettingStiker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  void onSendMessage(String contentMsg, int type) {
    //type = 0 its text msg
    // type=1 is iamg file
    //type=2  is stickers
    if (contentMsg != "") {
      textEditingController.clear();
      var docRef = FirebaseFirestore.instance
          .collection("classroom")
          .doc(roomname)
          .collection("chat")
          .doc(DateTime.now().microsecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docRef, {
          "idForm": userId,
          "name": name,
          "url": url,
          "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
          "content": contentMsg,
          "type": type,
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // need to add toast
      print("mzg didn't send");
    }
  }

  Future gettingImage() async {
    PickedFile image = await _picker.getImage(source: ImageSource.gallery);

    if (image != null) {
      isLoading = true;
      this.imageFile = File(image.path);
    }
    uploadImageFile();
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference storagereference =
        storage.ref().child("Classroom").child(roomname).child(fileName);
    UploadTask storageUploadTask = storagereference.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await storageUploadTask;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
    });
  }
}
