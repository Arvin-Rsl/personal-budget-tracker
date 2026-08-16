import 'package:flutter/material.dart';
import '../models/budget_models.dart';

class OverduePredictionsBanner extends StatelessWidget {
  final List<Transaction> overdueTransactions;
  final ValueChanged<String> onConfirm;
  final ValueChanged<Transaction> onReschedule;
  final ValueChanged<String> onDelete;

  const OverduePredictionsBanner({
    super.key,
    required this.overdueTransactions,
    required this.onConfirm,
    required this.onReschedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_busy),
                const SizedBox(width: 8),
                Text(
                  '${overdueTransactions.length} predicted expense${overdueTransactions.length == 1 ? ' needs' : 's need'} attention',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...overdueTransactions.map((transaction) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${transaction.description} — \$${transaction.amount.toStringAsFixed(2)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      tooltip: 'Confirm',
                      onPressed: () => onConfirm(transaction.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit/Reschedule',
                      onPressed: () => onReschedule(transaction),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: 'Delete',
                      onPressed: () => onDelete(transaction.id),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
