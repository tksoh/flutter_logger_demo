import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'plain_printer.dart';

const logFolder = 'logs';

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
  final logFolderPath = '${tmpdir.path}/$logFolder';
  await Directory(logFolderPath).create(recursive: true);
  return logFolderPath;
}

Future<void> clearLogFiles() async {
  final logFolderPath = await getLogFolderPath();
  final dir = Directory(logFolderPath);
  try {
    dir.deleteSync(recursive: true);
  } on FileSystemException catch (e) {
    debugPrint('$e');
  }
}

Future<File> openLogFile() async {
  final dir = await getLogFolderPath();
  final timeCode = DateFormat('yyyyMMdd').format(DateTime.now());
  final filename = 'Log_$timeCode.txt';
  final path = '$dir/$filename';
  logFilePath = path;
  final logfile = File(path);
  return logfile;
}
