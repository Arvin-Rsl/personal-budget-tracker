import 'package:flutter/material.dart';
import 'package:personal_budget_app/app.dart';
import '../models/budget_models.dart';
import '../utils/date_format_option.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onConfirm;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  formatDate(transaction.date, MyApp.of(context).dateFormat),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '-\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.isConfirmed? Theme.of(context).colorScheme.error:Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 12),
              if (!transaction.isConfirmed)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  tooltip: 'Confirm',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onConfirm,
                ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'Delete',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
