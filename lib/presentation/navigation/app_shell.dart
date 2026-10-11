import 'package:flutter/material.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';
import '../screens/arte_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/drive_integration_screen.dart';
import '../screens/inventario_screen.dart';
import '../screens/maestras_screen.dart';
import '../screens/muebles_screen.dart';
import '../screens/nomina_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final MockDatabaseService _db = MockDatabaseService();

  @override
  void initState() {
    super.initState();
    _db.addListener(() {
      setState(() {});
    });
  }

  void _navigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(db: _db, onNavigateTab: _navigateTab),
      MueblesScreen(db: _db),
      ArteScreen(db: _db),
      NominaScreen(db: _db),
      InventarioScreen(db: _db),
      MaestrasScreen(db: _db),
      DriveIntegrationScreen(db: _db),
    ];

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.handyman, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                children: [
                  TextSpan(text: 'Carpint', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'Art', style: TextStyle(color: AppTheme.primaryGold)),
                  TextSpan(text: ' • ERP Taller & Arte', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _db.driveConectado ? AppTheme.successGreen.withValues(alpha: 0.2) : AppTheme.errorRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _db.driveConectado ? AppTheme.successGreen : AppTheme.errorRed),
            ),
            child: Row(
              children: [
                Icon(
                  _db.driveConectado ? Icons.cloud_done : Icons.cloud_off,
                  color: _db.driveConectado ? AppTheme.successGreen : AppTheme.errorRed,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _db.driveConectado ? 'Drive Online' : 'Drive Offline',
                  style: TextStyle(
                    color: _db.driveConectado ? AppTheme.successGreen : AppTheme.errorRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppTheme.surfaceDark,
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryGold),
                  selectedLabelTextStyle: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedIconTheme: const IconThemeData(color: AppTheme.textMuted),
                  unselectedLabelTextStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.carpenter), label: Text('Muebles RH')),
                    NavigationRailDestination(icon: Icon(Icons.brush), label: Text('Estudio Arte')),
                    NavigationRailDestination(icon: Icon(Icons.badge), label: Text('Nómina')),
                    NavigationRailDestination(icon: Icon(Icons.inventory), label: Text('Inventario')),
                    NavigationRailDestination(icon: Icon(Icons.tune), label: Text('Maestras')),
                    NavigationRailDestination(icon: Icon(Icons.cloud), label: Text('Google Drive')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF334155)),
                Expanded(child: screens[_currentIndex]),
              ],
            )
          : screens[_currentIndex],
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppTheme.surfaceDark,
              selectedItemColor: AppTheme.primaryGold,
              unselectedItemColor: AppTheme.textMuted,
              selectedFontSize: 10,
              unselectedFontSize: 9,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.carpenter), label: 'Muebles'),
                BottomNavigationBarItem(icon: Icon(Icons.brush), label: 'Arte'),
                BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Nómina'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventario'),
                BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Maestras'),
                BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Drive'),
              ],
            ),
    );
  }
}
