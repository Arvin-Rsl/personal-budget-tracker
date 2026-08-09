import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import 'transaction_tile.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final double allocatedBudget;
  final double spentAmount;
  final List<Transaction> transactions;
  final bool isExpanded;
  final bool isMonthClosed;
  final VoidCallback onTap;
  final ValueChanged<Transaction> onEditTransaction;
  final ValueChanged<String> onDeleteTransaction;

  const CategoryCard({
    super.key,
    required this.category,
    required this.allocatedBudget,
    required this.spentAmount,
    required this.transactions,
    required this.isExpanded,
    required this.isMonthClosed,
    required this.onTap,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
  });

  Color _getProgressColor(BuildContext context, double percent) {
    if (percent >= 1.0) {
      return Colors.redAccent.shade700;
    } else if (percent >= 0.90) {
      return Colors.red.shade400;
    } else if (percent >= 0.70) {
      return Colors.orangeAccent.shade400;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double budget = allocatedBudget;
    final double percentSpent = budget > 0 ? (spentAmount / budget) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${spentAmount.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentSpent.clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                color: isMonthClosed
                    ? Theme.of(context).colorScheme.secondary
                    : _getProgressColor(context, percentSpent),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        'No transactions recorded here yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return TransactionTile(
                        transaction: transaction,
                        onEdit: () => onEditTransaction(transaction),
                        onDelete: () => onDeleteTransaction(transaction.id),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
