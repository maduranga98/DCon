import 'package:dconference/Screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroAuthScreen extends StatefulWidget {
  @override
  _IntroAuthScreenState createState() => _IntroAuthScreenState();
}

class _IntroAuthScreenState extends State<IntroAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome",
          body: "D-CON, work together with one click",
          image: Center(
            child: Image.asset(
              'assets/img1.jpg',
              height: 175,
            ),
          ),
          decoration: PageDecoration(
            bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontFamily: 'Drsugiyama',
                letterSpacing: 3.0),
            titleTextStyle: TextStyle(
                color: Colors.blue[900], fontSize: 30, fontFamily: 'Jacques'),
          ),
        ),
        PageViewModel(
          title: "Join or start meetings",
          body: "Easy to use interface, joint or start in a fast time",
          image: Center(
            child: Image.asset(
              'assets/conference.png',
              height: 175,
            ),
          ),
          decoration: PageDecoration(
            bodyTextStyle: TextStyle(
                letterSpacing: 3.0,
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Drsugiyama'),
            titleTextStyle: TextStyle(
                color: Colors.blue[900], fontSize: 20, fontFamily: 'Uncial'),
          ),
        ),
        PageViewModel(
          title: "Security",
          body:
              "Your security is important for us. Our server are secure and reliable",
          image: Center(
            child: Image.asset(
              'assets/secure.jpg',
              height: 175,
            ),
          ),
          decoration: PageDecoration(
            bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 30,
                letterSpacing: 3.0,
                fontFamily: 'Drsugiyama'),
            titleTextStyle: TextStyle(
                color: Colors.blue[900], fontSize: 20, fontFamily: 'Uncial'),
          ),
        ),
        // PageViewModel(
        //   title: "Quick guid",
        //   body:
        //       "Enter your data to the 'Profile', then find the user you want to chat in the 'Chat'.",
        //   image: Center(
        //     child: Image.asset(
        //       'assets/how.png',
        //       height: 175,
        //     ),
        //   ),
        //   decoration: PageDecoration(
        //     bodyTextStyle: TextStyle(
        //         color: Colors.blue[900], fontSize: 20, fontFamily: 'Fascinate'),
        //     titleTextStyle: TextStyle(
        //         color: Colors.blue[900], fontSize: 20, fontFamily: 'Uncial'),
        //   ),
        // ),
      ],
      onDone: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      },
      onSkip: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      },
      showDoneButton: true,
      showSkipButton: true,
      skip: const Icon(
        Icons.skip_next,
        size: 45,
      ),
      next: const Icon(Icons.arrow_forward_ios),
      done: Text(
        "Done",
        style: TextStyle(color: Colors.blue[900], fontSize: 20),
      ),
    );
  }
}
