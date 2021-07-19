import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dconference/LMS/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchRooms extends StatefulWidget {
  @override
  _SearchRoomsState createState() => _SearchRoomsState();
}

class _SearchRoomsState extends State<SearchRooms> {
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
        .collection('classroom')
        .where("roomname", isGreaterThanOrEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
      setState(() {
        name = userMap['roomname'];
      });
    });
  }

  emptyTextFormField() {
    _search.clear();
  }

  User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
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
                                    builder: (context) => MainScreen(
                                          roomname: userMap['roomname'],
                                          userId: user.uid,
                                          creatorID: userMap['creatior'],
                                        )));
                          },
                          title: Text(
                            name,
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
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
                                Icons.folder_open,
                                color: Colors.blue[900],
                                size: 200.0,
                              ),
                              Text(
                                "Search Room",
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
}
