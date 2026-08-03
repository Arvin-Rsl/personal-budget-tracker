import 'package:flutter/material.dart';
import '../budget_state.dart';
import '../models/budget_models.dart';
import '../widgets/transfer_form.dart';

class UnallocatedFundsScreen extends StatelessWidget {
  const UnallocatedFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);
    final balance = provider.getUnallocatedFundsBalance();

    return Scaffold(
      appBar: AppBar(title: const Text('Unallocated Funds')),
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
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => TransferForm(
                    sourcePool: FundPool.unallocatedFunds,
                    allowedDestinations: const [
                      FundPool.savings,
                      FundPool.categoryBudget,
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
