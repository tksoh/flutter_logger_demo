import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger_demo/logging/logging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

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
                Platform.isWindows
                    ? buildIconButton(
                        icon: Icons.description,
                        size: 36,
                        onPressed: openSelectedFiles,
                        tooltip: 'Open selected files',
                        enabled: selectedFiles.isNotEmpty,
                      )
                    : buildIconButton(
                        icon: Icons.share,
                        size: 36,
                        onPressed: shareSelectedFiles,
                        tooltip: 'Shared selected files',
                        enabled: selectedFiles.isNotEmpty,
                      ),
                buildIconButton(
                  icon: Icons.delete,
                  size: 36,
                  onPressed: deleteSelectedFiles,
                  tooltip: 'Delete selected files',
                  enabled: selectedFiles.isNotEmpty,
                ),
                const Spacer(),
                Checkbox(
                  tristate: true,
                  value: selectedFiles.length == logFiles.length
                      ? true
                      : selectedFiles.isNotEmpty
                          ? null
                          : false,
                  onChanged: (value) {
                    if (value == null || value == false) {
                      selectedFiles.clear();
                    } else {
                      selectedFiles.clear();
                      selectedFiles.addAll(logFiles);
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(width: 15),
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
                  final fname = p.basename(logFile);
                  final isActiveFile = logFile == Logging.path;

                  return GestureDetector(
                    onDoubleTap: () => openFile(logFile),
                    child: ListTile(
                      leading: Text('${index + 1}'),
                      title: Text(
                        fname,
                      ),
                      subtitle: isActiveFile
                          ? const Text(
                              '(active)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )
                          : null,
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

  void deleteSelectedFiles() async {
    final status = await showComfirmDialog(
        'Deleten Log Files', 'Do you want to selected log files');
    if (status != 'YES') {
      return;
    }

    for (final f in selectedFiles) {
      if (f == Logging.path) {
        continue; // skip active log file
      }

      try {
        File(f).deleteSync();
      } on FileSystemException catch (e) {
        logger.e('Error deleting $f: $e');
      }
    }

    setState(() {
      selectedFiles.clear();
      logFiles = getLogFiles();
    });
  }

  void openLogFileFolder() {
    if (!Platform.isWindows) return;

    final url = Uri.parse(Logging.folder);
    launchUrl(url);
  }

  void openSelectedFiles() {
    for (final f in selectedFiles) {
      openFile(f);
    }
  }

  void openFile(String path) {
    if (!Platform.isWindows) return;

    final url = Uri.parse(path);
    launchUrl(url);
  }

  Future<String> showComfirmDialog(String title, String content) async {
    final resp = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => buildConfirmDialog(
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(content)),
    );

    return resp ?? '';
  }

  Widget buildConfirmDialog(Widget title, Widget content) {
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        TextButton(
            child: const Text(
              'NO',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop('NO');
            }),
        TextButton(
            child: const Text(
              'YES',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop('YES');
            }),
      ],
    );
  }
}

Padding buildIconButton({
  required IconData icon,
  VoidCallback? onPressed,
  double size = 48,
  bool enabled = true,
  String tooltip = '',
}) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: SizedBox.square(
      dimension: size,
      child: Tooltip(
        message: tooltip,
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
    ),
  );
}
