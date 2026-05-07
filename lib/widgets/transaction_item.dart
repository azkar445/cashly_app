import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel tx;

  const TransactionItem(this.tx, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tx.isIncome ? Colors.green : Colors.red,
          child: Icon(
            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),

        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          "${tx.date.day}/${tx.date.month}/${tx.date.year}",
          style: TextStyle(color: Colors.grey.shade600),
        ),

        trailing: Text(
          "Rp ${tx.amount}",
          style: TextStyle(
            color: tx.isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}