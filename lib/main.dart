import 'package:flutter/material.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/onboarding/name_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nilah',
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => WelcomeScreen(
          onBegin: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NameScreen(
                  onContinue: (name) {
                    debugPrint('Name: $name'); // saved properly on Day 7
                  },
                  onSkip: () {},
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}