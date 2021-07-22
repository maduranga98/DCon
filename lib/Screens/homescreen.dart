// @dart=2.9
import 'package:dconference/Calls/CallPage.dart';
import 'package:dconference/Chats/chattedTiles.dart';
import 'package:dconference/LMS/MainPage.dart';
import 'package:dconference/Screens/accountSetting.dart';
import 'package:dconference/Screens/loadingScreen.dart';
import 'package:dconference/Screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final myController = TextEditingController();
  bool _validateError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        title: Text(
          "D - Con..",
          style: TextStyle(fontFamily: 'Molle', fontSize: 25.0),
        ),
        titleSpacing: 5.0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[900],
              ),
              child: Container(
                child: Column(
                  children: [
                    Material(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/img2.jpeg',
                            width: 300,
                            height: 120,
                          ),
                        )),
                  ],
                ),
              ),
            ),
            CustomListTile(
                Icons.person,
                'Profile',
                () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()))
                    }),
            CustomListTile(
                Icons.chat_bubble_sharp,
                'Chat',
                () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChattedTiles()))
                    }),
            CustomListTile(
                Icons.file_copy,
                'D-LMS',
                () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MainPage()))
                    }),
            CustomListTile(
                Icons.exit_to_app_outlined,
                'LogOut',
                () => {
                      setState(() {
                        FirebaseAuth.instance.signOut();
                      }),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()))
                    }),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Study Group Call',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  controller: myController,
                  decoration: InputDecoration(
                    labelText: 'Channel Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.black45),
                    errorText:
                        _validateError ? 'Channel name is mandatory' : null,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 30)),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: MaterialButton(
                  onPressed: onJoin,
                  height: 40,
                  color: Colors.blueAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Join',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    setState(() {
      myController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(channelName: myController.text),
        ));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}

// ignore: must_be_immutable
class CustomListTile extends StatelessWidget {
  IconData icon;
  String text;
  Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black))),
        child: InkWell(
          splashColor: Colors.red,
          onTap: onTap,
          child: Container(
            // color: Colors.blue[900],
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        text,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Uncial'),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
