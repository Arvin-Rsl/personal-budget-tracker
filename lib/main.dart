import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';
import 'models/budget_models.dart';

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
    final provider = BudgetState.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Budget Tracker'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // financial summary
            Card(
              elevation: 4, // a subtle, sleek shadow below the card frame
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

                    // Displays the dynamically calculated remaining balance
                    Text(
                      '\$${provider.getOverallRemainingBudget().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: provider.getOverallRemainingBudget() > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider line separating the main balance from the secondary totals row
                    const Divider(),
                    const SizedBox(height: 12),

                    // Horizontal Row breaking down Total Budget allocation vs Total Spent costs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Total Budget',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${provider.getTotalBudget().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Total Spent',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${provider.getTotalSpent().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Text(
              'Monthly Expenses by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // TODO: Implement Scrollable List of Categories with Progress Indicators
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const TransactionForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
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

          // Category dropdown menu
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: provider.categories.map((Category choice) {
              return DropdownMenuItem<String>(
                value: choice.id,
                child: Text(choice.name),
              );
            }).toList(),
            // Whenever the user clicks an alternative option label:
            onChanged: (String? newlySelectedValue) {
              setState(() {
                _selectedCategoryId = newlySelectedValue;
              });
            },
          ),
          const SizedBox(height: 16),

          // Date selection row displaying the choice and the calendar trigger button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  // Opens the OS-native full graphic calendar picker overlay modal
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  // If the user picked a valid calendar date and didn't hit cancel
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submission trigger button
          SizedBox(
            width: double.infinity,
            // Stretches the button horizontally across the full card width
            child: FilledButton(
              onPressed: () {
                final String inputDescription = _descriptionController.text.trim();
                final double? inputAmount = double.tryParse(_amountController.text);

                if (inputAmount == null || inputAmount <= 0) {
                  debugPrint('Invalid Amount!');
                  return;
                } else if (inputDescription.isEmpty) {
                  debugPrint('Empty Description!');
                  return;
                }

                provider.addTransaction(
                  inputDescription,
                  inputAmount,
                  _selectedCategoryId!,
                  _selectedDate,
                );

                // return the user to the dashboard
                Navigator.of(context).pop();
              },
              child: const Text('Add Cost'),
            ),
          ),
        ],
      ),
    );
  }
}
