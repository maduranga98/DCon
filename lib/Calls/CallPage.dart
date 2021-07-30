import 'package:flutter/material.dart';
import '../utils/AppID.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:rich_text_editor/rich_text_editor.dart';

class CallPage extends StatefulWidget {
  final String? channelName;

  const CallPage({this.channelName});

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  SpannableTextEditingController _controller = SpannableTextEditingController();

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Widget? inputWidg;

  Widget noteWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scrollbar(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
        ),
        StyleToolbar(
          controller: _controller,
        ),
        // Container(
        //   child: _toolbar(),
        // ),
      ],
    );
  }

  Widget videoWidget() {
    return Center(
      child: Stack(
        children: <Widget>[
          _viewRows(),
          _toolbar(),
        ],
      ),
    );
  }

  int? y;
  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    inputWidg = videoWidget();
  }

  Future<void> initialize() async {
    if (appID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    await _engine.joinChannel(null, widget.channelName!, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(appID);
    await _engine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //mute button
          RawMaterialButton(
            onPressed: () {
              setState(() {
                _onToggleMute();
              });
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          //end call button
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          //camera on
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: inputWidg,
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  inputWidg = noteWidget();
                });
              },
              child: const Icon(Icons.note),
              backgroundColor: Colors.green,
            ),
          ),
          Container(
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  inputWidg = videoWidget();
                });
              },
              child: const Icon(Icons.video_call),
              backgroundColor: Colors.blueGrey,
            ),
          )
        ],
      ),
    );
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
    // return Container(width: 150, height: 100, child: view);
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: GridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: 1,
        children: wrappedViews,
      ),
    );
  }

  // Widget _expandedVideoRow(List<Widget> views) {
  //   final wrappedViews = views.map<Widget>(_videoView).toList();
  //   return Expanded(
  //     child: GridView.count(
  //       scrollDirection: Axis.horizontal,
  //       crossAxisCount: 1,
  //       children: wrappedViews,
  //     ),
  //   );
  // }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Row(
          children: <Widget>[
            // _videoView(views[0])
            _expandedVideoRow([views[0]])
          ],
        ));
      case 2:
        return Container(
            child: Row(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Row(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Row(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}

/// Video view row wrapper:GRID
// Widget _expandedVideoRow(List<Widget> views) {
//   final wrappedViews = views.map<Widget>(_videoView).toList();
//   return Expanded(
//     child: GridView.count(
//       scrollDirection: Axis.horizontal,
//       crossAxisCount: 1,
//       children: wrappedViews,
//     ),
//   );
// }

// import 'package:flutter/material.dart';
// import '../utils/AppID.dart';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:rich_text_editor/rich_text_editor.dart';

// class CallPage extends StatefulWidget {
//   final String? channelName;

//   const CallPage({this.channelName});

//   @override
//   _CallPageState createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   SpannableTextEditingController _controller = SpannableTextEditingController();

//   static final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   late RtcEngine _engine;

//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//     _engine.leaveChannel();
//     _engine.destroy();
//     super.dispose();
//   }

//   //DIFF
//   Widget? inputWidg;

//   @override
//   void initState() {
//     super.initState();
//     // initialize agora sdk
//     initialize();
//     inputWidg = noteWidget();
//   }

//   Future<void> initialize() async {
//     if (appID.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     // await _engine.enableWebSdkInteroperability(true);
//     await _engine.joinChannel(null, widget.channelName!, null, 0);
//   }

//   /// Create agora sdk instance and initialize
//   Future<void> _initAgoraRtcEngine() async {
//     _engine = await RtcEngine.create(appID);
//     await _engine.enableVideo();
//   }

//   /// Add agora event handlers
//   void _addAgoraEventHandlers() {
//     _engine.setEventHandler(RtcEngineEventHandler(
//       error: (code) {
//         setState(() {
//           final info = 'onError: $code';
//           _infoStrings.add(info);
//         });
//       },
//       joinChannelSuccess: (channel, uid, elapsed) {
//         setState(() {
//           final info = 'onJoinChannel: $channel, uid: $uid';
//           _infoStrings.add(info);
//         });
//       },
//       leaveChannel: (stats) {
//         setState(() {
//           _infoStrings.add('onLeaveChannel');
//           _users.clear();
//         });
//       },
//       userJoined: (uid, elapsed) {
//         setState(() {
//           final info = 'userJoined: $uid';
//           _infoStrings.add(info);
//           _users.add(uid);
//         });
//       },
//       userOffline: (uid, reason) {
//         setState(() {
//           final info = 'userOffline: $uid , reason: $reason';
//           _infoStrings.add(info);
//           _users.remove(uid);
//         });
//       },
//       firstRemoteVideoFrame: (uid, width, height, elapsed) {
//         setState(() {
//           final info = 'firstRemoteVideoFrame: $uid';
//           _infoStrings.add(info);
//         });
//       },
//     ));
//   }

//   /// Toolbar layout
//   Widget _toolbar() {
//     return Container(
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           //mute button
//           RawMaterialButton(
//             onPressed: _onToggleMute,
//             child: Icon(
//               muted ? Icons.mic_off : Icons.mic,
//               color: muted ? Colors.white : Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: muted ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           ),
//           //end call button
//           RawMaterialButton(
//             onPressed: () => _onCallEnd(context),
//             child: Icon(
//               Icons.call_end,
//               color: Colors.white,
//               size: 35.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.redAccent,
//             padding: const EdgeInsets.all(15.0),
//           ),
//           //camera on
//           RawMaterialButton(
//             onPressed: _onSwitchCamera,
//             child: Icon(
//               Icons.switch_camera,
//               color: Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           )
//         ],
//       ),
//     );
//   }

//   Widget videoWidget() {
//     return Center(
//       child: Stack(
//         children: <Widget>[
//           _viewRows(),
//           _toolbar(),
//         ],
//       ),
//     );
//   }

//   Widget noteWidget() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         Container(
//           child: _viewRows(),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Scrollbar(
//               child: TextField(
//                 controller: _controller,
//                 keyboardType: TextInputType.text,
//                 maxLines: null,
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//                   filled: false,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         StyleToolbar(
//           controller: _controller,
//         ),
//         // Container(
//         //   child: _toolbar(),
//         // ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: inputWidg,

//       //floating action buttons
//       floatingActionButton: Wrap(
//         direction: Axis.horizontal,
//         children: [
//           Container(
//             child: FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   inputWidg = noteWidget();
//                 });
//               },
//               child: const Icon(Icons.note),
//               backgroundColor: Colors.green,
//             ),
//           ),
//           Container(
//             child: FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   inputWidg = videoWidget();
//                 });
//               },
//               child: const Icon(Icons.video_call),
//               backgroundColor: Colors.blueGrey,
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   /// Helper function to get list of native views
//   List<Widget> _getRenderViews() {
//     final List<StatefulWidget> list = [];
//     list.add(RtcLocalView.SurfaceView());
//     _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
//     return list;
//   }

//   /// Video view wrapper
//   Widget _videoView(view) {
//     // return Container(width: 150, height: 100, child: view);
//     return Expanded(child: Container(child: view));
//   }

//   Widget _expandedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Expanded(
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }

//   /// Video view row wrapper:GRID
//   // Widget _expandedVideoRow(List<Widget> views) {
//   //   final wrappedViews = views.map<Widget>(_videoView).toList();
//   //   return Expanded(
//   //     child: GridView.count(
//   //       scrollDirection: Axis.horizontal,
//   //       crossAxisCount: 1,
//   //       children: wrappedViews,
//   //     ),
//   //   );
//   // }

//   /// Video layout wrapper
//   Widget _viewRows() {
//     final views = _getRenderViews();
//     switch (views.length) {
//       case 1:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             // _videoView(views[0])
//             _expandedVideoRow([views[0]])
//           ],
//         ));
//       case 2:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             _expandedVideoRow([views[0]]),
//             _expandedVideoRow([views[1]])
//           ],
//         ));
//       case 3:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 3))
//           ],
//         ));
//       case 4:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 4))
//           ],
//         ));
//       default:
//     }
//     return Container();
//   }

//   void _onCallEnd(BuildContext context) {
//     Navigator.pop(context);
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }

//   void _onSwitchCamera() {
//     _engine.switchCamera();
//   }
// }

// class Draw extends StatefulWidget {
//   @override
//   _DrawState createState() => _DrawState();
// }

// class _DrawState extends State<Draw> {
//   SpannableTextEditingController _controller = SpannableTextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Column(
//           children: <Widget> [
//               Container(
//               child: _viewRows(),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Scrollbar(
//                   child: TextField(
//                     controller: _controller,
//                     keyboardType: TextInputType.text,
//                     maxLines: null,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       filled: false,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             StyleToolbar(
//               controller: _controller,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CallPage extends StatefulWidget {
//   final String channelName;

//   const CallPage({this.channelName});

//   @override
//   _CallPageState createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   SpannableTextEditingController _controller = SpannableTextEditingController();

//   static final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   RtcEngine _engine;

//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//     _engine.leaveChannel();
//     _engine.destroy();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // initialize agora sdk
//     initialize();
//   }

//   Future<void> initialize() async {
//     if (appID.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     // await _engine.enableWebSdkInteroperability(true);
//     await _engine.joinChannel(null, widget.channelName, null, 0);
//   }

//   /// Create agora sdk instance and initialize
//   Future<void> _initAgoraRtcEngine() async {
//     _engine = await RtcEngine.create(appID);
//     await _engine.enableVideo();
//   }

//   /// Add agora event handlers
//   void _addAgoraEventHandlers() {
//     _engine.setEventHandler(RtcEngineEventHandler(
//       error: (code) {
//         setState(() {
//           final info = 'onError: $code';
//           _infoStrings.add(info);
//         });
//       },
//       joinChannelSuccess: (channel, uid, elapsed) {
//         setState(() {
//           final info = 'onJoinChannel: $channel, uid: $uid';
//           _infoStrings.add(info);
//         });
//       },
//       leaveChannel: (stats) {
//         setState(() {
//           _infoStrings.add('onLeaveChannel');
//           _users.clear();
//         });
//       },
//       userJoined: (uid, elapsed) {
//         setState(() {
//           final info = 'userJoined: $uid';
//           _infoStrings.add(info);
//           _users.add(uid);
//         });
//       },
//       userOffline: (uid, reason) {
//         setState(() {
//           final info = 'userOffline: $uid , reason: $reason';
//           _infoStrings.add(info);
//           _users.remove(uid);
//         });
//       },
//       firstRemoteVideoFrame: (uid, width, height, elapsed) {
//         setState(() {
//           final info = 'firstRemoteVideoFrame: $uid';
//           _infoStrings.add(info);
//         });
//       },
//     ));
//   }

//   /// Toolbar layout
//   Widget _toolbar() {
//     return Container(
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           //mute button
//           RawMaterialButton(
//             onPressed: _onToggleMute,
//             child: Icon(
//               muted ? Icons.mic_off : Icons.mic,
//               color: muted ? Colors.white : Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: muted ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           ),
//           //end call button
//           RawMaterialButton(
//             onPressed: () => _onCallEnd(context),
//             child: Icon(
//               Icons.call_end,
//               color: Colors.white,
//               size: 35.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.redAccent,
//             padding: const EdgeInsets.all(15.0),
//           ),
//           //camera on
//           RawMaterialButton(
//             onPressed: _onSwitchCamera,
//             child: Icon(
//               Icons.switch_camera,
//               color: Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             child: _viewRows(),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Scrollbar(
//                 child: TextField(
//                   controller: _controller,
//                   keyboardType: TextInputType.text,
//                   maxLines: null,
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     filled: false,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           StyleToolbar(
//             controller: _controller,
//           ),
//           // Container(
//           //   child: _toolbar(),
//           // ),
//         ],
//       ),
//     );

//     // return Scaffold(
//     //   // appBar: AppBar(
//     //   //   toolbarHeight: 10,
//     //   //   title: Text(' Dconn Meeting Calling'),
//     //   // ),
//     // backgroundColor: Colors.black,
//     // body: Column(
//     //   children: <Widget>[
//     //     _viewRows(),
//     //     _toolbar(),
//     //   ],
//     // ),
//     // );
//   }

//   /// Helper function to get list of native views
//   List<Widget> _getRenderViews() {
//     final List<StatefulWidget> list = [];
//     list.add(RtcLocalView.SurfaceView());
//     _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
//     return list;
//   }

//   /// Video view wrapper
//   Widget _videoView(view) {
//     return Container(width: 150, height: 100, child: view);
//     // return Expanded(child: Container(child: view));
//   }

//   /// Video view row wrapper
//   Widget _expandedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Expanded(
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }

//   /// Video layout wrapper
//   Widget _viewRows() {
//     final views = _getRenderViews();
//     switch (views.length) {
//       case 1:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             // _videoView(views[0])
//             _expandedVideoRow([views[0]])
//           ],
//         ));
//       case 2:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             _expandedVideoRow([views[0]]),
//             _expandedVideoRow([views[1]])
//           ],
//         ));
//       case 3:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 3))
//           ],
//         ));
//       case 4:
//         return Container(
//             child: Row(
//           children: <Widget>[
//             _expandedVideoRow(views.sublist(0, 2)),
//             _expandedVideoRow(views.sublist(2, 4))
//           ],
//         ));
//       default:
//     }
//     return Container();
//   }

//   void _onCallEnd(BuildContext context) {
//     Navigator.pop(context);
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }

//   void _onSwitchCamera() {
//     _engine.switchCamera();
//   }
// }
