import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  static const platform = MethodChannel('com.obanstudio.tidy_flow/engine');
  
  double systemHealth = 0.0;
  String healthStatus = 'Анализ...';
  Color healthColor = AppTheme.textMuted;
  double ramUsage = 0.0;
  double temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _fetchData();
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage, Permission.manageExternalStorage].request();
  }

  Future<void> _fetchData() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getSystemHealth');
      if (mounted) {
        setState(() {
          ramUsage = result['ramUsedPercent'];
          temperature = result['temp'];
          systemHealth = result['healthScore'];
          
          if (systemHealth >= 0.8) {
            healthStatus = 'ОТЛИЧНО'; healthColor = AppTheme.success;
          } else if (systemHealth >= 0.5) {
            healthStatus = 'В НОРМЕ'; healthColor = AppTheme.warning;
          } else {
            healthStatus = 'ОПАСНОСТЬ'; healthColor = AppTheme.danger;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { healthStatus = 'ОШИБКА ДАТЧИКОВ'; systemHealth = 0.1; healthColor = AppTheme.danger; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('СИСТЕМА', style: TextStyle(color: AppTheme.textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: AppTheme.shadow3D),
              child: CircularPercentIndicator(
                radius: 140.0, lineWidth: 25.0, animation: true, animateFromLastPercent: true, percent: systemHealth,
                circularStrokeCap: CircularStrokeCap.round, backgroundColor: AppTheme.bgDark,
                progressColor: healthColor,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(systemHealth * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 60.0, color: AppTheme.textMain)),
                    const SizedBox(height: 5),
                    Text(healthStatus, style: TextStyle(fontSize: 16.0, color: healthColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _build3DStatCard(Icons.memory, 'ОЗУ', '${ramUsage.toStringAsFixed(1)}%', AppTheme.accentNeon),
                const SizedBox(width: 25),
                _build3DStatCard(Icons.thermostat, 'ЦП', '${temperature.toStringAsFixed(1)}°C', AppTheme.accentPink),
              ],
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  Widget _build3DStatCard(IconData icon, String title, String val, Color color) {
    return Container(
      width: 150, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(25), boxShadow: AppTheme.shadow3D, border: Border.all(color: color.withOpacity(0.2), width: 1)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(val, style: const TextStyle(color: AppTheme.textMain, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
