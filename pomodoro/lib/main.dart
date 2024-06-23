// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
    await windowManager.center();
    await windowManager.setTitle("Pomodoro Timer");
    await windowManager.setMinimumSize(const Size(800, 500));
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "${DateFormat.MMMM().format(DateTime.now())} ${DateTime.now().day.toString()}, ${DateTime.now().year.toString()}",
            style: TextStyle(
              fontFamily: fontfamily,
              color: textLight,
            ),
          ),
          foregroundColor: background,
          backgroundColor: primary,
          elevation: 10.0,
          shadowColor: shadow,
        ),
        body: main(),
      ),
    );
  }

  Widget main() {
    return Container(
      color: background,
      child: Row(
        children: [
          Expanded(
            child: newSession(),
          ),
          Container(
            color: divider,
            width: 2,
            height: MediaQuery.of(context).size.height,
          ),
          Expanded(
            flex: 2,
            child: timer(),
          ),
          Container(
            color: divider,
            width: 2,
            height: MediaQuery.of(context).size.height,
          ),
          Expanded(
            child: tasks(),
          ),
        ],
      ),
    );
  }

  Widget timer() {
    return Container();
  }

  bool isHoveringTasksOptions = false;

  Widget tasks() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),

          // Tasks Header----------------------------------
          child: Row(
            children: [
              Text(
                "Today (0)",
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: textDark,
                  fontSize: 20.0,
                ),
              ),
              Expanded(child: Container()),
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    isHoveringTasksOptions = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    isHoveringTasksOptions = false;
                  });
                },
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color:
                          isHoveringTasksOptions ? accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: textDark,
                      size: 26.0,
                    ),
                  ),
                  onTap: () {
                    // TODO tasks options
                  },
                ),
              ),
            ],
          ),
        ),

        // Tasks Today---------------------------------------
        // Tasks Tomorrow------------------------------------
        // Tasks Upcoming------------------------------------
      ],
    );
  }

  Widget newSession() {
    return Container();
  }
}
