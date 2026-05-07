import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Logo rotate
  late AnimationController _rotateCtrl;
  late Animation<double>    _rotateAnim;

  // Logo scale
  late AnimationController _scaleCtrl;
  late Animation<double>    _scaleAnim;

  // Text fade
  late AnimationController _textCtrl;
  late Animation<double>    _textFade;
  late Animation<Offset>    _textSlide;

  // Tagline fade
  late AnimationController _tagCtrl;
  late Animation<double>    _tagFade;

  // Exit (fade out whole screen)
  late AnimationController _exitCtrl;
  late Animation<double>    _exitAnim;

  @override
  void initState() {
    super.initState();

    // 1. Logo rotate in
    _rotateCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _rotateAnim = Tween<double>(begin: -0.15, end: 0.0).animate(
        CurvedAnimation(parent: _rotateCtrl, curve: Curves.easeOutCubic));

    // 2. Logo scale bounce
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0),  weight: 20),
    ]).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));

    // 3. App name slide up + fade
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // 4. Tagline fade
    _tagCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut);

    // 5. Exit fade out
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _exitAnim = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn);

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Logo muncul
    _scaleCtrl.forward();
    _rotateCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    // Teks nama app
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    // Tagline
    _tagCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Fade out
    _exitCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _scaleCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, child) => Opacity(
        opacity: 1.0 - _exitAnim.value,
        child: child,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF060E2B),
                Color(0xFF0B1F5C),
                Color(0xFF1540A8),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: Stack(children: [
            // Glow orbs dekoratif
            Positioned(top: -60, right: -40,
                child: _glow(220, const Color(0xFF2563EB).withOpacity(0.18))),
            Positioned(top: 100, left: -30,
                child: _glow(140, const Color(0xFF60A5FA).withOpacity(0.12))),
            Positioned(bottom: 80, right: 20,
                child: _glow(100, const Color(0xFF38BDF8).withOpacity(0.10))),
            Positioned(bottom: -40, left: -20,
                child: _glow(160, const Color(0xFF1540A8).withOpacity(0.20))),

            // Grid pattern
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                         MediaQuery.of(context).size.height),
              painter: _GridPainter(),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleCtrl, _rotateCtrl]),
                    builder: (_, __) => Transform.rotate(
                      angle: _rotateAnim.value,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: _buildLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: RichText(
                        text: const TextSpan(children: [
                          TextSpan(
                            text: "Cash",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: "ly",
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      "Kelola keuanganmu dengan cerdas",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading dots di bawah
            Positioned(
              bottom: 60,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _tagFade,
                child: Center(child: _LoadingDots()),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.50),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 52, height: 52,
          child: CustomPaint(painter: _CashlyLogoPainter()),
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

// ─── Cashly Logo (koin + tanda panah) ────────────────────────────────────────
class _CashlyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Lingkaran luar (koin)
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, strokePaint);

    // Simbol Rp di tengah
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Rp',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Loading dots animasi ─────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>>   _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true));
    _anims = List.generate(3, (i) => CurvedAnimation(
        parent: _ctrls[i], curve: Curves.easeInOut));

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _anims[i],
        builder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.30 + _anims[i].value * 0.70),
            shape: BoxShape.circle,
          ),
        ),
      )),
    );
  }
}

// ─── Grid painter ─────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x <= size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y <= size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_) => false;
}