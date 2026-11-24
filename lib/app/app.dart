import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/features/auth/data/data_sources/auth_api_data_source.dart';
import 'package:simpliadz_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:simpliadz_mobile/features/auth/data/storage/refresh_token_store.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simpliadz_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/dashboard/data/data_sources/dashboard_api_data_source.dart';
import 'package:simpliadz_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:simpliadz_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';

class SimpliaDzApp extends StatefulWidget {
  const SimpliaDzApp({super.key});

  @override
  State<SimpliaDzApp> createState() => _SimpliaDzAppState();
}

class _SimpliaDzAppState extends State<SimpliaDzApp> {
  late final AuthController _authController;
  late final DashboardController _dashboardController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      AuthRepositoryImpl(AuthApiDataSource(), RefreshTokenStore()),
    );
    _dashboardController = DashboardController(
      DashboardRepositoryImpl(
        DashboardApiDataSource(
          AuthenticatedApiClient(tokenProvider: _authController.accessToken),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    _dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpliaDz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF156F63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: LoginScreen(
        authController: _authController,
        dashboardController: _dashboardController,
      ),
    );
  }
}
