import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pomodoro/pages/home.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow().then((_) async {
    // await windowManager.setTitleBarStyle(TitleBarStyle.normal);

    await windowManager.setSkipTaskbar(false); // add this when minimised
    await windowManager.setOpacity(1); // add this when minimised
    await windowManager.setAlwaysOnTop(false); // add this when minimised

    // await windowManager.setIcon();
    await windowManager.setTitle("Pomodoro Timer");
    await windowManager.setMinimumSize(const Size(600, 400));
    await windowManager.setSize(const Size(1100, 700));
    await windowManager.show();
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Screen Dimensions
  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      home: Scaffold(
        backgroundColor: background,
        body: mainScreen(),
      ),
    );
  }

  Widget mainScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        navBar(),
        const Expanded(child: HomeScreen()),
      ],
    );
  }

  Widget navBar() {
    return Container(
      decoration: BoxDecoration(
        color: secondary,
      ),
      height: 0.075 * screenHeight,
      width: screenWidth,
    );
  }
}
