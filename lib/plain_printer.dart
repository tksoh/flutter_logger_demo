import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PlainLogPrinter extends LogPrinter {
  static final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SS');
  static final levelPrefixes = {
    Level.verbose: 'verbose',
    Level.debug: 'debug',
    Level.info: 'info',
    Level.warning: 'warning',
    Level.error: 'error',
    Level.wtf: 'wtf',
  };

  @override
  List<String> log(LogEvent event) {
    final evtime = dateFormat.format(event.time);
    var output = StringBuffer('$evtime [${levelPrefixes[event.level]}]:');
    if (event.message is String) {
      output.write(' ${event.message}');
    } else if (event.message is Map) {
      event.message.entries.forEach((entry) {
        if (entry.value is num) {
          output.write(' ${entry.key}=${entry.value}');
        } else {
          output.write(' ${entry.key}="${entry.value}"');
        }
      });
    }
    if (event.error != null) {
      output.write(' error="${event.error}"');
    }

    return [output.toString()];
  }
}
