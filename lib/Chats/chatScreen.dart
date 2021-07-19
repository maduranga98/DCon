import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/Chats/chat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chatting extends StatefulWidget {
  @override
  _ChattingState createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  String name, email, id, url;
  Map<String, dynamic> userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
      setState(() {
        name = userMap['name'];
        email = userMap['createAt'];
        id = userMap['id'];
        url = userMap['photoUrl'];
      });
    });
  }

  emptyTextFormField() {
    _search.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue[900],
        title: Container(
          margin: EdgeInsets.only(bottom: 4.0),
          child: TextFormField(
            style: TextStyle(fontSize: 18.0, color: Colors.white),
            controller: _search,
            decoration: InputDecoration(
              hintText: "Search ..",
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: emptyTextFormField,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () => onSearch())
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                userMap != null
                    ? GestureDetector(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Chat(
                                          receiverId: userMap['uid'],
                                          receiverName: userMap['name'],
                                          receiverAvvatar: userMap['photoUrl'],
                                        )));
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[900],
                            // ignore: missing_required_param
                            backgroundImage: CachedNetworkImageProvider(url),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Joined:" +
                                DateFormat("dd MMMM,yyyy - hh:mm:aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(email))),
                            style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 14.0,
                                fontStyle: FontStyle.italic),
                          ),
                          trailing: Icon(Icons.chat, color: Colors.blue[900]),
                        ),
                      )
                    : Container(
                        child: Center(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Icon(
                                Icons.group_rounded,
                                color: Colors.blue[900],
                                size: 200.0,
                              ),
                              Text(
                                "Search Users",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 50.0,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  receiverId: userMap['uid'],
                  receiverName: userMap['name'],
                  receiverAvvatar: userMap['photoUrl'],
                )));
  }
}
