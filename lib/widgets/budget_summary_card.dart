import 'package:flutter/material.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double remaining;
  final double totalBudget;
  final double totalSpent;
  final double totalPredicted;

  const BudgetSummaryCard({
    super.key,
    required this.remaining,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalPredicted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Remaining Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${remaining.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: remaining >= 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryFigure(label: 'Total Budget', value: totalBudget),
                _SummaryFigure(label: 'Actual Spent', value: totalSpent),
                _SummaryFigure(
                  label: 'Predicted',
                  value: totalPredicted,
                  color: Theme.of(context).colorScheme.secondary
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryFigure extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;

  const _SummaryFigure({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color)),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
