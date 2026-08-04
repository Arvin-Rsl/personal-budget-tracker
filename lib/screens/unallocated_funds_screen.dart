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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 48),
                      FilledButton.icon(
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Transfer'),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const TransferForm(
                              sourcePool: FundPool.unallocatedFunds,
                              allowedDestinations: [
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
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Money that\'s available but not yet assigned anywhere. '
                  'You can move it into Savings to set it aside, allocate it to '
                  'a category\'s budget for a chosen month, or just keep it here!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
