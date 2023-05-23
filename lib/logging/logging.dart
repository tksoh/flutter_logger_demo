import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'plain_printer.dart';

late Logger logger;

class Logging {
  static const _logFolderName = 'logs';
  static final _logFilter =
      kDebugMode ? DevelopmentFilter() : ProductionFilter();
  static late File _logFile;

  static String get path => _logFile.path;

  static String get folder => _logFile.parent.path;

  Logging._(); // Logging is just a wrapper class

  static Future<void> initialize() async {
    _logFile = await _openLogFile();

    logger = Logger(
      printer: PlainLogPrinter(),
      output: MultiOutput([
        if (kDebugMode) ConsoleOutput(),
        FileOutput(file: _logFile),
      ]),
      filter: _logFilter,
    );
  }

  static Level? setFilterLevel(Level level) {
    final curLevel = _logFilter.level;
    _logFilter.level = level;
    return curLevel;
  }

  static List<String> getLogFiles() {
    final files = _logFile.parent.listSync().map((f) => f.path).toList();
    return files;
  }

  static Future<void> purgeLogFiles() async {
    // delete all log files except current one in use
    final files = _logFile.parent.listSync();
    for (final f in files) {
      if (f.path == _logFile.path) {
        continue; // skip active log file
      }

      try {
        f.deleteSync();
      } on FileSystemException catch (e) {
        logger.e('Error deleting $f: $e');
      }
    }
  }

  static Future<File> _openLogFile() async {
    final tmpdir = await getTemporaryDirectory();
    final logDir = p.join(tmpdir.path, _logFolderName);
    final timeCode = DateFormat('yyyyMMdd').format(DateTime.now());
    final filename = 'Log_$timeCode.txt';

    // create folder for log files
    await Directory(logDir).create(recursive: true);

    return File(p.join(logDir, filename));
  }
}
