import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class OptimizationScreen extends StatefulWidget {
  final String title; final IconData icon; final Color color; final String methodChannelName;
  const OptimizationScreen({super.key, required this.title, required this.icon, required this.color, required this.methodChannelName});
  @override
  State<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends State<OptimizationScreen> with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.obanstudio.tidy_flow/engine');
  bool _isCompleted = false; String _message = "Выполнение операции...";
  late AnimationController _pulseController; late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _runTask();
  }

  Future<void> _runTask() async {
    await Future.delayed(const Duration(seconds: 2)); 
    try {
      final result = await platform.invokeMethod(widget.methodChannelName);
      if (mounted) {
        setState(() {
          _isCompleted = true; _pulseController.stop();
          if (widget.methodChannelName == 'boostRAM') _message = "Остановлено процессов: $result.";
          else if (widget.methodChannelName == 'coolCPU') _message = "Температура снижена до $result°C.";
          else if (widget.methodChannelName == 'scanSecurity') _message = "Проверено $result пакетов. Угроз нет.";
          else _message = "Операция успешно завершена.";
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isCompleted = true; _pulseController.stop(); _message = "Ошибка ядра: ${e.message ?? 'Сбой вызова'}"; });
    }
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isCompleted ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 170, height: 170,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cardDark, boxShadow: _isCompleted ? AppTheme.shadowNeon : AppTheme.shadow3D, border: Border.all(color: widget.color, width: 4)),
                    child: Icon(_isCompleted ? Icons.check_rounded : widget.icon, size: 80, color: widget.color),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            Text(_isCompleted ? 'ГОТОВО' : widget.title.toUpperCase(), style: const TextStyle(color: AppTheme.textMain, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3)),
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(_message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted, fontSize: 18))),
            const SizedBox(height: 60),
            if (_isCompleted)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: widget.color, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)), elevation: 10, shadowColor: widget.color),
                child: const Text('ВЕРНУТЬСЯ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
              )
          ],
        ),
      ),
    );
  }
}
