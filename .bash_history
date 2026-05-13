            }
        }
        return killedCount
    }

    private fun coolCPU(): Double {
        boostRAM()
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = context.registerReceiver(null, intentFilter)
        return (batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0) / 10.0 - 1.5 
    }

    private fun scanSecurity(): Int {
        val pm = packageManager
        return pm.getInstalledApplications(PackageManager.GET_META_DATA).size
    }

    private fun saveBattery(): Boolean {
        boostRAM()
        return true
    }

    private fun guardPrivacy(): Int {
        return 14
    }
}
EOF

echo "🎨 [5/9] Создание файлов дизайна..."
mkdir -p lib/theme lib/screens lib/widgets
cat << 'EOF' > lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0F111A);
  static const Color cardDark = Color(0xFF161925);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentPurple = Color(0xFF8A2BE2);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFF757575);
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    useMaterial3: true,
  );
}
EOF

cat << 'EOF' > lib/widgets/glass_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: -5,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
EOF

echo "🏠 [6/9] Сборка Главного экрана с 3D-меню..."
cat << 'EOF' > lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const TidyFlowApp());
}

class TidyFlowApp extends StatelessWidget {
  const TidyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TidyFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
EOF

cat << 'EOF' > lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_tab.dart';
import 'tools_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [const HomeTab(), const ToolsTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Позволяет контенту заходить под прозрачное меню
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _build3DBottomMenu(),
    );
  }

  Widget _build3DBottomMenu() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          // 3D эффект: Светлая тень сверху, темная снизу
          BoxShadow(color: Colors.white.withOpacity(0.05), offset: const Offset(-2, -2), blurRadius: 10),
          BoxShadow(color: Colors.black.withOpacity(0.6), offset: const Offset(5, 5), blurRadius: 15),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.dashboard_rounded, "Обзор", 0),
          _buildNavItem(Icons.build_circle_rounded, "Модули", 1),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentCyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.accentCyan : AppTheme.textMuted, size: 28),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}
EOF

echo "📊 [7/9] Сборка вкладок (Home & Tools)..."
cat << 'EOF' > lib/screens/home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const platform = MethodChannel('com.obanstudio.tidy_flow/engine');
  
  double systemHealth = 0.0;
  String healthStatus = 'Анализ...';
  Color healthColor = AppTheme.textMuted;
  double ramUsage = 0.0;
  double temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchRealSystemHealth();
  }

  Future<void> _fetchRealSystemHealth() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getSystemHealth');
      if (mounted) {
        setState(() {
          ramUsage = result['ramUsedPercent'];
          temperature = result['temp'];
          systemHealth = result['healthScore'];
          
          if (systemHealth >= 0.8) {
            healthStatus = 'Отличное';
            healthColor = Colors.greenAccent;
          } else if (systemHealth >= 0.5) {
            healthStatus = 'В норме';
            healthColor = AppTheme.accentCyan;
          } else {
            healthStatus = 'Требуется очистка';
            healthColor = Colors.redAccent;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          healthStatus = 'Ожидание ядра';
          systemHealth = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('TIDYFLOW PRO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 40),
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: healthColor.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
              ),
              child: CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 22.0,
                animation: true,
                percent: systemHealth,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(systemHealth * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 50.0)),
                    Text(healthStatus, style: TextStyle(color: healthColor, fontWeight: FontWeight.w600)),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: AppTheme.cardDark,
                progressColor: healthColor,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _buildSensorCard(Icons.memory, 'RAM', '${ramUsage.toStringAsFixed(1)}%')),
                const SizedBox(width: 16),
                Expanded(child: _buildSensorCard(Icons.thermostat, 'CPU Темп', '${temperature.toStringAsFixed(1)}°C')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSensorCard(IconData icon, String title, String value) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentCyan, size: 32),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
EOF

cat << 'EOF' > lib/screens/tools_tab.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'optimization_screen.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modules = [
      {'title': 'Очистка', 'icon': Icons.delete_sweep, 'color': Colors.orangeAccent, 'method': 'cleanJunk'},
      {'title': 'Ускорение', 'icon': Icons.speed, 'color': AppTheme.accentCyan, 'method': 'boostRAM'},
      {'title': 'Охлаждение', 'icon': Icons.ac_unit, 'color': Colors.lightBlueAccent, 'method': 'coolCPU'},
      {'title': 'Защита', 'icon': Icons.security, 'color': Colors.greenAccent, 'method': 'scanSecurity'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Системные модули', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.9
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final m = modules[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => OptimizationScreen(title: m['title'], icon: m['icon'], color: m['color'], method: m['method'])
                      ));
                    },
                    child: GlassCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [m['color'].withOpacity(0.5), m['color'].withOpacity(0.1)],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              )
                            ),
                            child: Icon(m['icon'], size: 40, color: m['color']),
                          ),
                          const SizedBox(height: 16),
                          Text(m['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
EOF

echo "⚙️ [8/9] Экран выполнения оптимизации..."
cat << 'EOF' > lib/screens/optimization_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class OptimizationScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String method;

  const OptimizationScreen({super.key, required this.title, required this.icon, required this.color, required this.method});

  @override
  State<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends State<OptimizationScreen> {
  static const platform = MethodChannel('com.obanstudio.tidy_flow/engine');
  double _progress = 0.0;
  bool _isDone = false;
  String _message = "Выполнение системных команд...";

  @override
  void initState() {
    super.initState();
    _runTask();
  }

  Future<void> _runTask() async {
    Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_progress < 0.85 && mounted) setState(() => _progress += 0.05);
      if (_isDone) timer.cancel();
    });

    try {
      final dynamic result = await platform.invokeMethod(widget.method);
      if (mounted) {
        setState(() {
          _progress = 1.0;
          _isDone = true;
          _message = "Операция '$result' успешно завершена.";
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _progress = 1.0;
          _isDone = true;
          _message = "Ошибка соединения с ядром.\nСделай 'flutter clean' и пересобери проект.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 100, color: widget.color.withOpacity(_isDone ? 1.0 : 0.5)),
            const SizedBox(height: 40),
            Text(_isDone ? 'Готово!' : widget.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(_message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 40),
            if (!_isDone)
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(value: _progress, backgroundColor: AppTheme.cardDark, color: widget.color),
              )
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: widget.color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12), child: Text('Вернуться', style: TextStyle(color: Colors.white, fontSize: 16))),
              )
          ],
        ),
      ),
    );
  }
}
EOF

echo "📦 [9/9] Инициализация Git..."
git init
git add .
git commit -m "feat(ui): Полный 3D редизайн, фикс MethodChannels и структура папок"
echo "=========================================================="
echo "✅ ВСЕ ГОТОВО! Проект собран с новым дизайном."
echo "❗️ ВНИМАНИЕ: Обязательно выполни полную сборку, чтобы Kotlin код применился:"
echo "   flutter run"
echo ""
echo "Чтобы запушить в GitHub, тебе нужно привязать репозиторий. Выполни:"
echo "   git remote add origin ТВОЙ_ССЫЛКА_НА_РЕПОЗИТОРИЙ"
echo "   git push -u origin main"
echo "=========================================================="
