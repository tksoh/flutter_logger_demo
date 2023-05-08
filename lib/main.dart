import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'plain_printer.dart';

late String logFilePath;

Future<File> openLogFile() async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/test1_log.txt';
  logFilePath = path;
  final logfile = File(path);
  return logfile;
}

late Logger logger;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger = Logger(
    printer: PlainLogPrinter(),
    output: MultiOutput([
      if (kDebugMode) ConsoleOutput(),
      FileOutput(file: await openLogFile()),
    ]),
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Logger Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final start = DateTime.now();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    addLog();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        kDebugMode ? '${widget.title} [Debug]' : '${widget.title} [Release]';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      logFilePath,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: logFilePath));
                  },
                  tooltip: 'Copy log file path',
                  icon: const Icon(
                    Icons.copy,
                    size: 14,
                  ),
                ),
                IconButton(
                  onPressed: Platform.isWindows ? null : shareLog,
                  tooltip: 'share log file',
                  icon: const Icon(
                    Icons.share,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void addLog() {
    logger.i('log file = $logFilePath');
    logger.d('Counter = $_counter');
  }

  shareLog() {
    // ignore: deprecated_member_use
    Share.shareFiles([logFilePath], text: 'log data');
  }
}
