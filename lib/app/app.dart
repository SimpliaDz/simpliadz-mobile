import 'package:flutter/material.dart';
import 'package:simplia_mobile/app/app_theme.dart';
import 'package:simplia_mobile/features/auth/data/data_sources/auth_api_data_source.dart';
import 'package:simplia_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:simplia_mobile/features/auth/data/storage/refresh_token_store.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simplia_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/dashboard/data/data_sources/dashboard_api_data_source.dart';
import 'package:simplia_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:simplia_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';

class SimpliaWearApp extends StatefulWidget {
  const SimpliaWearApp({super.key});

  @override
  State<SimpliaWearApp> createState() => _SimpliaWearAppState();
}

class _SimpliaWearAppState extends State<SimpliaWearApp> {
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
      title: 'SimpliaWear',
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      home: LoginScreen(
        authController: _authController,
        dashboardController: _dashboardController,
      ),
    );
  }
}
