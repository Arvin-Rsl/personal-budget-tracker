import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BudgetState(
      notifier: BudgetProvider(),
      child: MaterialApp(
        title: 'Personal Budget Tracker',
        debugShowCheckedModeBanner: false, // hide the red development banner
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Extract budget state provider data and layout the scannable scaffold dashboard
    return const Scaffold(body: Center(child: Text('Dashboard Stub')));
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now(); // default = current moment

  @override
  void dispose() {
    // clean up controllers when the form is closed to prevent system memory leaks
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);

    // default to the first available category ID if nothing is chosen yet
    _selectedCategoryId ??= provider.categories.first.id;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // ensures the form slides up perfectly above the keyboard
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // constrains the sheet to only be as tall as its contents
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Cost',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Lunch at Feast, Phone bill, Drake concert',
            ),
          ),
          const SizedBox(height: 12),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText:
                  '\$ ', // Automatically prefixes a dollar sign to the input line
            ),
          ),
          const SizedBox(height: 12),

          // TODO: Implement Category Selection Dropdown

          // TODO: Implement Interactive Date Picker Row

          // TODO: Implement Action Submission Button
        ],
      ),
    );
  }
}
