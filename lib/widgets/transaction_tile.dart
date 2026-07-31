import 'package:flutter/material.dart';
import '../models/budget_models.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
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
                  '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
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
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
              ),
              const SizedBox(width: 16),
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
