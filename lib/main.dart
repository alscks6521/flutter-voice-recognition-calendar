import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:speek_plan/views/home_page.dart';

void main() async {
  // 언어설정(intl)
  await initializeDateFormatting();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SpeekPlan',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      //   useMaterial3: true,
      // ),
      home: HomePage(),
    );
  }
}
