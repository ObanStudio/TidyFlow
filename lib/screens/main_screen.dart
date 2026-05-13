import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/modules_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [DashboardTab(), ModulesTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          Positioned(
            bottom: 25, left: 20, right: 20,
            child: _build3DBottomMenu(),
          ),
        ],
      ),
    );
  }

  Widget _build3DBottomMenu() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppTheme.shadow3D,
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(Icons.dashboard_rounded, 'Статус', 0),
          _buildTabItem(Icons.grid_view_rounded, 'Модули', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 24 : 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentNeon.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? Border.all(color: AppTheme.accentNeon.withOpacity(0.3)) : null,
          boxShadow: isSelected ? AppTheme.shadowNeon : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.accentNeon : AppTheme.textMuted, size: 28),
            if (isSelected) ...[
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: AppTheme.accentNeon, fontWeight: FontWeight.bold, fontSize: 16)),
            ]
          ],
        ),
      ),
    );
  }
}
