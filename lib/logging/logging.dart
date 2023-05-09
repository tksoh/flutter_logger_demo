import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'plain_printer.dart';

const logFolderName = 'logs';

late String logFolderPath;

late String logFilePath;

late Logger logger;

Future<void> createLogger() async {
  logger = Logger(
    printer: PlainLogPrinter(),
    output: MultiOutput([
      if (kDebugMode) ConsoleOutput(),
      FileOutput(file: await openLogFile()),
    ]),
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
  );
}

Future<String> getLogFolderPath() async {
  final tmpdir = await getTemporaryDirectory();
  logFolderPath = p.join(tmpdir.path, logFolderName);
  await Directory(logFolderPath).create(recursive: true);
  return logFolderPath;
}

Future<void> purgeLogFiles() async {
  final dir = Directory(logFolderPath);

  // delete all log files except current one in use
  final files = dir.listSync();
  for (final f in files) {
    if (f.path == logFilePath) {
      continue; // skip active log file
    }

    try {
      f.deleteSync();
    } on FileSystemException catch (e) {
      logger.e('Error deleting $f: $e');
    }
  }
}

Future<File> openLogFile() async {
  final dir = await getLogFolderPath();
  final timeCode = DateFormat('yyyyMMdd').format(DateTime.now());
  final filename = 'Log_$timeCode.txt';
  final path = p.join(dir, filename); //'$dir/$filename';
  logFilePath = path;
  final logfile = File(path);

  // tmp file for testing log files purging
  final tmpFile = File('$dir/$filename.tmp');
  tmpFile.writeAsStringSync('test contents\n');

  return logfile;
}
