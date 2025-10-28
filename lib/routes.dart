import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/quiz_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String quizList = '/quiz_list';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getAll() {
    return {
      splash: (_) => SplashScreen(),
      home: (_) => HomeScreen(),
      courses: (_) => CoursesScreen(),
      quizList: (_) => QuizListScreen(),
      profile: (_) => ProfileScreen(),
      settings: (_) => SettingsScreen(),
    };
  }
}
