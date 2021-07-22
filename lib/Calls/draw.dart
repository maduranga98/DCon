import 'package:flutter/material.dart';
import 'package:rich_text_editor/rich_text_editor.dart';

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  SpannableTextEditingController _controller = SpannableTextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
