import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/theme_provider.dart';
import '../services/api_constants.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  const ProfileScreen({super.key, required this.transactions});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  String  _name     = "User";
  String  _email    = "-";
  String? _photoUrl;
  String  _userId   = '';

  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 750));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _loadUser();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _loadUser() async {
    final raw = await LocalStorageService.getUser();
    if (raw != null && mounted) {
      final u = jsonDecode(raw);
      setState(() {
        _name     = u["name"]           ?? "User";
        _email    = u["email"]          ?? "-";
        _photoUrl = u["photo"];
        _userId   = u["id"]?.toString() ?? '';
      });
    }
  }

  String get _initials {
    final p = _name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p[0].isNotEmpty ? p[0][0].toUpperCase() : 'U';
  }

  int get _totalTx    => widget.transactions.length;
  int get _cats       => widget.transactions
      .where((t) => !t.isIncome).map((t) => t.category).toSet().length;
  int get _activeDays => widget.transactions
      .map((t) => DateTime(t.date.year, t.date.month, t.date.day)
          .millisecondsSinceEpoch)
      .toSet().length;

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final c  = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: c.bgCard,
        child: Padding(padding: const EdgeInsets.all(24), child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                  color: StaticColors.expenseLight, shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded,
                  color: StaticColors.expenseRed, size: 26),
            ),
            const SizedBox(height: 16),
            Text("Keluar dari akun?",
                style: TextStyle(color: c.textPrimary, fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "Kamu akan keluar dari Cashly.\nYakin ingin melanjutkan?",
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.cardBorder),
                  ),
                  child: Center(child: Text("Batal",
                      style: TextStyle(color: c.textSecondary,
                          fontWeight: FontWeight.w600))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: StaticColors.expenseRed,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: StaticColors.expenseRed.withValues(alpha: 0.35),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Center(child: Text("Keluar",
                      style: TextStyle(color: StaticColors.white,
                          fontWeight: FontWeight.w700))),
                ),
              )),
            ]),
          ],
        )),
      ),
    );

    if (ok == true) {
      await LocalStorageService.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final isDark = context.watch<ThemeProvider>().isDark;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: c.bgPage,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildStatsRow(context),
                const SizedBox(height: 24),

                _buildSection(context, "Akun", [
                  _Tile(
                    icon: Icons.person_outline_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconFg: StaticColors.headerBright,
                    label: "Edit Profil",
                    sub: "Nama, email, foto",
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      );
                      if (result == true) _loadUser();
                    },
                  ),
                  _Tile(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconFg: StaticColors.headerBright,
                    label: "Ubah Password",
                    sub: "Keamanan akun",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen()),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                _buildSection(context, "Preferensi", [
                  _Tile(
                    icon: Icons.notifications_none_rounded,
                    iconBg: StaticColors.incomeLight,
                    iconFg: StaticColors.incomeDeep,
                    label: "Notifikasi",
                    sub: "Pengingat & alert",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NotificationScreen(
                              transactions: widget.transactions)),
                    ),
                  ),
                  _Tile(
                    icon: Icons.attach_money_rounded,
                    iconBg: const Color(0xFFFFF7E6),
                    iconFg: const Color(0xFFB45309),
                    label: "Mata Uang",
                    sub: "IDR – Rupiah",
                    onTap: () {},
                  ),
                  _Tile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconBg: isDark
                        ? const Color(0xFF1E1B4B)
                        : const Color(0xFFFFFBEB),
                    iconFg: isDark
                        ? const Color(0xFF818CF8)
                        : const Color(0xFFD97706),
                    label: "Tampilan",
                    sub: isDark ? "Mode Gelap aktif" : "Mode Terang aktif",
                    trailing: _Switch(isDark: isDark),
                    onTap: () => context.read<ThemeProvider>().toggle(),
                  ),
                  _Tile(
                    icon: Icons.copy_all_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconFg: const Color(0xFF0284C7),
                    label: "Salin Ringkasan Keuangan",
                    sub: "Ekspor saldo & ringkasan ke clipboard",
                    onTap: () {
                      final inc = widget.transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
                      final exp = widget.transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
                      final bal = inc - exp;
                      final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                      final text = "📊 Ringkasan Finansial Cashly\n"
                          "Nama Pengguna: $_name\n"
                          "Sisa Saldo: ${f.format(bal)}\n"
                          "Total Pemasukan: ${f.format(inc)}\n"
                          "Total Pengeluaran: ${f.format(exp)}\n"
                          "Jumlah Transaksi: ${widget.transactions.length}\n"
                          "Dicatat di Cashly Finance App";
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Expanded(child: Text("Ringkasan keuangan berhasil disalin ke clipboard!")),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: StaticColors.incomeDeep,
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 16),

                _buildSection(context, "Lainnya", [
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    iconBg: const Color(0xFFF3E8FF),
                    iconFg: const Color(0xFF7C3AED),
                    label: "Tentang Cashly",
                    sub: "Versi 1.0.1",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                  _Tile(
                    icon: Icons.help_outline_rounded,
                    iconBg: const Color(0xFFF3E8FF),
                    iconFg: const Color(0xFF7C3AED),
                    label: "Bantuan & FAQ",
                    sub: "Pusat bantuan",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HelpScreen())),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildLogoutBtn(context),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Cashly v1.0.1  ·  Made by MDC Team",
                    style: TextStyle(
                        color: c.textMuted.withValues(alpha: 0.7), fontSize: 11),
                  ),
                ),
              ])),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            StaticColors.headerDeep,
            StaticColors.headerNavy,
            StaticColors.headerBlue,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(top: -40, right: -20,
            child: _glow(170, StaticColors.headerBright.withValues(alpha: 0.17))),
        Positioned(top: 60, right: 60,
            child: _glow(70, StaticColors.accentCyan.withValues(alpha: 0.10))),
        Positioned(bottom: 0, left: -20,
            child: _glow(110, StaticColors.glowBlue.withValues(alpha: 0.12))),

        SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(children: [
            // Top bar
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Profil",
                  style: TextStyle(
                    color: StaticColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  )),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.settings_outlined,
                    color: StaticColors.white, size: 18),
              ),
            ]),
            const SizedBox(height: 28),

            // Avatar — tap untuk edit, TANPA ikon pensil
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                );
                if (result == true) _loadUser();
              },
              child: Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      StaticColors.accentCyan.withValues(alpha: 0.80),
                      StaticColors.headerBright,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30), width: 2.5),
                  boxShadow: [BoxShadow(
                      color: StaticColors.headerBright.withValues(alpha: 0.40),
                      blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: ClipOval(
                  child: () {
                    final resolvedAvatar = ApiConstants.resolveAvatarUrl(_photoUrl);
                    return resolvedAvatar != null
                        ? Image.network(
                            resolvedAvatar,
                            fit: BoxFit.cover,
                            width: 84, height: 84,
                            errorBuilder: (_, __, ___) => _initialsWidget(),
                          )
                        : _initialsWidget();
                  }(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Nama
            Text(_name,
                style: const TextStyle(
                  color: StaticColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                )),
            const SizedBox(height: 4),

            // Email
            Text(_email,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
            const SizedBox(height: 12),

            // Member badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: StaticColors.incomeGreen,
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text("Member Aktif",
                    style: TextStyle(
                      color: StaticColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ]),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _initialsWidget() => Center(
    child: Text(_initials,
        style: const TextStyle(
          color: StaticColors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        )),
  );

  Widget _glow(double s, Color c) => Container(
      width: s, height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(BuildContext context) {
    return Row(children: [
      _statCard(context, "Transaksi",  "$_totalTx",
          Icons.receipt_long_outlined, const Color(0xFFEFF6FF), StaticColors.headerBright),
      const SizedBox(width: 10),
      _statCard(context, "Kategori",   "$_cats",
          Icons.label_outline_rounded, StaticColors.incomeLight, StaticColors.incomeDeep),
      const SizedBox(width: 10),
      _statCard(context, "Hari Aktif", "$_activeDays",
          Icons.local_fire_department_outlined,
          const Color(0xFFFFF7E6), const Color(0xFFB45309)),
    ]);
  }

  Widget _statCard(BuildContext context, String label, String value,
      IconData icon, Color iconBg, Color iconFg) {
    final c = context.colors;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(
            color: const Color(0xFF1540A8).withValues(alpha: 0.05),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 17, color: iconFg),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: c.textPrimary, fontSize: 20,
            fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: c.textMuted, fontSize: 10),
            textAlign: TextAlign.center),
      ]),
    ));
  }

  // ── Section ───────────────────────────────────────────────────────────────
  Widget _buildSection(BuildContext context, String title, List<_Tile> items) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Row(children: [
          Container(
            width: 3, height: 14,
            decoration: BoxDecoration(
              color: StaticColors.headerBright,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              )),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.cardBorder),
          boxShadow: [BoxShadow(
              color: const Color(0xFF1540A8).withValues(alpha: 0.06),
              blurRadius: 18, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final isLast = i == items.length - 1;
            final t = items[i];
            return Column(children: [
              InkWell(
                onTap: t.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                          color: t.iconBg,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(t.icon, size: 20, color: t.iconFg),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.label,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                        if (t.sub != null)
                          Text(t.sub!,
                              style: TextStyle(
                                  color: c.textMuted, fontSize: 11)),
                      ],
                    )),
                    t.trailing ?? Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: c.bgPage,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.chevron_right_rounded,
                          size: 16, color: c.textMuted),
                    ),
                  ]),
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1,
                    color: c.divider, indent: 68),
            ]);
          }),
        ),
      ),
    ]);
  }

  // ── Logout button ─────────────────────────────────────────────────────────
  Widget _buildLogoutBtn(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: _logout,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
          boxShadow: [BoxShadow(
              color: StaticColors.expenseRed.withValues(alpha: 0.08),
              blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(
                color: StaticColors.expenseLight, shape: BoxShape.circle),
            child: const Icon(Icons.logout_rounded,
                size: 16, color: StaticColors.expenseRed),
          ),
          const SizedBox(width: 10),
          const Text("Keluar dari Akun",
              style: TextStyle(
                color: StaticColors.expenseDeep,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
        ]),
      ),
    );
  }
}

// ─── Dark mode switch ─────────────────────────────────────────────────────────
class _Switch extends StatelessWidget {
  final bool isDark;
  const _Switch({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46, height: 26,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF6366F1)
              : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20, height: 20,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 12,
              color: isDark
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFD97706),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tile model ───────────────────────────────────────────────────────────────
class _Tile {
  final IconData     icon;
  final Color        iconBg;
  final Color        iconFg;
  final String       label;
  final String?      sub;
  final Widget?      trailing;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    this.sub,
    this.trailing,
    required this.onTap,
  });
}