// @dart=2.9
// import 'package:cached_network_image/cached_network_image.dart';

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
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  final String receiverAvvatar;

  Chat({
    Key key,
    @required this.receiverId,
    @required this.receiverName,
    @required this.receiverAvvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvvatar),
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 3.0,
        centerTitle: true,
      ),
      body: ChattingScreen(
        receiverId: receiverId,
        receiverAvatar: receiverAvvatar,
        receivername: receiverName,
      ),
    );
  }
}

class ChattingScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receivername;

  ChattingScreen(
      {Key key,
      @required this.receiverId,
      @required this.receiverAvatar,
      @required this.receivername});
  @override
  _ChattingScreenState createState() => _ChattingScreenState(
      receiverId: receiverId,
      receiverAvatar: receiverAvatar,
      receivername: receivername);
}

class _ChattingScreenState extends State<ChattingScreen> {
  final String receiverId;
  final String receiverAvatar;
  final String receivername;

  _ChattingScreenState(
      {Key key,
      @required this.receiverId,
      @required this.receiverAvatar,
      @required this.receivername});

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  final _picker = ImagePicker();
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;
  String username;
  String useravatar;
  var listMessage;
  Map<String, dynamic> userMap;
  @override
  Void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    //  chatId= user.uid;

    isDisplaySticker = false;
    isLoading = false;

    chatId = "";
    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    User user = FirebaseAuth.instance.currentUser;
    id = user.uid;

    if (id.hashCode <= receiverId.hashCode) {
      chatId = "$id-$receiverId";
    } else {
      chatId = "$receiverId-$id";
    }
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("chatting")
        .doc(chatId)
        .set({
      'chattingWith': receiverId,
      'name': receivername,
      'url': receiverAvatar,
      'chat': chatId,
      "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
    });
    try {
      FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: user.uid)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        print(userMap);
        setState(() {
          username = userMap['name'];
          useravatar = userMap['photourl'];
          FirebaseFirestore.instance
              .collection("users")
              .doc(receiverId)
              .collection("chatting")
              .doc(chatId)
              .set({
            'chattingWith': user.uid,
            'chat': chatId,
            'name': userMap['name'],
            'url': userMap['photoUrl'],
            "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
          });
        });
      });

      print("username:$username");
    } on Exception catch (e) {
      print("get:*****************$e");
    }

    setState(() {});
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
    // ignore: missing_required_param
    return WillPopScope(
      child: Stack(
        children: [
          Column(
            children: [
              // create list of mzgs
              createListMessages(),

              // show stickers
              (isDisplaySticker ? createSticker() : Container()),
              // Input Controllers
              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
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

  createSticker() {
    return Container(
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
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.blue[900], width: 0.5))),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          //picked iamges
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.blue[900],
                onPressed: gettingImage,
              ),
            ),
            color: Colors.white,
          ),
          //emoji icon buttons
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.emoji_emotions),
                color: Colors.blue[900],
                onPressed: gettingStiker,
              ),
            ),
            color: Colors.white,
          ),

          //Text Field
          // ignore: missing_required_param
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.blue[900], fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: Colors.grey)),
                focusNode: focusNode,
              ),
            ),
          ),

          //send massage icon button

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send_sharp),
                color: Colors.blue[900],
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
          )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        color: Colors.white,
      ),
    );
  }

  void gettingStiker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  createListMessages() {
    return Flexible(
        child: chatId == ""
            ? Center(
                child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]),
                ),
              ))
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("mesages")
                    .doc(chatId)
                    .collection(chatId)
                    .orderBy("timestamp", descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[900]),
                      ),
                    );
                  } else {
                    listMessage = snapshot.data.docs;
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        // return
                        //     // Text(snapshot.data.docs[index].data()['content']);
                        //     createItem(index, snapshot.data.docs[index].data());
                        if (snapshot.data.docs[index].data()['idForm'] == id) {
                          print(snapshot.data.docs[index].data()['idFrom']);
                          return Row(
                            children: [
                              snapshot.data.docs[index].data()["type"] == 0
                                  //textR
                                  ? Container(
                                      child: Text(
                                        snapshot.data.docs[index]
                                            .data()["content"],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      padding: EdgeInsets.fromLTRB(
                                          15.0, 10.0, 15.0, 10.0),
                                      width: 200.0,
                                      decoration: BoxDecoration(
                                          color: Colors.blue[900],
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      margin: EdgeInsets.only(
                                          bottom: isLastMsgRight(index)
                                              ? 20.0
                                              : 10.0,
                                          right: 10.0),
                                    )

                                  //image mzg
                                  : snapshot.data.docs[index].data()["type"] ==
                                          1
                                      ? Container(
                                          // ignore: deprecated_member_use
                                          child: FlatButton(
                                            child: Material(
                                              // ignore: missing_required_param
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
                                                    height: 200.0,
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
                                          margin: EdgeInsets.only(
                                              bottom: isLastMsgRight(index)
                                                  ? 20.0
                                                  : 10.0,
                                              right: 10.0),
                                        )
                                      :
                                      //stickers
                                      Container(
                                          child: Image.asset(
                                              "assets/${snapshot.data.docs[index].data()['content']}.gif",
                                              width: 100.0,
                                              height: 100.0,
                                              fit: BoxFit.cover),
                                          margin: EdgeInsets.only(
                                              bottom: isLastMsgRight(index)
                                                  ? 20.0
                                                  : 10.0,
                                              right: 10.0),
                                        ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.end,
                          );
                        }
                        // Receiver mzg left
                        else {
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    isLastMsgLeft(index)
                                        ? Material(
                                            // display receiver profile image
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
                                                width: 35.0,
                                                height: 35.0,
                                                padding: EdgeInsets.all(10.0),
                                              ),
                                              imageUrl: receiverAvatar,
                                              width: 35.0,
                                              height: 35.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(18.0)),
                                            clipBehavior: Clip.hardEdge,
                                          )
                                        : Container(
                                            width: 35.0,
                                          ),
                                    //display Messages
                                    snapshot.data.docs[index].data()["type"] ==
                                            0
                                        //text
                                        ? Container(
                                            child: Text(
                                              snapshot.data.docs[index]
                                                  .data()["content"],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                                15.0, 10.0, 15.0, 10.0),
                                            width: 200.0,
                                            decoration: BoxDecoration(
                                                color: Colors.lightBlueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            margin: EdgeInsets.only(left: 10.0),
                                          )
                                        :
                                        //image mzg
                                        snapshot.data.docs[index]
                                                    .data()["type"] ==
                                                1
                                            ? Container(
                                                // ignore: deprecated_member_use
                                                child: FlatButton(
                                                  child: Material(
                                                    // ignore: missing_required_param
                                                    child: CachedNetworkImage(
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.blue[
                                                                      900]),
                                                        ),
                                                        width: 200.0,
                                                        height: 200.0,
                                                        padding: EdgeInsets.all(
                                                            70.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Material(
                                                        child: Image.asset(
                                                          "assets/image_not_available.jpg",
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8.0)),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      imageUrl: snapshot
                                                          .data.docs[index]
                                                          .data()["content"],
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  onPressed: () {
                                                    print(snapshot
                                                        .data.docs[index]
                                                        .data()["content"]);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => FullPhoto(
                                                                url: snapshot
                                                                        .data
                                                                        .docs[index]
                                                                        .data()[
                                                                    "content"])));
                                                  },
                                                ),
                                                margin:
                                                    EdgeInsets.only(left: 10.0),
                                              )
                                            :
                                            //stickers
                                            Container(
                                                child: Image.asset(
                                                    "assets/${snapshot.data.docs[index].data()['content']}.gif",
                                                    width: 100.0,
                                                    height: 100.0,
                                                    fit: BoxFit.cover),
                                                margin: EdgeInsets.only(
                                                    bottom:
                                                        isLastMsgRight(index)
                                                            ? 20.0
                                                            : 10.0,
                                                    right: 10.0),
                                              ),
                                  ],
                                ),
                                isLastMsgLeft(index)
                                    ? Container(
                                        child: Text(
                                          DateFormat("dd MMM, yyyy -hh:mm:aa")
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      int.parse(snapshot
                                                              .data.docs[index]
                                                              .data()[
                                                          "timestamp"]))),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            margin: EdgeInsets.only(bottom: 10.0),
                          );
                        }
                      },
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  }
                }));
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idForm"] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idForm"] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
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
        storage.ref().child("Chat Images").child(fileName);
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

  void onSendMessage(String contentMsg, int type) {
    //type = 0 its text msg
    // type=1 is iamg file
    //type=2  is stickers
    if (contentMsg != "") {
      textEditingController.clear();
      var docRef = FirebaseFirestore.instance
          .collection("mesages")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().microsecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docRef, {
          "idForm": id,
          "idTo": receiverId,
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
}
