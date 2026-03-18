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
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.steps;
    final stepText = _cleanStep(steps[_currentStep]);
    final secs = parseStepSeconds(steps[_currentStep]);
    final isLast = _currentStep == steps.length - 1;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: brandOrangeLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, top + 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão voltar
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 2, right: 12),
                    child: Icon(Icons.arrow_back_ios,
                        size: 20, color: Color(0xFF333333)),
                  ),
                ),

                // Info da receita
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.recipe.servings.isNotEmpty &&
                              widget.recipe.servings != '-') ...[
                            const Icon(Icons.people_outline,
                                size: 14, color: textMedium),
                            const SizedBox(width: 4),
                            Text(widget.recipe.servings,
                                style: const TextStyle(
                                    fontSize: 13, color: textMedium)),
                            const SizedBox(width: 16),
                          ],
                          if (widget.recipe.cookingTime.isNotEmpty &&
                              widget.recipe.cookingTime != '-') ...[
                            const Icon(Icons.schedule,
                                size: 14, color: textMedium),
                            const SizedBox(width: 4),
                            Text(widget.recipe.cookingTime,
                                style: const TextStyle(
                                    fontSize: 13, color: textMedium)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Contador de passo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_currentStep + 1}/${steps.length}',
                      style: const TextStyle(
                        color: brandOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('passos',
                        style: TextStyle(fontSize: 11, color: textMedium)),
                  ],
                ),
              ],
            ),
          ),

          // Barra de progresso
          LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            backgroundColor: const Color(0xFFEDE8E3),
            valueColor: const AlwaysStoppedAnimation(brandOrange),
            minHeight: 3,
          ),

          // ── Conteúdo do passo ────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topLeft,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: SingleChildScrollView(
                key: ValueKey(_currentStep),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      'Passo ${_currentStep + 1}',
                      style: const TextStyle(
                        color: brandOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Texto
                    Text(
                      stepText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.7,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),

                    // Timer
                    if (secs != null) ...[
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE5E0DA)),
                      const SizedBox(height: 20),
                      StepTimerWidget(totalSeconds: secs, large: true),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Navegação ────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Color(0xFFEDE8E3), width: 1)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: Color(0xFFDDD8D3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios,
                              size: 12, color: Color(0xFF666666)),
                          SizedBox(width: 4),
                          Text('Anterior',
                              style: TextStyle(color: Color(0xFF666666))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLast
                        ? () => Navigator.pop(context)
                        : () => setState(() => _currentStep++),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast ? badgeGreen : brandOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'Finalizar' : 'Próximo',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isLast ? Icons.check : Icons.arrow_forward_ios,
                          size: 13,
                        ),
                      ],
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
