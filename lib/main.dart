import 'package:dsas_app/viewmodels/profile_viewmodel.dart';
import 'package:dsas_app/viewmodels/register_student_card_view_model.dart';
import 'package:dsas_app/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vlczvgksmheqtkwmuecr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZsY3p2Z2tzbWhlcXRrd211ZWNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3NzY3ODEsImV4cCI6MjEwMzM1Mjc4MX0.z0-yt0CdppUJB_35hjWpN0w8hKFUI2Rv5GE2uKqjY1s',
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
  ChangeNotifierProvider(create: (_) => ProfileViewmodel()),
  ChangeNotifierProvider(create: (_) => RegisterStudentCardViewModel()),
],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          themeMode: ThemeMode.dark,
          home: const AuthGate(),
        );
      },
    );
  }
}
