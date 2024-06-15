// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/pages/home.dart';
import 'package:pomodoro/pages/settings.dart';
import 'package:pomodoro/pages/stats.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';
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

  // Screens
  final PageController _pageController = PageController();
  int _pageSelectedIndex = 0;

  void _onPageChanged(index) {
    setState(() {
      _pageSelectedIndex = index;
    });
  }

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
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              HomeScreen(),
              StatsScreen(),
              SettingsScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget navBar() {
    return Container(
      color: secondary,
      height: 0.075 * screenHeight,
      width: screenWidth,
      child: Row(
        children: [
          Expanded(child: Container()),
          // navbar-----------------------------------
          Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: getMenuItems()),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget getMenuItems() {
    return Row(
      children: [
        menuItemStyle("home", 0),
        Container(width: 20),
        menuItemStyle("stats", 1),
        Container(width: 20),
        menuItemStyle("settings", 2),
      ],
    );
  }

  bool isHovering = false;
  late int hoveringIndex;

  Widget menuItemStyle(String title, int index) {
    return MouseRegion(
      onEnter: (_) => _onHover(true, index),
      onExit: (_) => _onHover(false, index),
      child: GestureDetector(
        child: AnimatedScale(
          scale: isHovering && hoveringIndex == index ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: SizedBox(
            child: Text(
              title,
              style: TextStyle(
                color: background,
                fontFamily: fontfamily,
                fontWeight: isHovering && hoveringIndex == index
                    ? FontWeight.w500
                    : FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            _pageSelectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastEaseInToSlowEaseOut,
            );
          });
        },
      ),
    );
  }

  void _onHover(bool hovering, int index) {
    setState(() {
      isHovering = hovering;
      hoveringIndex = index;
    });
  }
}
