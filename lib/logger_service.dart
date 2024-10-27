import 'package:logger/logger.dart';

class LoggerService {
  // Step 1: Create a private static instance of Logger
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Step 2: Static method to log a debug message
  static void debug(String message) {
    _logger.d(message);
  }

  // Step 2: Static method to log a debug message
  static void fatal(String message) {
    _logger.f(message);
  }

  // Step 3: Static method to log an info message
  static void info(String message) {
    _logger.i(message);
  }

  // Static method to log a warning message
  static void warning(String message) {
    _logger.w(message);
  }

  // Static method to log an error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message);
  }

  // Static method to log a verbose message
  static void verbose(String message) {
    _logger.v(message);
  }
}
