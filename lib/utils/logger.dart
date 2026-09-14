// Logger Servis
// Açıklama: Uygulama genelinde loglama işlemlerini yönetir

class AppLogger {
  static void debug(String message) {
    print('[DEBUG] $message');
  }

  static void info(String message) {
    print('[INFO] $message');
  }

  static void success(String message) {
    print('[SUCCESS] ✅ $message');
  }

  static void warning(String message) {
    print('[WARNING] ⚠️ $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[ERROR] ❌ $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }
}
