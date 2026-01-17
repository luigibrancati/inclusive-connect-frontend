import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends ChangeNotifier {
  static const String _storageKeyHighContrast = 'high_contrast';
  static const String _storageKeyTextScale = 'text_scale';
  static const String _storageKeyReadableFont = 'readable_font';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _highContrast = false;
  double _textScaleFactor = 1.0;
  bool _readableFont = false;

  bool get highContrast => _highContrast;
  double get textScaleFactor => _textScaleFactor;
  bool get readableFont => _readableFont;

  ThemeService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String? highContrastVal = await _storage.read(key: _storageKeyHighContrast);
    String? textScaleVal = await _storage.read(key: _storageKeyTextScale);
    String? readableFontVal = await _storage.read(key: _storageKeyReadableFont);

    if (highContrastVal != null) {
      _highContrast = highContrastVal == 'true';
    }
    if (textScaleVal != null) {
      _textScaleFactor = double.tryParse(textScaleVal) ?? 1.0;
    }
    if (readableFontVal != null) {
      _readableFont = readableFontVal == 'true';
    }
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    await _storage.write(key: _storageKeyHighContrast, value: value.toString());
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScaleFactor = value.clamp(1.0, 1.5);
    await _storage.write(
      key: _storageKeyTextScale,
      value: _textScaleFactor.toString(),
    );
    notifyListeners();
  }

  Future<void> setReadableFont(bool value) async {
    _readableFont = value;
    await _storage.write(key: _storageKeyReadableFont, value: value.toString());
    notifyListeners();
  }
}
