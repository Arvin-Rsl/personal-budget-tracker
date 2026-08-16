import 'package:flutter/material.dart';
import '../budget_state.dart';
import '../screens/unallocated_funds_screen.dart';
import '../screens/savings_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/settings_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Unallocated Funds'),
              trailing: Text(
                '\$${provider.getUnallocatedFundsBalance().toStringAsFixed(2)}',
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UnallocatedFundsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: const Text('Savings'),
              trailing: Text(
                '\$${provider.getSavingsBalance().toStringAsFixed(2)}',
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SavingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
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
