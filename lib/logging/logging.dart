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

  static Future<void> initialize() async {
    _logFile = await openLogFile();

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

  static Future<String> getLogFolderPath() async {
    final tmpdir = await getTemporaryDirectory();
    final logPath = p.join(tmpdir.path, _logFolderName);
    await Directory(logPath).create(recursive: true);
    return logPath;
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

  static Future<File> openLogFile() async {
    final dir = await getLogFolderPath();
    final timeCode = DateFormat('yyyyMMdd').format(DateTime.now());
    final filename = 'Log_$timeCode.txt';

    // tmp file for testing log files purging
    final tmpFileName = '$filename.tmp';
    final tmpFile = File(p.join(dir, tmpFileName));
    tmpFile.writeAsStringSync('test contents\n');

    return File(p.join(dir, filename));
  }
}
