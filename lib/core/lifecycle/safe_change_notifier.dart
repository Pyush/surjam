import 'package:flutter/foundation.dart';

/// Ignores notifications after dispose. Providers reset key highlights on short timers;
/// when the screen closes first, those late updates must not touch the disposed notifier.
mixin SafeChangeNotifier on ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
