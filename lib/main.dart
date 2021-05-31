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

Stream<int> getPageOffsets(args) async* {
  num lineText = 0;
  int lineCount = 0;

  if (args[0].isNotEmpty) {
    int i = 0;
    while (true) {
      if (lineCount >= args[1]) {
        lineCount = 0;
        yield i;
      }

      if (args[0][i].contains(new RegExp(r'[A-Za-z ]'))) {
        lineText += 0.5;
      } else
        lineText += 1;

      if (lineText >= args[2] || args[0][i] == '\n') {
        lineText = 0;
        lineCount++;
      }
      if (i == args[0].length - 1)
        break;
      else
        i++;
    }
    if (lineText > 0) {
      yield i;
    }
  }
}

TextPainter getTextPainter(text) {
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
    TextPainter test = getTextPainter('''가''');
    test.layout(maxWidth: width);
    double lineHeight = test.preferredLineHeight;
    double charWidth = test.width;
    int lineNumberPerPage = (height ~/ lineHeight) - 1;
    int charNumberPerLine = width ~/ charWidth;
    getPageOffsets([rawText, lineNumberPerPage, charNumberPerLine])
        .listen((value) {
      setState(() {
        textIdx.add(value);
        isLoding = false;
        currentPage = 0;
        txtStart = 0;
        txtEnd = textIdx[currentPage];
      });
    });
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Container(
              height: 56.0,
              width: MediaQuery.of(context).size.width / 4 * 3,
              child: Slider(
                value: currentPage.toDouble(),
                min: 0,
                max: textIdx.isEmpty ? 1 : textIdx.length.toDouble() - 1.0,
                divisions: textIdx.isEmpty ? 1 : textIdx.length - 2,
                onChanged: (double value) {
                  setState(
                    () {
                      if (textIdx.isNotEmpty) {
                        currentPage = value.toInt();
                        txtStart = value == 0.0 ? 0 : textIdx[currentPage - 1];
                        txtEnd = textIdx[currentPage];
                      }
                    },
                  );
                },
              ),
            ),
            Spacer(),
            Text(textIdx.isNotEmpty
                ? '${currentPage + 1}/${textIdx.length}'
                : '0/0'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadText,
        tooltip: 'LoadText',
        child: Icon(Icons.folder_open),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
