import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback? onTap;

  const TransactionItem(this.tx, {super.key, this.onTap});

  String _rp(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  String _dateStr(DateTime d) => DateFormat('d MMM yyyy', 'id_ID').format(d);

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'hiburan':
        return Icons.movie_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'kesehatan':
        return Icons.favorite_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      case 'rumah':
        return Icons.home_rounded;
      default:
        return tx.isIncome ? Icons.arrow_downward_rounded : Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isInc = tx.isIncome;
    final sign = isInc ? '+' : '-';
    final amountColor = isInc ? StaticColors.incomeGreen : StaticColors.expenseRed;
    final bgIconColor = isInc ? StaticColors.incomeLight : StaticColors.expenseLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgIconColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _iconForCategory(tx.category),
                    color: amountColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.bgPage,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tx.category,
                              style: TextStyle(color: c.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _dateStr(tx.date),
                            style: TextStyle(color: c.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "$sign ${_rp(tx.amount)}",
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}