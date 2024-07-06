import 'package:intl/intl.dart';

const String fontfamily = "Rubik";

// GENERAL APP STRINGS-----------------------------------------------------------------------------------
String appHeaderText =
    "${DateFormat.MMMM().format(DateTime.now())} ${DateTime.now().day}, ${DateTime.now().year}";
String appTitle = "Day Planner";

String noTasksText = "- no tasks here -";
String newTaskTextFieldTooltip =
    "task prototype:\n[task name] [150]m upcoming tag[0]";
String newTaskTextFieldHint = "new task...";

final Map<String, int> timeDragStrings = {
  '1m': 1,
  '5m': 5,
  '10m': 10,
  '15m': 15,
  '20m': 20,
  '25m': 25,
  '30m': 30,
  '45m': 45,
  '1h': 60,
  '1h 15m': 75,
  '1h 30m': 90,
  '2h': 120,
  '2h 15m': 135,
  '2h 30m': 150,
};

// SHARED PREFERENCES------------------------------------------------------------------------------------
const String prefsAPIKey = "api";
const String prefsAnonKey = "anon";
const String prefsTasksTodayName = "tasksToday";
const String prefsTasksTomorrowName = "tasksTomorrow";
const String prefsTasksUpcomingName = "tasksUpcoming";
const String prefsPlannerSections = "planner";

// SUPABASE SETTINGS-------------------------------------------------------------------------------------
// Create a new Supabase project.
// Go to Project Settings > API > Project URL and paste the url below
String SUPABASE_URL = "";

// Go to Project Settings > API > Project API Keys and paste the public anon below
String SUPABASE_ANON_KEY = "";
