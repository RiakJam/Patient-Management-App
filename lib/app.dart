import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';

class PatientManagementApp extends StatelessWidget {
  final DatabaseService databaseService = DatabaseService();
  final AuthService authService = AuthService();

  PatientManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => databaseService),
        Provider<AuthService>(create: (_) => authService),
      ],
      child: MaterialApp(
        title: 'Patient Management',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/login',
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}