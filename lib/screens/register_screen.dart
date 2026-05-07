import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'main_screen.dart';

// ─── Color Palette (konsisten dengan seluruh app) ────────────────────────────
class _C {
  static const Color headerDeep    = Color(0xFF060E2B);
  static const Color headerNavy    = Color(0xFF0B1F5C);
  static const Color headerBlue    = Color(0xFF1540A8);
  static const Color headerBright  = Color(0xFF2563EB);
  static const Color glowBlue      = Color(0xFF60A5FA);
  static const Color accentCyan    = Color(0xFF38BDF8);

  static const Color bgPage        = Color(0xFFF1F5FE);
  static const Color bgCard        = Colors.white;

  static const Color incomeGreen   = Color(0xFF22C55E);
  static const Color expenseDeep   = Color(0xFFDC2626);

  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted     = Color(0xFF94A3B8);
  static const Color inputBorder   = Color(0xFFE2E8F0);
  static const Color white         = Colors.white;
  static const Color white70       = Color(0xB3FFFFFF);
}

// ═══════════════════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {

  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();

  final _nameFocus  = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();
  final _confFocus  = FocusNode();

  bool _obscurePass = true;
  bool _obscureConf = true;
  bool _isLoading   = false;

  late AnimationController _floatCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _floatAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    _nameFocus.dispose(); _emailFocus.dispose();
    _passFocus.dispose(); _confFocus.dispose();
    _floatCtrl.dispose(); _entryCtrl.dispose();
    super.dispose();
  }

  // ── Logic ─────────────────────────────────────────────────────────────────
  Future<void> _register() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final conf  = _confCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || conf.isEmpty) {
      _snack("Semua field wajib diisi", isError: true); return;
    }
    if (pass != conf) {
      _snack("Password tidak cocok", isError: true); return;
    }
    if (pass.length < 6) {
      _snack("Password minimal 6 karakter", isError: true); return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(name, email, pass);

      if (result["status"] == true) {
        final loginResult = await AuthService.login(email, pass);

        if (loginResult["status"] == true) {
          await LocalStorageService.saveUser(loginResult["user"]);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        } else {
          _snack(loginResult["message"] ?? "Login gagal", isError: true);
        }
      } else {
        _snack(result["message"] ?? "Registrasi gagal", isError: true);
      }
    } catch (_) {
      _snack("Terjadi kesalahan koneksi", isError: true);
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
          // Background gradient
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

          // Floating orbs
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, __) {
              final t = _floatAnim.value;
              return Stack(children: [
                _orb(top: -50 + t * 28, right: -40, size: 200,
                    color: _C.headerBright.withOpacity(0.17)),
                _orb(top: 100 - t * 18, left: -30, size: 150,
                    color: _C.accentCyan.withOpacity(0.10)),
                _orb(top: 220 + t * 22, right: 50, size: 90,
                    color: _C.glowBlue.withOpacity(0.12)),
              ]);
            },
          ),

          // Grid pattern
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                       MediaQuery.of(context).size.height * 0.50),
            painter: _GridPainter(),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  _buildBrand(),
                  const SizedBox(height: 32),
                  _buildCard(),
                  const SizedBox(height: 24),
                  _buildLoginRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb({double? top, double? left, double? right,
               required double size, required Color color}) {
    return Positioned(
      top: top, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  // ── Brand ─────────────────────────────────────────────────────────────────
  Widget _buildBrand() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          children: [
            // Logo
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _C.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _C.white.withOpacity(0.20), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _C.headerBright.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: _C.white, size: 32),
                  Positioned(
                    top: 9, right: 9,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: "Cash",
                  style: TextStyle(
                    color: _C.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: "ly",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 6),
            Text(
              "Buat akun baru, gratis!",
              style: TextStyle(
                  color: _C.white.withOpacity(0.60),
                  fontSize: 13,
                  letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────
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
                BoxShadow(
                  color: _C.headerBlue.withOpacity(0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Daftar sekarang ✨",
                    style: TextStyle(
                      color: _C.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 4),
                const Text("Isi data di bawah untuk membuat akun",
                    style: TextStyle(color: _C.textMuted, fontSize: 13)),
                const SizedBox(height: 24),

                // Nama
                _inputField(
                  label: "Nama Lengkap",
                  hint: "Masukkan nama kamu",
                  icon: Icons.person_outline_rounded,
                  controller: _nameCtrl,
                  focus: _nameFocus,
                  nextFocus: _emailFocus,
                ),
                const SizedBox(height: 14),

                // Email
                _inputField(
                  label: "Email",
                  hint: "nama@email.com",
                  icon: Icons.email_outlined,
                  controller: _emailCtrl,
                  focus: _emailFocus,
                  nextFocus: _passFocus,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // Password
                _inputField(
                  label: "Password",
                  hint: "Minimal 6 karakter",
                  icon: Icons.lock_outline_rounded,
                  controller: _passCtrl,
                  focus: _passFocus,
                  nextFocus: _confFocus,
                  obscure: _obscurePass,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePass = !_obscurePass),
                    child: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _C.textMuted, size: 20),
                  ),
                ),
                const SizedBox(height: 14),

                // Konfirmasi password
                _inputField(
                  label: "Konfirmasi Password",
                  hint: "Ulangi password",
                  icon: Icons.lock_outline_rounded,
                  controller: _confCtrl,
                  focus: _confFocus,
                  obscure: _obscureConf,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureConf = !_obscureConf),
                    child: Icon(
                      _obscureConf
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _C.textMuted, size: 20),
                  ),
                ),
                const SizedBox(height: 28),

                // Terms note
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: _C.headerBlue.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: _C.headerBright.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 12, color: _C.headerBright),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              color: _C.textMuted,
                              fontSize: 11,
                              height: 1.5),
                          children: [
                            TextSpan(text: "Dengan mendaftar, kamu menyetujui "),
                            TextSpan(
                              text: "Syarat & Ketentuan",
                              style: TextStyle(
                                  color: _C.headerBright,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: " dan "),
                            TextSpan(
                              text: "Kebijakan Privasi",
                              style: TextStyle(
                                  color: _C.headerBright,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: " Cashly."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register button
                _buildRegisterBtn(),
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
        Text(label,
            style: const TextStyle(
              color: _C.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            )),
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
            textInputAction: nextFocus != null
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              } else {
                focus.unfocus();
              }
            },
            style: const TextStyle(
                color: _C.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: _C.textMuted, fontSize: 14),
              prefixIcon: Icon(icon, color: _C.textMuted, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _register,
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
          boxShadow: [
            BoxShadow(
              color: _C.headerBright.withOpacity(0.38),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Buat Akun",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        )),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Login row ─────────────────────────────────────────────────────────────
  Widget _buildLoginRow() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sudah punya akun? ",
                style: TextStyle(color: _C.white70, fontSize: 13)),
            Text("Masuk di sini",
                style: TextStyle(
                  color: _C.accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Painters ────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override bool shouldRepaint(_) => false;
}