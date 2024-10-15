import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isInitialized = false;

  Future<bool> initialize() async {
    isInitialized = await _speech.initialize(
      onError: (val) {
        debugPrint("Speech.initalize Error: $val");
        isInitialized = false;
      },
      onStatus: (val) {
        debugPrint('Speech.initalize Status: $val');
        isInitialized = true;
      },
    );

    return isInitialized;
  }

  Future<String> startListening() async {
    debugPrint("음성지원");
    Completer<String> comple = Completer<String>();
    try {
      _speech.listen(
        listenFor: const Duration(seconds: 30),
        onResult: (result) {
          if (result.finalResult) {
            final recogn = result.recognizedWords.toLowerCase();
            debugPrint("voice input : $recogn");
            if (!comple.isCompleted) {
              comple.complete(recogn);
            }
          }
        },
      );
    } catch (e) {
      if (!comple.isCompleted) {
        comple.completeError(e);
      }
      debugPrint("Listening error: $e");
    }
    return comple.future;
  }
}
