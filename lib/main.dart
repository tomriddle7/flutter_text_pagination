import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  // Inspired by that issue.
  //github.com/flutter/flutter/issues/75550
  // but it was improved.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Text Pagination'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoding = false;
  String rawText = 'Load Text File';
  List<num> textIdx = [];
  int currentPage = 0;
  int txtStart = 0;
  int txtEnd = 14;

  void loadText() async {
    setState(() {
      isLoding = true;
      rawText = '';
      textIdx.clear();
    });

    rawText = await rootBundle.loadString('assets/Lorem ipsum.txt');
    double height = MediaQueryData.fromWindow(window).size.height;
    // For safeArea, uncomment below two lines.
    // double padding = MediaQueryData.fromWindow(window).padding.top + MediaQueryData.fromWindow(window).padding.bottom;
    // height -= padding;
    double width = MediaQueryData.fromWindow(window).size.width;
    setState(() {
      textIdx = getPageOffsets(rawText, height, width);

      isLoding = false;
      currentPage = 0;
      txtStart = 0;
      txtEnd = textIdx[currentPage];
    });
  }

  List<num> getPageOffsets(String content, double pageHeight, double width) {
    String tempStr = content;
    List<num> pageConfig = [];
    if (content.isEmpty) {
      return pageConfig;
    }

    TextPainter textPainter = getTextPainter(tempStr, width);
    textPainter.layout(maxWidth: width);
    double textHeight = textPainter.height;
    double lineHeight = textPainter.preferredLineHeight;
    // int lineNumber = textHeight ~/ lineHeight;
    int lineNumberPerPage = pageHeight ~/ lineHeight;
    // int pageNum = (lineNumber / lineNumberPerPage).ceil();
    double actualPageHeight = (lineNumberPerPage - 1) * lineHeight;
    double index = 1.0;
    while (true) {
      var end = textPainter
          .getPositionForOffset(Offset(width, actualPageHeight * index))
          .offset;

      if (actualPageHeight * index > textHeight) {
        break;
      }
      index += 1.0;

      pageConfig.add(end);
    }
    return pageConfig;
  }

  TextPainter getTextPainter(text, width) {
    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textScaleFactor: MediaQueryData.fromWindow(window).textScaleFactor);

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
          locale: Locale('en_EN'),
          fontFamily: "Roboto",
          fontSize: 26,
          letterSpacing: 3.0,
          height: 1.5),
    );

    return textPainter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoding
            ? CircularProgressIndicator()
            : Text(
                rawText.substring(txtStart, txtEnd),
                style: TextStyle(
                    locale: Locale('en_EN'),
                    fontFamily: "Roboto",
                    fontSize: 26,
                    letterSpacing: 3.0,
                    height: 1.5),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                currentPage = 0;
                break;
              case 1:
                if (currentPage > 0) currentPage--;
                break;
              case 2:
                if (currentPage < textIdx.length - 1) currentPage++;
                break;
              case 3:
                currentPage = textIdx.length - 1;
            }
            txtStart = currentPage == 0 ? 0 : textIdx[currentPage - 1];
            txtEnd = textIdx[currentPage];
          });
        },
        items: [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.first_page),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.navigate_before),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.navigate_next),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.last_page),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadText,
        tooltip: 'LoadText',
        child: Icon(Icons.folder_open),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
