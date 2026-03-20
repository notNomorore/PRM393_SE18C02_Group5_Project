import 'package:flutter/material.dart';
import 'package:project_prm/data/features/auth/screens/auth_screen.dart';

import '../data/features/auth/screens/login_screen.dart';
import '../data/features/auth/screens/register_screen.dart';
import '../data/features/auth/screens/splash_screen.dart';
import '../data/features/product/screens/product_list_screen.dart';

class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const AuthScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const ProductListScreen(),
  };
}