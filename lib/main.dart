import 'package:flutter/material.dart';

import 'src/screens/login_page.dart';
import 'src/screens/signup_page.dart';
import 'src/screens/home_page.dart';
import 'src/screens/profile_page.dart';

import 'src/data/database_helper.dart';
import 'src/data/repositories/users_repository.dart';
import 'src/data/models/users.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final db = await dbHelper.db;

  // final repo = UsersRepository();

  await dbHelper.printDatabaseContent();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
