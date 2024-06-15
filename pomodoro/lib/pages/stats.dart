import 'package:flutter/material.dart';
import 'package:pomodoro/variables/colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: Text(
        "Stats Screen",
      ),
    );
  }
}
