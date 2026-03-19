import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../theme/app_colors.dart';

class StepTimerWidget extends StatefulWidget {
  final int totalSeconds;
  final bool large;
  final bool circular;
  const StepTimerWidget({
    super.key,
    required this.totalSeconds,
    this.large = false,
    this.circular = false,
  });

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
  void didUpdateWidget(StepTimerWidget old) {
    super.didUpdateWidget(old);
    if (old.totalSeconds != widget.totalSeconds) {
      _timer?.cancel();
      setState(() {
        _remaining = widget.totalSeconds;
        _running = false;
        _done = false;
      });
    }
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

  // ── Modo circular ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.circular) return _buildCircular();
    if (widget.large) return _buildLarge();
    return _buildCompact();
  }

  Widget _buildCircular() {
    final progress = widget.totalSeconds > 0
        ? _remaining / widget.totalSeconds
        : 0.0;

    return Column(
      children: [
        // Círculo com arco
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arco de fundo
              CustomPaint(
                size: const Size(180, 180),
                painter: _ArcPainter(
                  progress: progress,
                  done: _done,
                ),
              ),
              // Tempo no centro
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _done ? '00:00' : _format(_remaining),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: _done ? badgeGreen : neutralDark,
                      letterSpacing: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _done ? 'PRONTO!' : 'MINUTOS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: _done ? badgeGreen : const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Controles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset
            GestureDetector(
              onTap: _reset,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.replay,
                    size: 20, color: Color(0xFF888888)),
              ),
            ),
            const SizedBox(width: 20),

            // Play / Pause
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _done ? badgeGreen : brandOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_done ? badgeGreen : brandOrange)
                          .withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _done
                      ? Icons.check
                      : (_running ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Modo large (retângulo) ─────────────────────────────────────────────────
  Widget _buildLarge() {
    final isActive = _running || _done;
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

  // ── Modo compacto (pill) ───────────────────────────────────────────────────
  Widget _buildCompact() {
    final isActive = _running || _done;
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

// ── Arc Painter ───────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final bool done;

  _ArcPainter({required this.progress, required this.done});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 8.0;
    const startAngle = -pi / 2;

    // Trilha (fundo)
    final trackPaint = Paint()
      ..color = const Color(0xFFEDE8E3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Arco de progresso
    final arcPaint = Paint()
      ..color = done ? const Color(0xFF43A047) : brandOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.done != done;
}

// ── Parse helper ─────────────────────────────────────────────────────────────

int? parseStepSeconds(String step) {
  int total = 0;
  final hourMatch =
      RegExp(r'(\d+)\s*hora', caseSensitive: false).firstMatch(step);
  final minMatch =
      RegExp(r'(\d+)\s*(minutos?|min\b)', caseSensitive: false).firstMatch(step);
  if (hourMatch != null) total += int.parse(hourMatch.group(1)!) * 3600;
  if (minMatch != null) total += int.parse(minMatch.group(1)!) * 60;
  return total > 0 ? total : null;
}
