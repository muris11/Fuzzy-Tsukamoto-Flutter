import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final colorSeed = const Color(0xFF6366F1);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiagnoFuzzy',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: colorSeed,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MainPage(),
    );
  }
}
