import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CarpintArtApp());
}

class CarpintArtApp extends StatelessWidget {
  const CarpintArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarpintArt ERP - Taller de Muebles & Estudio de Arte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
