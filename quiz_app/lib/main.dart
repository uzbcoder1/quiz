import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDB();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F6FA),
        fontFamily: 'Inter',
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
      ),
      home: DatabaseHelper.instance.currentUser == null
          ? const LoginScreen()
          : const MainScreen(),
    );
  }
}
