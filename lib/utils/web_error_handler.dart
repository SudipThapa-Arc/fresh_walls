import 'package:flutter/foundation.dart';

class WebErrorHandler {
  static void handleError(dynamic error, dynamic stackTrace) {
    if (kIsWeb) {
      // Log error to console in a formatted way
      debugPrint('=== Web Error ===');
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');

      // You can add web-specific error reporting here
      // For example, sending to a web analytics service
    }
  }
}
