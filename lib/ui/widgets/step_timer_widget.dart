import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../theme/app_colors.dart';

class StepTimerWidget extends StatefulWidget {
  final int totalSeconds;
  final bool large;
  const StepTimerWidget({super.key, required this.totalSeconds, this.large = false});

  @override
  State<StepTimerWidget> createState() => _StepTimerWidgetState();
}

class _StepTimerWidgetState extends State<StepTimerWidget> {
  late int _remaining;
  bool _running = false;
  bool _done = false;
  Timer? _timer;
  final _ringtone = FlutterRingtonePlayer();

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringtone.stop();
    super.dispose();
  }

  void _toggle() {
    if (_done) {
      _ringtone.stop();
      setState(() {
        _remaining = widget.totalSeconds;
        _done = false;
        _running = false;
      });
      return;
    }
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          if (_remaining > 0) {
            _remaining--;
          } else {
            _done = true;
            _running = false;
            t.cancel();
            HapticFeedback.heavyImpact();
            _ringtone.play(
              android: AndroidSounds.alarm,
              ios: IosSounds.alarm,
              looping: false,
              volume: 1.0,
              asAlarm: false,
            );
          }
        });
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    _ringtone.stop();
    setState(() {
      _remaining = widget.totalSeconds;
      _done = false;
      _running = false;
    });
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _running || _done;

    if (widget.large) {
      return GestureDetector(
        onTap: _toggle,
        onLongPress: _reset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _done
                ? badgeGreen
                : isActive
                ? brandOrange
                : brandOrangeLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _done ? badgeGreen : brandOrange,
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: (_done ? badgeGreen : brandOrange)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _done
                    ? Icons.check_circle
                    : (_running ? Icons.pause_circle : Icons.play_circle),
                size: 28,
                color: isActive ? Colors.white : brandOrange,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _done ? 'Pronto! 🎉' : _format(_remaining),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : brandOrange,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _done
                        ? 'Segure para reiniciar'
                        : (_running ? 'Toque para pausar' : 'Toque para iniciar'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : textMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Versão compacta (tela de detalhes)
    return GestureDetector(
      onTap: _toggle,
      onLongPress: _reset,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _done
              ? badgeGreen
              : isActive
              ? brandOrange
              : brandOrangeLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _done ? badgeGreen : brandOrange,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _done ? Icons.check : (_running ? Icons.pause : Icons.play_arrow),
              size: 13,
              color: isActive ? Colors.white : brandOrange,
            ),
            const SizedBox(width: 4),
            Text(
              _done ? 'Pronto!' : _format(_remaining),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : brandOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int? parseStepSeconds(String step) {
  int total = 0;
  final hourMatch = RegExp(r'(\d+)\s*hora', caseSensitive: false).firstMatch(step);
  final minMatch = RegExp(r'(\d+)\s*(minutos?|min\b)', caseSensitive: false).firstMatch(step);
  if (hourMatch != null) total += int.parse(hourMatch.group(1)!) * 3600;
  if (minMatch != null) total += int.parse(minMatch.group(1)!) * 60;
  return total > 0 ? total : null;
}
