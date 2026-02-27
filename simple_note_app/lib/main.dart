import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Note App',
      theme: ThemeData(
        useMaterial3: true,
        // Sử dụng ColorSchemeSeed để tự động tạo bảng màu hài hòa
        colorSchemeSeed: Colors.teal, 
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Nền trắng xám sang trọng
      ),
      home: const HomeScreen(),
    );
  }
}
