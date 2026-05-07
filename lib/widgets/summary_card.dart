import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expense;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // 🟢 INCOME
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 8, bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.arrow_downward, color: Colors.green),
                const SizedBox(height: 6),
                const Text("Income"),
                const SizedBox(height: 4),
                Text(
                  "Rp $income",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🔴 EXPENSE
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 16, left: 8, bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.arrow_upward, color: Colors.red),
                const SizedBox(height: 6),
                const Text("Expense"),
                const SizedBox(height: 4),
                Text(
                  "Rp $expense",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}