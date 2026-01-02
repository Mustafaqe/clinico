import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/patient_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/prescription_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for desktop platforms
  await DatabaseHelper.initializeFfi();

  runApp(const ClinicoApp());
}

class ClinicoApp extends StatelessWidget {
  const ClinicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider()),
      ],
      child: MaterialApp(
        title: 'Clinico',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
