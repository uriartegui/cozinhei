import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../model/recipe.dart';
import '../../widgets/step_timer_widget.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;
  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;

  String _cleanStep(String step) {
    return step
        .replaceAll(RegExp(r'^Passo\s+\d+[:.)]?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*\(\d+\s*minutos?\)', caseSensitive: false), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.steps;
    final stepText = _cleanStep(steps[_currentStep]);
    final secs = parseStepSeconds(steps[_currentStep]);
    final isLast = _currentStep == steps.length - 1;
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EF),
      body: Column(
        children: [

          // ── Header ─────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, top + 12, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      size: 22, color: Color(0xFF333333)),
                ),
                Expanded(
                  child: Text(
                    'Passo ${_currentStep + 1} de ${steps.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: neutralDark,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 22),
              ],
            ),
          ),

          // ── Progress bar ────────────────────────────────────────
          LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            backgroundColor: const Color(0xFFEDE8E3),
            valueColor: const AlwaysStoppedAnimation(brandOrange),
            minHeight: 2,
          ),

          // ── Conteúdo ────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey(_currentStep),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Header fixo — sempre na mesma posição ──────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'MODO COZINHA',
                          style: TextStyle(
                            color: brandOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.recipe.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: neutralDark,
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Card + timer (scrollável) ──────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Card com o texto do passo
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              stepText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                                color: neutralDark,
                              ),
                            ),
                          ),

                          // Timer circular
                          if (secs != null) ...[
                            const SizedBox(height: 28),
                            StepTimerWidget(totalSeconds: secs, circular: true),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Botão de navegação ──────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 16),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentStep--),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDEA),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios,
                                size: 12, color: Color(0xFF555555)),
                            SizedBox(width: 4),
                            Text('Anterior',
                                style: TextStyle(
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: isLast
                        ? () => Navigator.pop(context)
                        : () => setState(() => _currentStep++),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: isLast
                            ? const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                              )
                            : brandGradient,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: (isLast
                                    ? const Color(0xFF2E7D32)
                                    : brandOrange)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLast ? Icons.check : Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: isLast ? 16 : 13,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLast ? 'Finalizar Passo' : 'Próximo Passo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
