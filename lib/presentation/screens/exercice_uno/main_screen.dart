import 'package:flutter/material.dart';
import 'package:front/presentation/screens/exercice_uno/card_stack_screen_static.dart';

class CardStackApp extends StatelessWidget {
  const CardStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNO Card Stack',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      home: const CardStackScreenStatic(),
    );
  }
}
