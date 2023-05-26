import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:logger_demo/logging/manager.dart';
import 'package:share_plus/share_plus.dart';

import 'logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Logging.initialize();
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
                      Logging.path,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: Logging.path));
                  },
                  tooltip: 'Copy log file path',
                  icon: const Icon(
                    Icons.copy,
                    size: 14,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const LogManager2(),
                      ),
                    );
                  },
                  tooltip: 'Log file manager',
                  icon: const Icon(
                    Icons.folder,
                    size: 14,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    Logging.purgeLogFiles();
                  },
                  tooltip: 'Delete old log files',
                  icon: const Icon(
                    Icons.cleaning_services,
                    size: 16,
                    color: Colors.blue,
                  ),
                ),
                Platform.isWindows
                    ? Container()
                    : IconButton(
                        onPressed: Platform.isWindows ? null : shareLog,
                        tooltip: 'share log file',
                        icon: const Icon(
                          Icons.share,
                          size: 14,
                          color: Colors.blue,
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
    logger.i('log file = ${Logging.path}');
    logger.d('Counter = $_counter');
  }

  shareLog() {
    // ignore: deprecated_member_use
    Share.shareFiles([Logging.path], text: 'log data');
  }
}

class LogManager2 extends LogManager {
  const LogManager2({super.key});

  @override
  State<LogManager2> createState() => LogManager2State();
}

class LogManager2State extends LogManagerState<LogManager2> {
  @override
  List<Widget> getCustomActions() {
    return [
      buildIconButton(
        icon: Icons.upload,
        onPressed: uploadSelectedFiles,
        enabled: selectedFiles.isNotEmpty,
      ),
    ];
  }

  void uploadSelectedFiles() {
    if (selectedFiles.isEmpty) return;
    logger.d('uploading: $selectedFiles');
  }
}
