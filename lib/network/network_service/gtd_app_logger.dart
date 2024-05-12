import 'dart:developer';

class NetWorkLogger {
  // ignore: constant_identifier_names
  static const String _DEFAULT_TAG_PREFIX = "DVTNetwork";

  ///use Log.v. Print all Logs
  ///ignore: constant_identifier_names
  static const int VERBOSE = 2;

  ///use Log.d. Print Debug Logs
  ///ignore: constant_identifier_names
  static const int DEBUG = 3;

  ///use Log.i. Print Info Logs
  ///ignore: constant_identifier_names
  static const int INFO = 4;

  ///use Log.w. Print warning logs
  ///ignore: constant_identifier_names
  static const int WARN = 5;

  ///use Log.e. Print error logs
  ///ignore: constant_identifier_names
  static const int ERROR = 6;

  ///use Log.wtf. Print Failure Logs(What a Terrible Failure= WTF)
  ///ignore: constant_identifier_names
  static const int WTF = 7;

  ///SET APP LOG LEVEL, Default ALL
  static int _currentLogLevel = DEBUG;

  static setLogLevel(int priority) {
    int newPriority = priority;
    if (newPriority <= VERBOSE) {
      newPriority = VERBOSE;
    } else if (newPriority >= WTF) {
      newPriority = WTF;
    }
    _currentLogLevel = newPriority;
  }

  static int getLogLevel() {
    NetWorkLogger.v(
        "Current Log Level is ${_getPriorityText(_currentLogLevel)}");
    return _currentLogLevel;
  }

  static _log(int priority, String tag, String message) {
    if (_currentLogLevel <= priority) {
      switch (priority) {
        case INFO:
          log("\x1B[34m${_getPriorityText(priority)}$tag: $message \x1B[0m");
          return;
        case DEBUG:
          log("\x1B[32m${_getPriorityText(priority)}$tag: $message \x1B[0m");
          return;
        case ERROR:
          log("\x1B[31m${_getPriorityText(priority)}$tag: $message \x1B[0m");
          return;
        case WARN:
          log("\x1B[33m${_getPriorityText(priority)}$tag: $message \x1B[0m");
          return;
        case WTF:
          log("${_getPriorityText(priority)}$tag: $message");
          return;
        default:
          log("${_getPriorityText(priority)}$tag: $message");
      }
    }
  }

  static String _getPriorityText(int priority) {
    switch (priority) {
      case INFO:
        return "INFO|";
      case DEBUG:
        return "DEBUG|";
      case ERROR:
        return "ERROR|";
      case WARN:
        return "WARN|";
      case VERBOSE:
      default:
        return "";
    }
  }

  ///Print general logs
  static v(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    _log(VERBOSE, tag, message);
  }

  ///Print info logs
  static i(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    _log(INFO, tag, message);
  }

  ///Print debug logs
  static d(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    _log(DEBUG, tag, message);
  }

  ///Print warning logs
  static w(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    _log(WARN, tag, message);
  }

  ///Print error logs
  static e(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    _log(ERROR, tag, message);
  }

  ///Print failure logs
  static wtf(String message, {String tag = _DEFAULT_TAG_PREFIX}) {
    _log(WTF, tag, message);
  }
}
