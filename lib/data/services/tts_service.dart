import 'package:flutter/scheduler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  double _speechRate = 0.8;
  double _pitch = 1.0;

  double get speechRate => _speechRate;
  double get pitch => _pitch;

  bool _isItalianAvailable = false;
  bool get isItalianAvailable => _isItalianAvailable;

  String? _currentSpeakingId;
  String? get currentSpeakingId => _currentSpeakingId;

  TtsService() {
    _initTts();
  }

  void _initTts() async {
    // Check if Italian is available
    var availability = await _flutterTts.isLanguageAvailable("it-IT");

    // Logic to determine if available based on return type (can vary by platform)
    if (availability == true ||
        availability == "Fully supported" ||
        availability == "supported") {
      _isItalianAvailable = true;
      await _flutterTts.setLanguage("it-IT");
    } else {
      _isItalianAvailable = false;
      // If not available, we can't default to it yet.
      // Maybe default to English or first available?
      // For now, leaving it unset or default system.
    }

    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(_pitch);

    _flutterTts.setCompletionHandler(() {
      _currentSpeakingId = null;
      _safeNotifyListeners();
    });

    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle ||
        SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> installItalianLanguage() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use Android Intent to open TTS data installation
      const intent = AndroidIntent(
        action: 'android.speech.tts.engine.INSTALL_TTS_DATA',
      );
      await intent.launch();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    _safeNotifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
    _safeNotifyListeners();
  }

  Future<void> speak(String text, {String? id}) async {
    if (text.isNotEmpty) {
      _currentSpeakingId = id;
      _safeNotifyListeners();
      await _flutterTts.speak(text);
    }
  }

  Future<void> test() async {
    await _flutterTts.speak("Questo è un test per la sintesi vocale.");
  }

  Future<void> stop() async {
    _currentSpeakingId = null;
    _safeNotifyListeners();
    await _flutterTts.stop();
  }

  Future<void> stopIfId(String id) async {
    if (_currentSpeakingId == id) {
      await stop();
    }
  }
}
