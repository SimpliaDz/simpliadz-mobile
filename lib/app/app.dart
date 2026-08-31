import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/features/auth/presentation/screens/login_screen.dart';

class SimpliaDzApp extends StatelessWidget {
  const SimpliaDzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpliaDz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
