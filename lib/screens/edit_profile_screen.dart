import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _nameFocus = FocusNode();

  String  _email     = '';
  String  _userId    = '';
  String? _photoUrl;       // URL foto dari server
  File?   _localPhoto;     // Foto baru yang dipilih lokal
  bool    _isLoading = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final raw = await LocalStorageService.getUser();
    if (raw != null && mounted) {
      final u = jsonDecode(raw);
      setState(() {
        _userId   = u['id']?.toString()   ?? '';
        _nameCtrl.text = u['name']        ?? '';
        _email    = u['email']            ?? '';
        _photoUrl = u['photo'];
      });
    }
  }

  // ── Pilih foto ─────────────────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await _showPhotoSourceDialog();
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (picked != null && mounted) {
      setState(() => _localPhoto = File(picked.path));
    }
  }

  Future<ImageSource?> _showPhotoSourceDialog() {
    final c = context.colors;
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: c.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: c.cardBorder,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text("Pilih Foto Profil",
              style: TextStyle(color: c.textPrimary, fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _sourceBtn(Icons.camera_alt_rounded, StaticColors.headerBright,
              const Color(0xFFEFF6FF), "Ambil Foto", () => Navigator.pop(context, ImageSource.camera)),
          const SizedBox(height: 10),
          _sourceBtn(Icons.photo_library_rounded, const Color(0xFF7C3AED),
              const Color(0xFFF3E8FF), "Pilih dari Galeri", () => Navigator.pop(context, ImageSource.gallery)),
          const SizedBox(height: 10),
          if (_photoUrl != null || _localPhoto != null)
            _sourceBtn(Icons.delete_outline_rounded, StaticColors.expenseRed,
                StaticColors.expenseLight, "Hapus Foto", () {
              setState(() { _localPhoto = null; _photoUrl = null; });
              Navigator.pop(context);
            }),
        ]),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, Color fg, Color bg, String label, VoidCallback onTap) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: c.bgPage, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.cardBorder),
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          Container(width: 34, height: 34,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: fg, size: 18)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack("Nama tidak boleh kosong", isError: true);
      return;
    }
    if (_userId.isEmpty) {
      _snack("User tidak ditemukan", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("http://10.0.2.2/keuangan_api/config/update_profile.php");
      final req = http.MultipartRequest('POST', uri);

      req.fields['user_id'] = _userId;
      req.fields['name']    = name;

      if (_localPhoto != null) {
        req.files.add(await http.MultipartFile.fromPath('photo', _localPhoto!.path));
      }

      final streamed = await req.send();
      final res      = await http.Response.fromStream(streamed);
      final data     = jsonDecode(res.body);

      if (data['status'] == 'success') {
        // Simpan data user terbaru ke storage
        await LocalStorageService.saveUser(jsonEncode(data['user']));
        _snack("Profil berhasil diperbarui ✓");
        if (mounted) Navigator.pop(context, true);
      } else {
        _snack(data['msg'] ?? "Gagal memperbarui profil", isError: true);
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
          child: Column(children: [
            _buildAvatarSection(context),
            const SizedBox(height: 36),
            _buildForm(context),
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
        const Text("Edit Profil",
            style: TextStyle(color: StaticColors.white, fontSize: 18,
                fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      ]),
    )),
  );

  // ── Avatar ────────────────────────────────────────────────────────────────
  Widget _buildAvatarSection(BuildContext context) {
    final initials = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text.trim().split(' ').take(2).map((e) => e[0]).join().toUpperCase()
        : 'U';

    return Column(children: [
      Stack(children: [
        // Avatar
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [StaticColors.accentCyan.withOpacity(0.80), StaticColors.headerBright],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: StaticColors.headerBright.withOpacity(0.30), width: 3),
              boxShadow: [BoxShadow(
                  color: StaticColors.headerBright.withOpacity(0.30),
                  blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: ClipOval(
              child: _localPhoto != null
                  // Foto baru dipilih lokal
                  ? Image.file(_localPhoto!, fit: BoxFit.cover,
                      width: 100, height: 100)
                  : _photoUrl != null
                      // Foto dari server
                      ? Image.network(_photoUrl!, fit: BoxFit.cover,
                          width: 100, height: 100,
                          errorBuilder: (_, __, ___) => _initialsWidget(initials))
                      // Inisial
                      : _initialsWidget(initials),
            ),
          ),
        ),

        // Camera badge
        Positioned(
          bottom: 2, right: 2,
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: StaticColors.headerBright,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(
                    color: StaticColors.headerBright.withOpacity(0.40),
                    blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
      ]),

      const SizedBox(height: 12),
      GestureDetector(
        onTap: _pickPhoto,
        child: const Text("Ubah Foto Profil",
            style: TextStyle(
              color: StaticColors.headerBright,
              fontSize: 13, fontWeight: FontWeight.w600,
            )),
      ),
    ]);
  }

  Widget _initialsWidget(String initials) => Center(
    child: Text(initials,
        style: const TextStyle(color: Colors.white, fontSize: 34,
            fontWeight: FontWeight.w800, letterSpacing: -0.5)),
  );

  // ── Form ──────────────────────────────────────────────────────────────────
  Widget _buildForm(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Nama
      Text("Nama Lengkap",
          style: TextStyle(color: c.textSecondary, fontSize: 12,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: c.bgInput, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.inputBorder),
        ),
        child: TextField(
          controller: _nameCtrl,
          focusNode: _nameFocus,
          style: TextStyle(color: c.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Masukkan nama lengkap",
            hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.person_outline_rounded,
                color: StaticColors.headerBright, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}), // rebuild untuk update inisial
        ),
      ),
      const SizedBox(height: 20),

      // Email (read-only)
      Text("Email",
          style: TextStyle(color: c.textSecondary, fontSize: 12,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: c.bgPage, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.cardBorder),
        ),
        child: TextField(
          enabled: false,
          style: TextStyle(color: c.textMuted, fontSize: 15),
          controller: TextEditingController(text: _email),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined,
                color: c.textMuted, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            suffixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: c.bgCard, borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.cardBorder),
              ),
              child: Text("Tidak bisa diubah",
                  style: TextStyle(color: c.textMuted, fontSize: 9,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Save button 
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
              Icon(Icons.save_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Simpan Perubahan",
                  style: TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            ]),
        ),
      ),
    );
  }
}