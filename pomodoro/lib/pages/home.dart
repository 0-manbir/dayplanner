import 'package:flutter/material.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: Text(
        "Hello World!!",
        style: TextStyle(
          color: text,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontFamily: fontfamily,
        ),
      ),
    );
  }
}
