import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/features/auth/data/data_sources/auth_api_data_source.dart';
import 'package:simpliadz_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:simpliadz_mobile/features/auth/data/storage/refresh_token_store.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simpliadz_mobile/features/auth/presentation/screens/login_screen.dart';

class SimpliaDzApp extends StatefulWidget {
  const SimpliaDzApp({super.key});

  @override
  State<SimpliaDzApp> createState() => _SimpliaDzAppState();
}

class _SimpliaDzAppState extends State<SimpliaDzApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      AuthRepositoryImpl(AuthApiDataSource(), RefreshTokenStore()),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpliaDz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(),
        ),
      ),
      home: LoginScreen(authController: _authController),
    );
  }
}
