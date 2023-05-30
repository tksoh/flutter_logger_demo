import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

import 'logging.dart';

class LogManager extends StatefulWidget {
  const LogManager({super.key});

  @override
  State<LogManager> createState() => LogManagerState();
}

class LogManagerState<T extends StatefulWidget> extends State<T> {
  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  List<String> logFiles = [];
  List<String> selectedFiles = [];
  Map<String, FileStat> fileStats = {};

  @override
  void initState() {
    logFiles = getLogFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Files')),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        buildActionBar(),
        Expanded(
          child: buildFileListView(),
        ),
      ],
    );
  }

  Widget buildActionBar() {
    final checkBoxState = selectedFiles.length == logFiles.length
        ? true
        : selectedFiles.isEmpty
            ? false
            : null;

    return Row(
      children: [
        ...getDefaultActions(),
        ...getCustomActions(),
        const Spacer(),
        Checkbox(
          tristate: true,
          value: checkBoxState,
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
    );
  }

  Widget buildFileListView() {
    return ListView.separated(
        itemCount: logFiles.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return buildLogFileListItem(index);
        });
  }

  Widget buildLogFileListItem(int index) {
    final logFile = logFiles[index];
    final isSelected = selectedFiles.contains(logFile);
    final fname = p.basename(logFile);
    final isActiveFile = logFile == Logging.path;
    final stat = fileStats[logFile];
    final fdate = formatter.format(stat!.modified);
    final fsize = (stat.size / 1024).toStringAsFixed(2);

    return GestureDetector(
      onDoubleTap: () => openFile(logFile),
      child: ListTile(
        leading: Text('${index + 1}'),
        title: Text(
          fname + (isActiveFile ? ' [active]' : ''),
          style: TextStyle(
            color: isActiveFile ? Colors.deepOrange : Colors.black,
          ),
        ),
        subtitle: Text(
          '$fsize KB, $fdate',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
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
  }

  List<String> getLogFiles() {
    final list = Logging.getLogFiles()..sort();
    fileStats.clear();
    for (final f in list) {
      final st = FileStat.statSync(f);
      fileStats[f] = st;
    }
    return list.reversed.toList();
  }

  void shareSelectedFiles() {
    if (selectedFiles.isEmpty) return;

    // ignore: deprecated_member_use
    Share.shareFiles(selectedFiles, text: 'log data');
  }

  void deleteSelectedFiles() async {
    final status = await showComfirmDialog(
        'Deleten Log Files', 'Do you want to selected log files?');
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

  List<Widget> getDefaultActions() {
    return [
      Platform.isWindows
          ? buildIconButton(
              icon: Icons.description,
              onPressed: openSelectedFiles,
              tooltip: 'Open selected files',
              enabled: selectedFiles.isNotEmpty,
            )
          : buildIconButton(
              icon: Icons.share,
              onPressed: shareSelectedFiles,
              tooltip: 'Shared selected files',
              enabled: selectedFiles.isNotEmpty,
            ),
      buildIconButton(
        icon: Icons.delete,
        onPressed: deleteSelectedFiles,
        tooltip: 'Delete selected files',
        enabled: selectedFiles.isNotEmpty,
      )
    ];
  }

  List<Widget> getCustomActions() {
    return [];
  }
}

Padding buildIconButton({
  required IconData icon,
  VoidCallback? onPressed,
  double size = 36,
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
