import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

late String logFilePath;

Future<File> openLogFile() async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/test1_log.txt';
  logFilePath = path;
  final logfile = File(path);
  return logfile;
}

late Logger logger;

void showLog() {
  logger.i('Time=${DateTime.now()}');
  logger.i('directory = $logFilePath');

  logger.d('Log message with 2 methods');

  // loggerNoStack.i('Info message');

  // loggerNoStack.w('Just a warning!');

  // logger.e('Error! Something bad happened', 'Test Error');

  // loggerNoStack.v({'key': 5, 'value': 'something'});

  // Logger(printer: SimplePrinter(colors: true)).v('boom');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger = Logger(
    printer: PrettyPrinter(colors: false),
    output: FileOutput(file: await openLogFile()),
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
    showLog();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(kDebugMode ? 'Dev mode' : 'Prod mode'),
            Text('path: $logFilePath'),
            const SizedBox(height: 10),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (Platform.isWindows) return;

                Share.shareFiles([logFilePath], text: 'log data');
              },
              child: const Text('share'),
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
}
