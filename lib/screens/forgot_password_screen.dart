import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {

  // Step 1 — email
  final _emailCtrl  = TextEditingController();
  final _emailFocus = FocusNode();

  // Step 2 — password baru
  final _passCtrl   = TextEditingController();
  final _confCtrl   = TextEditingController();
  final _passFocus  = FocusNode();
  final _confFocus  = FocusNode();

  bool _showPass    = false;
  bool _showConf    = false;
  bool _isLoading   = false;

  // State
  int    _step      = 1;   // 1 = input email, 2 = input password baru, 3 = sukses
  int    _userId    = 0;
  String _userName  = '';

  // Animasi
  late AnimationController _entryCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); _confCtrl.dispose();
    _emailFocus.dispose(); _passFocus.dispose(); _confFocus.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: Cek email ─────────────────────────────────────────────────────
  Future<void> _checkEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack("Masukkan email kamu", isError: true); return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2/keuangan_api/config/forgot_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "check_email", "email": email}),
      );
      final data = jsonDecode(res.body);

      if (data['status'] == true) {
        setState(() {
          _userId   = data['user_id'];
          _userName = data['name'] ?? '';
          _step     = 2;
        });
        _entryCtrl.reset();
        _entryCtrl.forward();
      } else {
        _snack(data['message'] ?? "Email tidak ditemukan", isError: true);
      }
    } catch (_) {
      _snack("Gagal terhubung ke server", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 2: Reset password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    final pass = _passCtrl.text;
    final conf = _confCtrl.text;

    if (pass.isEmpty || conf.isEmpty) {
      _snack("Isi semua field", isError: true); return;
    }
    if (pass.length < 6) {
      _snack("Password minimal 6 karakter", isError: true); return;
    }
    if (pass != conf) {
      _snack("Password tidak cocok", isError: true); return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2/keuangan_api/config/forgot_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action"      : "reset_password",
          "user_id"     : _userId,
          "new_password": pass,
        }),
      );
      final data = jsonDecode(res.body);

      if (data['status'] == true) {
        setState(() => _step = 3);
        _entryCtrl.reset();
        _entryCtrl.forward();
      } else {
        _snack(data['message'] ?? "Gagal mereset password", isError: true);
      }
    } catch (_) {
      _snack("Gagal terhubung ke server", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Password strength ─────────────────────────────────────────────────────
  double get _strength {
    final p = _passCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 6)  s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9!@#$%^&*]'))) s += 0.25;
    return s;
  }

  Color get _strengthColor => _strength <= 0.25
      ? StaticColors.expenseRed
      : _strength <= 0.50
          ? const Color(0xFFF59E0B)
          : _strength <= 0.75
              ? const Color(0xFF3B82F6)
              : StaticColors.incomeGreen;

  String get _strengthLabel => _strength <= 0.25 ? "Lemah"
      : _strength <= 0.50 ? "Cukup"
      : _strength <= 0.75 ? "Kuat"
      : "Sangat Kuat";

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? StaticColors.expenseDeep : StaticColors.incomeDeep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPage,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _step == 1 ? _buildStep1(context)
                  : _step == 2 ? _buildStep2(context)
                  : _buildStep3(context),
            ),
          ),
        )),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [StaticColors.headerDeep, StaticColors.headerNavy, StaticColors.headerBlue],
        stops: [0.0, 0.45, 1.0],
      ),
    ),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        GestureDetector(
          onTap: () {
            if (_step > 1 && _step < 3) {
              setState(() { _step = _step - 1; });
              _entryCtrl.reset(); _entryCtrl.forward();
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: StaticColors.white, size: 16),
          ),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Lupa Password",
              style: TextStyle(color: StaticColors.white, fontSize: 18,
                  fontWeight: FontWeight.w700)),
          Text(
            _step == 1 ? "Masukkan email akunmu"
                : _step == 2 ? "Buat password baru"
                : "Password berhasil direset",
            style: const TextStyle(color: StaticColors.white70, fontSize: 11),
          ),
        ]),

        const Spacer(),

        // Step indicator
        if (_step < 3)
          Row(children: List.generate(2, (i) => Container(
            margin: const EdgeInsets.only(left: 6),
            width: i + 1 == _step ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i + 1 <= _step
                  ? Colors.white
                  : Colors.white.withOpacity(0.30),
              borderRadius: BorderRadius.circular(99),
            ),
          ))),
      ]),
    )),
  );

  // ── Step 1: Email ─────────────────────────────────────────────────────────
  Widget _buildStep1(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Ilustrasi icon
      Center(child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          shape: BoxShape.circle,
          border: Border.all(color: StaticColors.headerBright.withOpacity(0.20)),
        ),
        child: const Icon(Icons.mail_outline_rounded,
            size: 36, color: StaticColors.headerBright),
      )),
      const SizedBox(height: 24),

      Center(child: Text("Verifikasi Email",
          style: TextStyle(color: c.textPrimary, fontSize: 20,
              fontWeight: FontWeight.w800))),
      const SizedBox(height: 8),
      Center(child: Text(
        "Masukkan email yang terdaftar di Cashly.\nKami akan verifikasi akunmu.",
        textAlign: TextAlign.center,
        style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.5),
      )),
      const SizedBox(height: 32),

      Text("Email", style: TextStyle(color: c.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: c.bgInput, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.inputBorder),
        ),
        child: TextField(
          controller: _emailCtrl, focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _checkEmail(),
          style: TextStyle(color: c.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: "nama@email.com",
            hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.email_outlined,
                color: StaticColors.headerBright, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ),
      const SizedBox(height: 32),

      _buildBtn(context, "Verifikasi Email", Icons.search_rounded, _checkEmail),
    ]);
  }

  // ── Step 2: Password baru ─────────────────────────────────────────────────
  Widget _buildStep2(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Ilustrasi
      Center(child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: StaticColors.incomeLight,
          shape: BoxShape.circle,
          border: Border.all(color: StaticColors.incomeGreen.withOpacity(0.30)),
        ),
        child: const Icon(Icons.lock_reset_rounded,
            size: 36, color: StaticColors.incomeDeep),
      )),
      const SizedBox(height: 24),

      Center(child: Text("Halo, $_userName! 👋",
          style: TextStyle(color: c.textPrimary, fontSize: 20,
              fontWeight: FontWeight.w800))),
      const SizedBox(height: 8),
      Center(child: Text(
        "Email terverifikasi. Sekarang buat\npassword baru untuk akunmu.",
        textAlign: TextAlign.center,
        style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.5),
      )),
      const SizedBox(height: 32),

      // Password baru
      Text("Password Baru", style: TextStyle(color: c.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: c.bgInput, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.inputBorder),
        ),
        child: TextField(
          controller: _passCtrl, focusNode: _passFocus,
          obscureText: !_showPass,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_confFocus),
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: c.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Minimal 6 karakter",
            hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: StaticColors.headerBright, size: 20),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _showPass = !_showPass),
              child: Padding(padding: const EdgeInsets.only(right: 12),
                child: Icon(_showPass ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                    color: c.textMuted, size: 20)),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ),

      // Strength bar
      if (_passCtrl.text.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _strength, minHeight: 5,
              color: _strengthColor,
              backgroundColor: _strengthColor.withOpacity(0.15),
            ),
          )),
          const SizedBox(width: 10),
          Text(_strengthLabel,
              style: TextStyle(color: _strengthColor, fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ],
      const SizedBox(height: 20),

      // Konfirmasi
      Text("Konfirmasi Password", style: TextStyle(color: c.textSecondary,
          fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: c.bgInput, borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _confCtrl.text.isNotEmpty
                ? (_passCtrl.text == _confCtrl.text
                    ? StaticColors.incomeGreen
                    : StaticColors.expenseRed)
                : c.inputBorder,
          ),
        ),
        child: TextField(
          controller: _confCtrl, focusNode: _confFocus,
          obscureText: !_showConf,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _resetPassword(),
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: c.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Ulangi password baru",
            hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: StaticColors.headerBright, size: 20),
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_confCtrl.text.isNotEmpty)
                Padding(padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    _passCtrl.text == _confCtrl.text
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _passCtrl.text == _confCtrl.text
                        ? StaticColors.incomeGreen
                        : StaticColors.expenseRed,
                    size: 18,
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _showConf = !_showConf),
                child: Padding(padding: const EdgeInsets.only(right: 12),
                  child: Icon(_showConf ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                      color: c.textMuted, size: 20)),
              ),
            ]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ),
      const SizedBox(height: 32),

      _buildBtn(context, "Reset Password", Icons.lock_reset_rounded,
          _resetPassword),
    ]);
  }

  // ── Step 3: Sukses ────────────────────────────────────────────────────────
  Widget _buildStep3(BuildContext context) {
    final c = context.colors;
    return Column(children: [
      const SizedBox(height: 20),
      Center(child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: StaticColors.incomeLight,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
              color: StaticColors.incomeGreen.withOpacity(0.25),
              blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: const Icon(Icons.check_circle_rounded,
            size: 50, color: StaticColors.incomeGreen),
      )),
      const SizedBox(height: 28),

      Text("Password Berhasil Direset! 🎉",
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textPrimary, fontSize: 20,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Text(
        "Password akunmu sudah diperbarui.\nSilakan login dengan password baru.",
        textAlign: TextAlign.center,
        style: TextStyle(color: c.textMuted, fontSize: 14, height: 1.5),
      ),
      const SizedBox(height: 40),

      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 54, width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [StaticColors.headerBlue, StaticColors.headerBright],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(
                color: StaticColors.headerBright.withOpacity(0.38),
                blurRadius: 18, offset: const Offset(0, 7))],
          ),
          child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.login_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Kembali ke Login",
                style: TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w700, letterSpacing: 0.4)),
          ])),
        ),
      ),
    ]);
  }

  // ── Shared button ─────────────────────────────────────────────────────────
  Widget _buildBtn(BuildContext context, String label, IconData icon,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54, width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [StaticColors.headerBlue, StaticColors.headerBright],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(
              color: StaticColors.headerBright.withOpacity(0.38),
              blurRadius: 18, offset: const Offset(0, 7))],
        ),
        child: Center(child: _isLoading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            ]),
        ),
      ),
    );
  }
}