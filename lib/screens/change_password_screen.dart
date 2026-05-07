import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldCtrl  = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();

  final _oldFocus  = FocusNode();
  final _newFocus  = FocusNode();
  final _confFocus = FocusNode();

  bool _showOld  = false;
  bool _showNew  = false;
  bool _showConf = false;
  bool _isLoading= false;

  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _oldCtrl.dispose(); _newCtrl.dispose(); _confCtrl.dispose();
    _oldFocus.dispose(); _newFocus.dispose(); _confFocus.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final raw = await LocalStorageService.getUser();
    if (raw != null) {
      final u = jsonDecode(raw);
      setState(() => _userId = u['id']?.toString() ?? '');
    }
  }

  // ── Password strength ─────────────────────────────────────────────────────
  double get _strength {
    final p = _newCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 6)  s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9!@#$%^&*]'))) s += 0.25;
    return s;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return StaticColors.expenseRed;
    if (_strength <= 0.50) return const Color(0xFFF59E0B);
    if (_strength <= 0.75) return const Color(0xFF3B82F6);
    return StaticColors.incomeGreen;
  }

  String get _strengthLabel {
    if (_strength <= 0.25) return "Lemah";
    if (_strength <= 0.50) return "Cukup";
    if (_strength <= 0.75) return "Kuat";
    return "Sangat Kuat";
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final oldPass  = _oldCtrl.text;
    final newPass  = _newCtrl.text;
    final confPass = _confCtrl.text;

    if (oldPass.isEmpty || newPass.isEmpty || confPass.isEmpty) {
      _snack("Semua field wajib diisi", isError: true); return;
    }
    if (newPass.length < 6) {
      _snack("Password baru minimal 6 karakter", isError: true); return;
    }
    if (newPass != confPass) {
      _snack("Konfirmasi password tidak cocok", isError: true); return;
    }
    if (oldPass == newPass) {
      _snack("Password baru harus berbeda", isError: true); return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2/keuangan_api/config/update_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id"     : int.tryParse(_userId) ?? 0,
          "old_password": oldPass,
          "new_password": newPass,
        }),
      );

      final data = jsonDecode(res.body);

      if (data['status'] == 'success') {
        _snack("Password berhasil diubah ✓");
        if (mounted) Navigator.pop(context, true);
      } else {
        _snack(data['msg'] ?? "Gagal mengubah password", isError: true);
      }
    } catch (e) {
      _snack("Gagal terhubung ke server", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPage,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Info card
            _buildInfoCard(context),
            const SizedBox(height: 28),

            // Old password
            _buildPasswordField(
              context,
              label: "Password Lama",
              hint: "Masukkan password saat ini",
              controller: _oldCtrl,
              focus: _oldFocus,
              nextFocus: _newFocus,
              show: _showOld,
              onToggle: () => setState(() => _showOld = !_showOld),
            ),
            const SizedBox(height: 20),

            // New password
            _buildPasswordField(
              context,
              label: "Password Baru",
              hint: "Minimal 6 karakter",
              controller: _newCtrl,
              focus: _newFocus,
              nextFocus: _confFocus,
              show: _showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
              showStrength: true,
            ),
            const SizedBox(height: 20),

            // Confirm password
            _buildPasswordField(
              context,
              label: "Konfirmasi Password Baru",
              hint: "Ulangi password baru",
              controller: _confCtrl,
              focus: _confFocus,
              show: _showConf,
              onToggle: () => setState(() => _showConf = !_showConf),
              isMatch: _confCtrl.text.isNotEmpty && _newCtrl.text == _confCtrl.text,
            ),
            const SizedBox(height: 32),

            _buildSaveBtn(context),
          ]),
        )),
      ]),
    );
  }

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
          onTap: () => Navigator.pop(context),
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
        const Text("Ubah Password",
            style: TextStyle(color: StaticColors.white, fontSize: 18,
                fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      ]),
    )),
  );

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StaticColors.headerBright.withOpacity(0.20)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: StaticColors.headerBright.withOpacity(0.12),
              shape: BoxShape.circle),
          child: const Icon(Icons.shield_outlined,
              color: StaticColors.headerBright, size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Tips Password Aman",
              style: TextStyle(color: StaticColors.headerBright, fontSize: 12,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 3),
          Text("Gunakan kombinasi huruf besar, angka, dan simbol untuk keamanan maksimal.",
              style: TextStyle(color: StaticColors.headerBlue, fontSize: 11, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focus,
    FocusNode? nextFocus,
    required bool show,
    required VoidCallback onToggle,
    bool showStrength = false,
    bool? isMatch,
  }) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: c.bgInput, borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMatch == true
                ? StaticColors.incomeGreen
                : isMatch == false
                    ? StaticColors.expenseRed
                    : c.inputBorder,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focus,
          obscureText: !show,
          textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              focus.unfocus();
            }
          },
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: c.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: StaticColors.headerBright, size: 20),
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isMatch != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isMatch ? StaticColors.incomeGreen : StaticColors.expenseRed,
                    size: 18,
                  ),
                ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: c.textMuted, size: 20),
                ),
              ),
            ]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),

      // Strength indicator (hanya untuk password baru)
      if (showStrength && _newCtrl.text.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _strength, minHeight: 5,
              color: _strengthColor,
              backgroundColor: c.cardBorder,
            ),
          )),
          const SizedBox(width: 10),
          Text(_strengthLabel,
              style: TextStyle(color: _strengthColor, fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ],
    ]);
  }

  Widget _buildSaveBtn(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
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
          : const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_reset_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Ubah Password",
                  style: TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            ]),
        ),
      ),
    );
  }
}