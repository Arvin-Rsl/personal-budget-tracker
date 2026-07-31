import 'package:flutter/material.dart';
import '../budget_state.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);
    final balance = provider.getSavingsBalance();

    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            // TODO: Add Transfer button + transfer history list
          ],
        ),
      ),
    );
  }
}
