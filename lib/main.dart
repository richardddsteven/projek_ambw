import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_ambw/screens/home_screen.dart';
import 'package:projek_ambw/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hjhwpeokoztuaifxgfky.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhqaHdwZW9rb3p0dWFpZnhnZmt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzMTc5NzQsImV4cCI6MjA2NTg5Mzk3NH0.HJhH6WCN26_c14JMkycWInFITJByZkdwZ5328-WdERk',
  );
  
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Booking App',
      theme: AppTheme.theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
