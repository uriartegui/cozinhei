import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../../../providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos.');
      return;
    }

    if (_isSignUp) {
      if (_displayNameController.text.trim().isEmpty) {
        _showError('Informe seu nome de exibição.');
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        _showError('Informe seu telefone.');
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('As senhas não coincidem.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'display_name': _displayNameController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verifique seu email para confirmar o cadastro.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(isUserActivatedProvider.notifier).state = true;
          context.go(Uri.decodeComponent(widget.redirectTo ?? '/'));
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) {
          ref.read(isUserActivatedProvider.notifier).state = true;
          context.go(Uri.decodeComponent(widget.redirectTo ?? '/'));
        }
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: brandOrangeDark,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Fundo gradiente ──────────────────────────────────────────
          Container(
            height: size.height,
            decoration: const BoxDecoration(gradient: brandGradient),
          ),

          // ── Hero section ─────────────────────────────────────────────
          Positioned(
            top: top + 28,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Ícone
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('🍳', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Cozinhei',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _isSignUp
                        ? 'Crie sua conta gratuita'
                        : 'Bem-vindo de volta!',
                    key: ValueKey(_isSignUp),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card branco deslizante ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: size.height * 0.30,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toggle Entrar / Criar conta
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _Tab(
                            label: 'Entrar',
                            active: !_isSignUp,
                            onTap: () => setState(() => _isSignUp = false),
                          ),
                          _Tab(
                            label: 'Criar conta',
                            active: _isSignUp,
                            onTap: () => setState(() => _isSignUp = true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email
                    const _Label(text: 'Email'),
                    const SizedBox(height: 6),
                    _Input(
                      controller: _emailController,
                      hint: 'nome@exemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Campos extras de cadastro (Nome e Telefone)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _isSignUp
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _Label(text: 'Nome de exibição'),
                                const SizedBox(height: 6),
                                _Input(
                                  controller: _displayNameController,
                                  hint: 'Como quer ser chamado?',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 16),
                                const _Label(text: 'Telefone'),
                                const SizedBox(height: 6),
                                _Input(
                                  controller: _phoneController,
                                  hint: '(11) 99999-9999',
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Icons.phone_outlined,
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Senha
                    const _Label(text: 'Senha'),
                    const SizedBox(height: 6),
                    _Input(
                      controller: _passwordController,
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      autofillHints: _isSignUp
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      prefixIcon: Icons.lock_outline_rounded,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: neutralMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmar senha (somente no cadastro)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _isSignUp
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _Label(text: 'Confirmar senha'),
                                const SizedBox(height: 6),
                                _Input(
                                  controller: _confirmPasswordController,
                                  hint: '••••••••',
                                  obscureText: _obscureConfirmPassword,
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffix: GestureDetector(
                                    onTap: () => setState(() =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword),
                                    child: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: neutralMedium,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                              ],
                            )
                          : const SizedBox(height: 12),
                    ),

                    // Botão principal
                    _SubmitButton(
                      label: _isSignUp ? 'Criar conta' : 'Entrar',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 20),

                    // Divisor
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE8E0D8), thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou',
                            style: TextStyle(
                              fontSize: 12,
                              color: neutralMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE8E0D8), thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Continuar sem conta
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE8E0D8),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continuar sem conta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: neutralMedium,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? neutralDark : neutralMedium,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: neutralMedium,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final IconData prefixIcon;
  final Widget? suffix;

  const _Input({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECE8E3), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        style: const TextStyle(
          fontSize: 15,
          color: neutralDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: neutralMedium.withOpacity(0.6),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(prefixIcon, size: 20, color: neutralMedium),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffix,
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading ? null : brandGradient,
          color: isLoading ? const Color(0xFFE0D8D0) : null,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: brandOrange.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
      ),
    );
  }
}
