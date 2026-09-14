// Logger Servis
// Açıklama: Uygulama genelinde loglama işlemlerini yönetir
// Debug, info, success, warning ve error seviyesinde loglar tutar

import 'package:logger/logger.dart';
import '../config/app_constants.dart';

/// Logger Sınıfı
/// Açıklama: Uygulama boyunca loglama işlemleri için kullanılır
/// Yapılandırılmış loglar console'a ve dosyaya yazılabilir
class AppLogger {
  /// Logger instance
  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: ConsoleOutput(),
  );

  /// Debug log
  /// Açıklama: Geliştirme sırasında detaylı bilgi logla
  /// message: Loglanacak mesaj
  /// error: İlişkili hata (opsiyonel)
  /// stackTrace: Stack trace (opsiyonel)
  static void debug(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!AppConstants.debugMode) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info log
  /// Açıklama: Genel bilgi mesajları
  /// message: Loglanacak mesaj
  static void info(dynamic message) {
    if (!AppConstants.enableLogging) return;
    _logger.i(message);
  }

  /// Success log
  /// Açıklama: Başarılı işlemler
  /// message: Loglanacak mesaj
  static void success(dynamic message) {
    if (!AppConstants.enableLogging) return;
    _logger.i('✅ $message');
  }

  /// Warning log
  /// Açıklama: Uyarı mesajları
  /// message: Loglanacak mesaj
  static void warning(dynamic message) {
    if (!AppConstants.enableLogging) return;
    _logger.w(message);
  }

  /// Error log
  /// Açıklama: Hata mesajları
  /// message: Loglanacak mesaj
  /// error: Hata detayları
  /// stackTrace: Stack trace
  static void error(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!AppConstants.enableLogging) return;
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
