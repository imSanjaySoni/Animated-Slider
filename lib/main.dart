import 'package:flutter/material.dart';
import 'package:slider/animated_slider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSlider(
              value: 0.4,
              onChange: (value) {},
            ),
          ),
        ),
      ),
    );
  }
}
