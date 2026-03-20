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

  String? _emailError;
  String? _displayNameError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _clearErrors() {
    _emailError = null;
    _displayNameError = null;
    _phoneError = null;
    _passwordError = null;
    _confirmPasswordError = null;
  }

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
    setState(() => _clearErrors());

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool hasError = false;

    if (email.isEmpty) {
      setState(() => _emailError = 'Informe o email.');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Informe a senha.');
      hasError = true;
    }

    if (_isSignUp) {
      if (_displayNameController.text.trim().isEmpty) {
        setState(() => _displayNameError = 'Informe seu nome de exibição.');
        hasError = true;
      }
      if (_phoneController.text.trim().isEmpty) {
        setState(() => _phoneError = 'Informe seu telefone.');
        hasError = true;
      } else {
        final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 10 || digits.length > 11) {
          setState(() => _phoneError = 'Telefone inválido. Informe DDD + 8 ou 9 dígitos.');
          hasError = true;
        }
      }
      if (_confirmPasswordController.text.isEmpty) {
        setState(() => _confirmPasswordError = 'Confirme sua senha.');
        hasError = true;
      } else if (password != _confirmPasswordController.text) {
        setState(() => _confirmPasswordError = 'As senhas não coincidem.');
        hasError = true;
      }
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final displayName = _displayNameController.text.trim();
        final phone = _phoneController.text.trim();

        // Valida tudo em paralelo
        final results = await Future.wait([
          Supabase.instance.client.from('profiles').select('id').eq('display_name', displayName).maybeSingle(),
          Supabase.instance.client.from('profiles').select('id').eq('phone', phone).maybeSingle(),
          Supabase.instance.client.from('profiles').select('id').eq('email', email).maybeSingle(),
        ]);

        bool hasConflict = false;
        if (results[0] != null) {
          setState(() => _displayNameError = 'Este nome já está em uso.');
          hasConflict = true;
        }
        if (results[1] != null) {
          setState(() => _phoneError = 'Este telefone já está cadastrado.');
          hasConflict = true;
        }
        if (results[2] != null) {
          setState(() => _emailError = 'Este email já está cadastrado.');
          hasConflict = true;
        }
        if (hasConflict) return;

        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'display_name': displayName, 'phone': phone},
        );

        if (response.user != null) {
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'display_name': displayName,
            'phone': phone,
            'email': email,
          });
        }

        if (mounted) {
          ref.read(isUserActivatedProvider.notifier).state = true;
          _invalidateProviders();
          context.go(Uri.decodeComponent(widget.redirectTo ?? '/'));
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) {
          ref.read(isUserActivatedProvider.notifier).state = true;
          _invalidateProviders();
          context.go(Uri.decodeComponent(widget.redirectTo ?? '/'));
        }
      }
    } on AuthException catch (e) {
      final msg = _translateError(e.message);
      if (mounted) {
        setState(() {
          if (msg.contains('email') || msg.contains('Email')) {
            _emailError = msg;
          } else if (msg.contains('senha') || msg.contains('Senha')) {
            _passwordError = msg;
          } else {
            _emailError = msg;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _emailError = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _translateError(String message) {
    final m = message.toLowerCase();
    if (m.contains('user already registered') || m.contains('already registered')) {
      return 'Este email já está cadastrado.';
    }
    if (m.contains('invalid login credentials') || m.contains('invalid credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (m.contains('email not confirmed')) {
      return 'Email não confirmado. Verifique sua caixa de entrada.';
    }
    if (m.contains('password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (m.contains('unable to validate email address')) {
      return 'Email inválido.';
    }
    if (m.contains('signup is disabled')) {
      return 'Cadastro desativado no momento.';
    }
    if (m.contains('email rate limit exceeded') || m.contains('rate limit')) {
      return 'Muitas tentativas. Tente novamente em breve.';
    }
    if (m.contains('duplicate key') && m.contains('display_name')) {
      return 'Este nome de exibição já está em uso.';
    }
    if (m.contains('duplicate key') && m.contains('phone')) {
      return 'Este telefone já está cadastrado.';
    }
    return message;
  }

  void _invalidateProviders() {
    ref.invalidate(houseProvider);
    ref.invalidate(fridgeProvider);
    ref.invalidate(savedRecipesProvider);
    ref.invalidate(favoriteRecipesProvider);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translateError(message)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: neutralBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Hero section ─────────────────────────────────────────────
          Positioned(
            top: top + 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Ícone quadrado arredondado
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: brandPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bem-vindo ao\nCozinhei',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: neutralDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sua jornada gastronômica começa aqui',
                  style: TextStyle(
                    color: neutralMedium,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // ── Card (sem borda arredondada, fundo já é branco) ───────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.22,
            child: Container(
              decoration: const BoxDecoration(color: neutralBackground),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Tabs fixas ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Container(
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
                            onTap: () => setState(() {
                              _isSignUp = false;
                              _clearErrors();
                              _emailController.clear();
                              _passwordController.clear();
                              _displayNameController.clear();
                              _phoneController.clear();
                              _confirmPasswordController.clear();
                            }),
                          ),
                          _Tab(
                            label: 'Criar conta',
                            active: _isSignUp,
                            onTap: () => setState(() {
                              _isSignUp = true;
                              _clearErrors();
                              _emailController.clear();
                              _passwordController.clear();
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Campos scrolláveis ──────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          const _Label(text: 'Email'),
                          const SizedBox(height: 6),
                          _Input(
                            controller: _emailController,
                            hint: '',
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            hasError: _emailError != null,
                          ),
                          if (_emailError != null) _FieldError(_emailError!),
                          const SizedBox(height: 12),

                          // Campos extras de cadastro
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
                                        hint: '',
                                        hasError: _displayNameError != null,
                                      ),
                                      if (_displayNameError != null) _FieldError(_displayNameError!),
                                      const SizedBox(height: 12),
                                      const _Label(text: 'Telefone'),
                                      const SizedBox(height: 6),
                                      _Input(
                                        controller: _phoneController,
                                        hint: '',
                                        keyboardType: TextInputType.phone,
                                        hasError: _phoneError != null,
                                      ),
                                      if (_phoneError != null) _FieldError(_phoneError!),
                                      const SizedBox(height: 12),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Senha
                          const _Label(text: 'Senha'),
                          const SizedBox(height: 6),
                          _Input(
                            controller: _passwordController,
                            hint: '',
                            obscureText: _obscurePassword,
                            hasError: _passwordError != null,
                            autofillHints: _isSignUp
                                ? const [AutofillHints.newPassword]
                                : const [AutofillHints.password],
                            suffix: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: neutralMedium,
                              ),
                            ),
                          ),
                          if (_passwordError != null) _FieldError(_passwordError!),
                          const SizedBox(height: 12),

                          // Confirmar senha (somente cadastro)
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
                                        hint: '',
                                        obscureText: _obscureConfirmPassword,
                                        hasError: _confirmPasswordError != null,
                                        autofillHints: const [AutofillHints.newPassword],
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
                                      if (_confirmPasswordError != null)
                                        _FieldError(_confirmPasswordError!),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Botão fixo no rodapé ────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SubmitButton(
                          label: _isSignUp ? 'Criar conta' : 'Entrar',
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: Center(
                            child: Text(
                              'Continuar sem conta →',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: neutralMedium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Cozinhei',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF5F2EE),
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

class _FieldError extends StatelessWidget {
  final String message;
  const _FieldError(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.redAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool hasError;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? suffix;

  const _Input({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.hasError = false,
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
        border: Border.all(
          color: hasError ? Colors.redAccent : const Color(0xFFECE8E3),
          width: 1.5,
        ),
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D8), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: neutralDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        -1.57, 3.14, true, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        1.57, 1.57, true, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        3.14, 0.785, true, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        3.925, 0.785, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(center, r * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
