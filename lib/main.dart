import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'src/screens/login_page.dart';
import 'src/screens/home_page.dart';
import 'src/data/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessário para o SQLite funcionar no Flutter Web
  databaseFactory = databaseFactoryFfiWeb;

  // Inicializa o banco
  final db = await DatabaseHelper().db;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
