import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../optimization_screen.dart';

class ModulesTab extends StatelessWidget {
  const ModulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modules = [
      {'title': 'Очистка', 'icon': Icons.delete_sweep_rounded, 'color': AppTheme.warning, 'method': 'cleanJunk'},
      {'title': 'Ускорение', 'icon': Icons.speed_rounded, 'color': AppTheme.accentNeon, 'method': 'boostRAM'},
      {'title': 'Защита', 'icon': Icons.security_rounded, 'color': AppTheme.success, 'method': 'scanSecurity'},
      {'title': 'Охлаждение', 'icon': Icons.ac_unit_rounded, 'color': Colors.lightBlueAccent, 'method': 'coolCPU'},
      {'title': 'Энергия', 'icon': Icons.battery_charging_full_rounded, 'color': AppTheme.success, 'method': 'saveBattery'},
      {'title': 'Приватность', 'icon': Icons.privacy_tip_rounded, 'color': AppTheme.accentPink, 'method': 'guardPrivacy'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text('МОДУЛИ', style: TextStyle(color: AppTheme.textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 0.85),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final m = modules[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OptimizationScreen(title: m['title'], icon: m['icon'], color: m['color'], methodChannelName: m['method']))),
                    child: Container(
                      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(30), boxShadow: AppTheme.shadow3D),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: m['color'].withOpacity(0.1), border: Border.all(color: m['color'].withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: m['color'].withOpacity(0.2), blurRadius: 20)]),
                            child: Icon(m['icon'], size: 45, color: m['color']),
                          ),
                          const SizedBox(height: 25),
                          Text(m['title'], style: const TextStyle(color: AppTheme.textMain, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
