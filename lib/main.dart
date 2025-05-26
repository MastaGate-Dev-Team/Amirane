import 'package:flutter/material.dart';
import 'package:bouf/screens/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {

    await Supabase.initialize(
    url: 'https://wlfkosccqrzontpkzjrb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZmtvc2NjcXJ6b250cGt6anJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1MjMwMDAsImV4cCI6MjA1NjA5OTAwMH0.uGadtPSYUVTyA5ZMdwT9X3rRelegDMfKUVUbOqawJbM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aimirane Express',
       debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Monsterrat',
      ),
      home: const SplashScreen(),
      
      
    );
  }
}