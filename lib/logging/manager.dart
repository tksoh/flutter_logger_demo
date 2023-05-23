import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger_demo/logging/logging.dart';
import 'package:share_plus/share_plus.dart';

class LogManager extends StatefulWidget {
  const LogManager({super.key});

  @override
  State<LogManager> createState() => _LogManagerState();
}

class _LogManagerState extends State<LogManager> {
  List<String> logFiles = [];
  List<String> selectedFiles = [];

  @override
  void initState() {
    logFiles = getLogFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Log Files')),
        body: Column(
          children: [
            Row(
              children: [
                buildIconButton(
                  icon: Icons.share,
                  size: 36,
                  onPressed: shareSelectedFiles,
                  enabled: !Platform.isWindows,
                ),
                buildIconButton(
                  icon: Icons.delete,
                  size: 36,
                  onPressed: deleteSelectedFiles,
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemCount: logFiles.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  final logFile = logFiles[index];
                  final isSelected = selectedFiles.contains(logFile);
                  return ListTile(
                    leading: Text('$index'),
                    title: Text(logFile),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            selectedFiles.add(logFile);
                          } else {
                            selectedFiles.remove(logFile);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  List<String> getLogFiles() {
    return Logging.getLogFiles();
  }

  void shareSelectedFiles() {
    if (selectedFiles.isEmpty) return;

    // ignore: deprecated_member_use
    Share.shareFiles(selectedFiles, text: 'log data');
  }

  void deleteSelectedFiles() {
    //
  }
}

Padding buildIconButton({
  required IconData icon,
  VoidCallback? onPressed,
  double size = 48,
  enabled = true,
}) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: SizedBox.square(
      dimension: size,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(5),
          backgroundColor: Colors.blue, // <-- Button color
          // foregroundColor: Colors.red, // <-- Splash color
        ),
        child: Icon(icon),
      ),
    ),
  );
}
