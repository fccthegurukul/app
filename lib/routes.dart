// lib/config/routes.dart

import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/course_screen.dart';
import '../screens/news_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String quiz = '/quiz';
  static const String course = '/course';
  static const String news = '/news';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      onboarding: (context) => const OnboardingScreen(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      quiz: (context) => const QuizScreen(),
      course: (context) => const CourseScreen(),
      news: (context) => const NewsScreen(),
    };
  }
}
