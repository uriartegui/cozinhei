import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.steps;
    final progress = (_currentStep + 1) / steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: brandOrange,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Progresso
            Column(
              children: [
                Text(
                  'Passo ${_currentStep + 1} de ${steps.length}',
                  style: const TextStyle(
                    color: brandOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: surfaceGray,
                  color: brandOrange,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            // Conteúdo do passo
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Column(
                key: ValueKey(_currentStep),
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: brandOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentStep + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          _cleanStep(steps[_currentStep]),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Builder(builder: (_) {
                    final secs = parseStepSeconds(steps[_currentStep]);
                    if (secs == null) return const SizedBox.shrink();
                    return StepTimerWidget(totalSeconds: secs, large: true);
                  }),
                ],
              ),
            ),

            // Botões de navegação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentStep > 0
                        ? () => setState(() => _currentStep--)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _currentStep < steps.length - 1
                      ? ElevatedButton.icon(
                    onPressed: () => setState(() => _currentStep++),
                    icon: const Text('Próximo'),
                    label: const Icon(Icons.arrow_forward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Finalizar! 🎉',
                        style:
                        TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
