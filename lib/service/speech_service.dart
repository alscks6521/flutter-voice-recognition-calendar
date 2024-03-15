import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isInitialized = false;

  Future<bool> initialize() async {
    isInitialized = await _speech.initialize(
      onError: (val) {
        print("Speech.initalize Error: $val");
        isInitialized = false;
      },
      onStatus: (val) {
        print('Speech.initalize Status: $val');
        isInitialized = true;
      },
    );

    return isInitialized;
  }

  Future<String> startListening() async {
    print("음성지원");
    Completer<String> comple = Completer<String>();
    try {
      _speech.listen(
        listenFor: const Duration(seconds: 30),
        onResult: (result) {
          if (result.finalResult) {
            final recogn = result.recognizedWords.toLowerCase();
            print("voice input : $recogn");
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
      print("Listening error: $e");
    }
    return comple.future;
  }
}
