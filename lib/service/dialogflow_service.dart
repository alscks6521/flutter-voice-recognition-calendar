import 'dart:async';
import 'dart:convert';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/widgets.dart';

// 리팩토링 예정 서비스레이어 코드.
class DialogflowService {
  late DialogFlowtter dialogFlowtter;

  Future<void> initialize(context) async {
    try {
      final keyJson =
          await DefaultAssetBundle.of(context).loadString('assets/speekplan-2f1f97f87f6c.json');
      final Map<String, dynamic> keyMap = json.decode(keyJson);
      final credentials = DialogAuthCredentials.fromJson(keyMap);
      dialogFlowtter = DialogFlowtter(credentials: credentials);
      debugPrint("Dialogflowttwe 인증 sucesses!");
    } catch (e) {
      debugPrint("Error initializing Dialogflow: $e");
    }
  }

  Future<Map<String, dynamic>?> detectIntentsResp(String speechText) async {
    TextInput textInput = TextInput(text: speechText);
    QueryInput queryInput = QueryInput(text: textInput);
    DetectIntentResponse response = await dialogFlowtter.detectIntent(queryInput: queryInput);
    return response.queryResult?.parameters;
  }
}
