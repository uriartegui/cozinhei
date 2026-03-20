import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../viewmodel/house_notifier.dart';

class HouseSetupScreen extends ConsumerStatefulWidget {
  const HouseSetupScreen({super.key});

  @override
  ConsumerState<HouseSetupScreen> createState() => _HouseSetupScreenState();
}

class _HouseSetupScreenState extends ConsumerState<HouseSetupScreen> {
  static const _kBlue = Color(0xFF007AFF);
  static const _kBg = Color(0xFFFAF7F2);
  static const _kFieldBg = Color(0xFFF2F2F7);

  final _houseNameCtrl = TextEditingController();
  final _userNameCtrl  = TextEditingController();
  final _codeCtrl      = TextEditingController();
  bool _showCreate = false;
  bool _showJoin   = false;

  @override
  void dispose() {
    _houseNameCtrl.dispose();
    _userNameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(houseProvider);
    final notifier = ref.read(houseProvider.notifier);
    final isLoading = state.status == HouseStatus.loading;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text('🏠', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 20),
              const Text(
                'Geladeira\nCompartilhada',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
              ),
              const SizedBox(height: 12),
              const Text(
                'Crie uma geladeira ou entre na de alguém para compartilhar em tempo real.',
                style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93), height: 1.4),
              ),

              if (state.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],

              const Spacer(),

              // ── Criar geladeira ──────────────────────────────────────────────
              if (_showCreate) ...[
                _label('Seu nome'),
                const SizedBox(height: 6),
                _field(_userNameCtrl, 'Ex: Gui', TextInputAction.next),
                const SizedBox(height: 12),
                _label('Nome da geladeira'),
                const SizedBox(height: 6),
                _field(_houseNameCtrl, 'Ex: Casa do Gui', TextInputAction.done),
                const SizedBox(height: 20),
                _primaryButton(
                  isLoading ? 'Criando...' : 'Criar geladeira',
                  isLoading ? null : () async {
                    if (_userNameCtrl.text.trim().isEmpty ||
                        _houseNameCtrl.text.trim().isEmpty) return;
                    await notifier.createHouse(
                      _houseNameCtrl.text.trim(),
                      _userNameCtrl.text.trim(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ghostButton('Voltar', () => setState(() => _showCreate = false)),
              ]

              // ── Entrar com código ────────────────────────────────────────────
              else if (_showJoin) ...[
                _label('Seu nome'),
                const SizedBox(height: 6),
                _field(_userNameCtrl, 'Ex: Ana', TextInputAction.next),
                const SizedBox(height: 12),
                _label('Código da geladeira'),
                const SizedBox(height: 6),
                _field(_codeCtrl, 'Ex: ABC123', TextInputAction.done, uppercase: true),
                const SizedBox(height: 20),
                _primaryButton(
                  isLoading ? 'Entrando...' : 'Entrar',
                  isLoading ? null : () async {
                    if (_userNameCtrl.text.trim().isEmpty ||
                        _codeCtrl.text.trim().isEmpty) return;
                    await notifier.joinHouse(
                      _codeCtrl.text.trim(),
                      _userNameCtrl.text.trim(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ghostButton('Voltar', () => setState(() => _showJoin = false)),
              ]

              // ── Escolha inicial ──────────────────────────────────────────────
              else ...[
                _primaryButton('Criar uma geladeira', () => setState(() => _showCreate = true)),
                const SizedBox(height: 12),
                _ghostButton('Entrar com código', () => setState(() => _showJoin = true)),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    TextInputAction action, {
    bool uppercase = false,
  }) =>
      TextField(
        controller: ctrl,
        textInputAction: action,
        textCapitalization: TextCapitalization.words,
        inputFormatters: uppercase ? [UpperCaseTextFormatter()] : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: _kFieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBlue, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _primaryButton(String label, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 54,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onTap == null ? _kBlue.withOpacity(0.5) : _kBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    ),
  );

  Widget _ghostButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 54,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _kFieldBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label,
          style: const TextStyle(color: Color(0xFF3C3C43), fontWeight: FontWeight.w600, fontSize: 16)),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) =>
      newVal.copyWith(text: newVal.text.toUpperCase());
}
