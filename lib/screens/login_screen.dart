import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
class _C {
  static const Color headerDeep   = Color(0xFF060E2B);
  static const Color headerNavy   = Color(0xFF0B1F5C);
  static const Color headerBlue   = Color(0xFF1540A8);
  static const Color headerBright = Color(0xFF2563EB);
  static const Color glowBlue     = Color(0xFF60A5FA);
  static const Color accentCyan   = Color(0xFF38BDF8);

  static const Color bgPage       = Color(0xFFF1F5FE);
  static const Color bgCard       = Colors.white;

  static const Color incomeGreen  = Color(0xFF22C55E);
  static const Color expenseDeep  = Color(0xFFDC2626);

  static const Color textPrimary  = Color(0xFF0F172A);
  static const Color textSecondary= Color(0xFF475569);
  static const Color textMuted    = Color(0xFF94A3B8);
  static const Color inputBorder  = Color(0xFFE2E8F0);
  static const Color white        = Colors.white;
  static const Color white70      = Color(0xB3FFFFFF);
}

// ═══════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();
  bool  _obscure    = true;
  bool  _isLoading  = false;

  late AnimationController _floatCtrl;
  late AnimationController _entryCtrl;
  late Animation<double>   _floatAnim;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _emailFocus.dispose(); _passFocus.dispose();
    _floatCtrl.dispose(); _entryCtrl.dispose();
    super.dispose();
  }

  // ── LOGIN LOGIC ───────────────────────────────────────────────────────────
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _snack("Isi email dan password terlebih dahulu", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(email, pass);

      if (result["status"] == true) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (_) => false,
          );
        }
      } else {
        _snack(result["message"] ?? "Email atau password salah", isError: true);
      }
    } catch (e) {
      _snack("Gagal terhubung ke server", isError: true);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _C.expenseDeep : _C.incomeGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgPage,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_C.headerDeep, _C.headerNavy, _C.headerBlue],
                stops: [0.0, 0.40, 1.0],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, __) {
              final t = _floatAnim.value;
              return Stack(children: [
                _orb(top: -60 + t * 30, left: -50,  size: 220,
                    color: _C.headerBright.withOpacity(0.18)),
                _orb(top: 80  - t * 20, right: -40, size: 170,
                    color: _C.accentCyan.withOpacity(0.10)),
                _orb(top: 200 + t * 25, left: 40,   size: 100,
                    color: _C.glowBlue.withOpacity(0.13)),
              ]);
            },
          ),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                       MediaQuery.of(context).size.height * 0.55),
            painter: _GridPainter(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _buildBrand(),
                  const SizedBox(height: 48),
                  _buildCard(),
                  const SizedBox(height: 24),
                  _buildSignUp(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb({double? top, double? left, double? right,
               required double size, required Color color}) =>
      Positioned(
        top: top, left: left, right: right,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      );

  Widget _buildBrand() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _C.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _C.white.withOpacity(0.20), width: 1.5),
                boxShadow: [BoxShadow(
                    color: _C.headerBright.withOpacity(0.35),
                    blurRadius: 28, offset: const Offset(0, 8))],
              ),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.monetization_on_rounded,
                    color: _C.white, size: 38),
                Positioned(top: 10, right: 10,
                  child: Container(width: 8, height: 8,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF38BDF8))),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            RichText(
              text: const TextSpan(children: [
                TextSpan(text: "Cash",
                    style: TextStyle(color: _C.white, fontSize: 38,
                        fontWeight: FontWeight.w900, letterSpacing: -1.0, height: 1)),
                TextSpan(text: "ly",
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 38,
                        fontWeight: FontWeight.w900, letterSpacing: -1.0, height: 1)),
              ]),
            ),
            const SizedBox(height: 8),
            Text("Kelola keuanganmu dengan cerdas",
                style: TextStyle(color: _C.white.withOpacity(0.60),
                    fontSize: 13, letterSpacing: 0.3)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _pill(Icons.auto_graph_rounded, "Tracking"),
              const SizedBox(width: 8),
              _pill(Icons.insights_rounded, "Insight AI"),
              const SizedBox(width: 8),
              _pill(Icons.savings_rounded, "Tabungan"),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _C.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: _C.white.withOpacity(0.15)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: _C.accentCyan),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(
          color: _C.white70, fontSize: 11, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _C.bgCard,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: _C.headerBlue.withOpacity(0.18),
                    blurRadius: 40, offset: const Offset(0, 16)),
                BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Selamat datang",
                    style: TextStyle(color: _C.textPrimary, fontSize: 22,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                const SizedBox(height: 4),
                const Text("Masuk untuk melanjutkan",
                    style: TextStyle(color: _C.textMuted, fontSize: 13)),
                const SizedBox(height: 28),
                _inputField(label: "Email", hint: "nama@email.com",
                    icon: Icons.email_outlined, controller: _emailCtrl,
                    focus: _emailFocus, nextFocus: _passFocus,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _inputField(label: "Password", hint: "Masukkan password",
                    icon: Icons.lock_outline_rounded, controller: _passCtrl,
                    focus: _passFocus, obscure: _obscure,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                          color: _C.textMuted, size: 20),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 28),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen())),
                      child: const Text("Lupa password?",
                          style: TextStyle(color: _C.headerBright,
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                _buildLoginBtn(),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("atau",
                        style: TextStyle(color: _C.textMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ]),
                const SizedBox(height: 20),
                _googleBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focus,
    FocusNode? nextFocus,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _C.textSecondary,
            fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.inputBorder),
          ),
          child: TextField(
            controller: controller,
            focusNode: focus,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction:
                nextFocus != null ? TextInputAction.next : TextInputAction.done,
            onSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              } else {
                _login(); 
              }
            },
            style: const TextStyle(color: _C.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _C.textMuted, fontSize: 14),
              prefixIcon: Icon(icon, color: _C.textMuted, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _login,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.headerBlue, _C.headerBright],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(
              color: _C.headerBright.withOpacity(0.38),
              blurRadius: 18, offset: const Offset(0, 7))],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Masuk", style: TextStyle(color: Colors.white,
                      fontSize: 15, fontWeight: FontWeight.w700,
                      letterSpacing: 0.4)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ]),
        ),
      ),
    );
  }

  Widget _googleBtn() => Container(
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.inputBorder, width: 1.5),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 22, height: 22,
          child: CustomPaint(painter: _GoogleGPainter())),
      const SizedBox(width: 10),
      const Text("Masuk dengan Google",
          style: TextStyle(color: _C.textPrimary, fontSize: 14,
              fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _buildSignUp() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RegisterScreen())),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Belum punya akun? ",
              style: TextStyle(color: _C.white70, fontSize: 13)),
          Text("Daftar sekarang",
              style: TextStyle(color: _C.accentCyan, fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ─── Painters ────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.04)..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x <= size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y <= size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final segs = [
      (0.0, math.pi * 0.5, const Color(0xFF4285F4)),
      (math.pi * 0.5, math.pi, const Color(0xFF34A853)),
      (math.pi, math.pi * 1.5, const Color(0xFFFBBC05)),
      (math.pi * 1.5, math.pi * 2.0, const Color(0xFFEA4335)),
    ];
    for (final s in segs) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - 1.5),
        s.$1 - math.pi / 2, s.$2 - s.$1, false,
        Paint()..color = s.$3..style = PaintingStyle.stroke
               ..strokeWidth = 3..strokeCap = StrokeCap.round,
      );
    }
  }
  @override bool shouldRepaint(_) => false;
}