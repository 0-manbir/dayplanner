import 'package:flutter/material.dart';
import 'package:pomodoro/variables/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: background,
      body: Text(
        "Settings Screen",
      ),
    );
  }
}
