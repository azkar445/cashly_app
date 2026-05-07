import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'transaction_screen.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';
import 'insight_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {

  int  _currentIdx = 0;
  bool _loading    = false;
  List<TransactionModel> transactions = [];

  late AnimationController _transCtrl;
  late Animation<double>   _fadeTrans;
  late Animation<Offset>   _slideTrans;

  // Total tinggi navbar + extra buffer agar konten tidak terpotong
  static const double _navBarVisualHeight = 110.0;

  @override
  void initState() {
    super.initState();
    _transCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fadeTrans  = CurvedAnimation(parent: _transCtrl, curve: Curves.easeOut);
    _slideTrans = Tween<Offset>(
            begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _transCtrl, curve: Curves.easeOutCubic));
    _transCtrl.forward();
    loadData();
  }

  @override
  void dispose() {
    _transCtrl.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (_loading) return;
    _loading = true;
    final data = await TransactionService.load();
    if (mounted) setState(() { transactions = data; _loading = false; });
  }

  Future<void> addTransaction(
      String title, double amount, bool isIncome, String category) async {
    await loadData();
  }

  Future<void> _onTabTap(int i) async {
    if (i == _currentIdx) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIdx = i);
    _transCtrl.reset();
    _transCtrl.forward();
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    final mq         = MediaQuery.of(context);
    final systemBottom = mq.padding.bottom;
    // Total ruang navbar: tinggi pill + padding atas + padding bawah + system inset
    final navBottom  = _navBarVisualHeight + systemBottom;

    final pages = [
      HomeScreen(transactions: transactions),
      TransactionScreen(transactions: transactions, addTx: addTransaction),
      InsightScreen(transactions: transactions),
      AiScreen(transactions: transactions),
      ProfileScreen(transactions: transactions),
    ];

    return Scaffold(
      extendBody: true,
      body: MediaQuery(
        // 🔥 Inject bottom padding sebesar tinggi navbar ke semua child screen
        // Sehingga ListView/CustomScrollView otomatis scroll sampai di atas navbar
        data: mq.copyWith(
          padding: mq.padding.copyWith(bottom: navBottom),
        ),
        child: FadeTransition(
          opacity: _fadeTrans,
          child: SlideTransition(
            position: _slideTrans,
            child: IndexedStack(
              index: _currentIdx,
              children: pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIdx,
        onTap: _onTabTap,
      ),
    );
  }
}

// ─── Floating Pill NavBar ─────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,         label: 'Home'),
    _NavItem(icon: Icons.receipt_long_outlined,  activeIcon: Icons.receipt_long_rounded, label: 'Transaksi'),
    _NavItem(icon: Icons.bar_chart_outlined,     activeIcon: Icons.bar_chart_rounded,    label: 'Insight'),
    _NavItem(icon: Icons.smart_toy_outlined,     activeIcon: Icons.smart_toy_rounded,    label: 'AI'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,       label: 'Profil'),
  ];

  static const int _centerIdx = 2;

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20,
          bottom: bottom + 6,
          top: 4,
        ),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: c.bgCard,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: StaticColors.headerBright.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final isCenter = i == _centerIdx;
              final isActive = currentIndex == i;

              if (isCenter) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: 58, height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              StaticColors.headerBlue,
                              StaticColors.headerBright,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: StaticColors.headerBright.withOpacity(
                                  isActive ? 0.55 : 0.35),
                              blurRadius: isActive ? 20 : 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          isActive ? _items[i].activeIcon : _items[i].icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: isActive ? 0.8 : 1.0,
                          end:   isActive ? 1.0 : 0.85,
                        ),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        builder: (_, scale, __) => Transform.scale(
                          scale: scale,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isActive ? _items[i].activeIcon : _items[i].icon,
                              key: ValueKey(isActive),
                              color: isActive
                                  ? StaticColors.headerBright
                                  : c.textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isActive
                              ? StaticColors.headerBright
                              : c.textMuted,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        child: Text(_items[i].label),
                      ),
                      // Dot indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(top: 3),
                        width:  isActive ? 16 : 0,
                        height: isActive ? 3  : 0,
                        decoration: BoxDecoration(
                          color: StaticColors.headerBright,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}