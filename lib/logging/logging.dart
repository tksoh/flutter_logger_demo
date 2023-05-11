import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'plain_printer.dart';

// const logFolderName = 'logs';

// late String logFolderPath;

// late String logFilePath;

// late Logger logger;

late MyLogger logger;

// final _logFilter = kDebugMode ? DevelopmentFilter() : ProductionFilter();

class MyLogger extends Logger {
  LogFilter? filter;
  LogPrinter? printer;
  LogOutput? output;
  Level? level;
  bool paused = false;

  MyLogger({
    this.filter,
    this.printer,
    this.output,
    this.level,
  }) : super(
          filter: filter ?? DevelopmentFilter(),
          printer: printer,
          output: output,
          level: level,
        );

  Level setLevel(Level newLevel) {
    final curLevel = filter!.level;
    filter!.level = newLevel;
    level = newLevel;
    return curLevel!;
  }
}

class Logging {
  static const logFolderName = 'logs';

  static late String logFolderPath;

  static late String logFilePath;

  // static late Logger logger;

  static final _logFilter =
      kDebugMode ? DevelopmentFilter() : ProductionFilter();
  static Future<void> initialize() async {
    logger = MyLogger(
      printer: PlainLogPrinter(),
      output: MultiOutput([
        if (kDebugMode) ConsoleOutput(),
        FileOutput(file: await openLogFile()),
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
    logFolderPath = p.join(tmpdir.path, logFolderName);
    await Directory(logFolderPath).create(recursive: true);
    return logFolderPath;
  }

  static Future<void> purgeLogFiles() async {
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

  static Future<File> openLogFile() async {
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
}

// Future<void> createLogger() async {
//   logger = Logger(
//     printer: PlainLogPrinter(),
//     output: MultiOutput([
//       if (kDebugMode) ConsoleOutput(),
//       FileOutput(file: await openLogFile()),
//     ]),
//     filter: _logFilter,
//   );
// }

// Level? setFilterLevel(Level level) {
//   final curLevel = _logFilter.level;
//   _logFilter.level = level;
//   return curLevel;
// }

// Future<String> getLogFolderPath() async {
//   final tmpdir = await getTemporaryDirectory();
//   logFolderPath = p.join(tmpdir.path, logFolderName);
//   await Directory(logFolderPath).create(recursive: true);
//   return logFolderPath;
// }

// Future<void> purgeLogFiles() async {
//   final dir = Directory(logFolderPath);

//   // delete all log files except current one in use
//   final files = dir.listSync();
//   for (final f in files) {
//     if (f.path == logFilePath) {
//       continue; // skip active log file
//     }

//     try {
//       f.deleteSync();
//     } on FileSystemException catch (e) {
//       logger.e('Error deleting $f: $e');
//     }
//   }
// }

// Future<File> openLogFile() async {
//   final dir = await getLogFolderPath();
//   final timeCode = DateFormat('yyyyMMdd').format(DateTime.now());
//   final filename = 'Log_$timeCode.txt';
//   final path = p.join(dir, filename); //'$dir/$filename';
//   logFilePath = path;
//   final logfile = File(path);

//   // tmp file for testing log files purging
//   final tmpFile = File('$dir/$filename.tmp');
//   tmpFile.writeAsStringSync('test contents\n');

//   return logfile;
// }
