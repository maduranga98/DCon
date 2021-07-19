import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'package:path/path.dart';

class PDFViewerpage extends StatefulWidget {
  final String file;

  const PDFViewerpage({Key key, @required this.file});
  @override
  _PDFViewerpageState createState() => _PDFViewerpageState(file: file);
}

class _PDFViewerpageState extends State<PDFViewerpage> {
  final String file;

  int pages = 0;
  int indexPage = 0;

  _PDFViewerpageState({Key key, @required this.file});
  @override
  Widget build(BuildContext context) {
    // final name = basename(widget.file.path);
    final text = '${indexPage + 1} of $pages';
    return Scaffold(
      appBar: AppBar(
          //    title: Text(name),
          // actions: pages >= 2
          //     ? [
          //         Center(child: Text(text)),
          //         IconButton(
          //           icon: Icon(Icons.chevron_left, size: 32),
          //           onPressed: () {
          //             final page = indexPage == 0 ? pages : indexPage - 1;
          //           },
          //         ),
          //         IconButton(
          //           icon: Icon(Icons.chevron_right, size: 32),
          //           onPressed: () {
          //             final page = indexPage == pages - 1 ? 0 : indexPage + 1;
          //             //  controller.setPage(page);
          //           },
          //         ),
          //       ]
          //     : null,
          ),
      // body: Center(
      //   child: PDF(nightMode: true).cachedFromUrl(file),
      // )
    );
  }
}
