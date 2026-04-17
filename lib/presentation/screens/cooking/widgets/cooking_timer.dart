import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CookingTimer extends StatefulWidget {
  final int initialMinutes;

  const CookingTimer({super.key, required this.initialMinutes});

  @override
  State<CookingTimer> createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer> {
  late int _remaining; // seconds
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining > 0) {
          setState(() => _remaining--);
        } else {
          _timer?.cancel();
          setState(() => _running = false);
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = widget.initialMinutes * 60;
      _running = false;
    });
  }

  String get _display {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _remaining == 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _display,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDone ? AppColors.secondary : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: isDone ? _reset : _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDone
                    ? [AppColors.secondary, AppColors.secondaryContainer]
                    : [AppColors.primary, AppColors.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isDone
                      ? Icons.replay
                      : (_running ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isDone
                      ? 'Recommencer'
                      : (_running ? 'Pause' : 'Démarrer'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
