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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which month and year the user is currently inspecting
  DateTime _selectedMonth = DateTime.now();

  // Track which category is expanded. Null if all cards are closed.
  String? _expandedCategoryId;

  static const MONTHS = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Helper method to turn a month number into a readable word string
  String _getMonthName(int month) {
    return MONTHS[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);

    final int targetYear = _selectedMonth.year;
    final int targetMonth = _selectedMonth.month;

    final double remaining = provider.getOverallRemainingBudgetForMonth(
      targetYear,
      targetMonth,
    );
    final double totalSpent = provider.getTotalSpentForMonth(
      targetYear,
      targetMonth,
    );
    final double totalBudget = provider.getTotalBudget();

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getMonthName(targetMonth)} $targetYear'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 28),
            tooltip: 'Change Month',
            onPressed: () async {
              int selectedYear = _selectedMonth.year;
              int selectedMonthNum = _selectedMonth.month;

              // Generate a list of years dynamically (e.g., from 2020 to 2035)
              final List<int> yearsList = List.generate(
                16,
                (index) => 2020 + index,
              );

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AlertDialog(
                        title: const Text('Select Month & Year'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Month Picker Dropdown
                            DropdownButton<int>(
                              value: selectedMonthNum,
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(MONTHS[index]),
                                );
                              }),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setDialogState(
                                    () => selectedMonthNum = newValue,
                                  );
                                }
                              },
                            ),

                            // Year Picker Dropdown
                            DropdownButton<int>(
                              value: selectedYear,
                              items: yearsList.map((int year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setDialogState(() => selectedYear = newValue);
                                }
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  selectedYear,
                                  selectedMonthNum,
                                );
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),

          const Padding(padding: EdgeInsets.only(right: 8.0)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // financial summary (monthly)
            Card(
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
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
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
                        Column(
                          children: [
                            const Text(
                              'Total Budget',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${totalBudget.toStringAsFixed(2)}',
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
                              '\$${totalSpent.toStringAsFixed(2)}',
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
            const SizedBox(height: 24),

            const Text(
              'Monthly Expenses by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Category progress track sequence (monthly)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                final spent = provider.getAmountSpentForCategoryAndMonth(
                  category.id,
                  targetYear,
                  targetMonth,
                );
                final budget = category.allocatedBudget;

                final double percentSpent = budget > 0
                    ? (spent / budget).clamp(0.0, 1.0)
                    : 0.0;

                final bool isExpanded = category.id == _expandedCategoryId;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  // (clip behavior) ensuring the InkWell splash ripple doesn't bleed past the rounded card corners
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedCategoryId = null; // close if clicked again
                        } else {
                          _expandedCategoryId = category.id; // open this one
                        }
                      });
                    },
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '\$${spent.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}',
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
                            value: percentSpent,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            color: percentSpent >= 1.0
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),

                            Builder(
                              builder: (context) {
                                final transactions = provider
                                    .getTransactionsForCategoryAndMonth(
                                      category.id,
                                      targetYear,
                                      targetMonth,
                                    );

                                if (transactions.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
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
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  // lets this nested list sit inside another Column safely
                                  physics: const NeverScrollableScrollPhysics(),
                                  // disables nested scrolling fights
                                  itemCount: transactions.length,
                                  itemBuilder: (context, transactionIndex) {
                                    final transaction =
                                        transactions[transactionIndex];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Flexible protects us from layout crashes if the description text is very long
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaction.description,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Group price tag and action buttons together on the right side
                                          Row(
                                            children: [
                                              Text(
                                                '-\$${transaction.amount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.errorContainer,
                                                ),
                                              ),
                                              const SizedBox(width: 4),

                                              // Edit Button
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  // open the same sheet, but pass the transaction data into it
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) =>
                                                        TransactionForm(
                                                          currentViewedMonth:
                                                              _selectedMonth,
                                                          transactionToEdit:
                                                              transaction,
                                                          // pass this entry to pre-fill the form
                                                          onDateChanged:
                                                              (
                                                                DateTime
                                                                newMonthToView,
                                                              ) {},
                                                        ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 8),

                                              // Delete Button
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  provider.deleteTransaction(
                                                    transaction.id,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => TransactionForm(
              currentViewedMonth: _selectedMonth,
              onDateChanged: (DateTime newMonthToView) {
                setState(() {
                  _selectedMonth = newMonthToView;
                });
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  final DateTime currentViewedMonth;
  final ValueChanged<DateTime> onDateChanged;

  // the transaction we want to modify. If null, we're adding a new cost.
  final Transaction? transactionToEdit;

  const TransactionForm({
    super.key,
    required this.currentViewedMonth,
    required this.onDateChanged,
    this.transactionToEdit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // If we passed a transaction to edit, pre-populate the form fields with its current data
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _descriptionController.text = tx.description;
      _amountController.text = tx.amount.toString();
      _selectedCategoryId = tx.categoryId;
      _selectedDate = tx.date;
    } else {
      // Default = current moment if adding a new transaction
      _selectedDate = DateTime.now();
    }
  }

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
    // Check if the currently chosen transaction date is outside the viewed month frame
    final bool isDifferentMonth =
        _selectedDate.year != widget.currentViewedMonth.year ||
        _selectedDate.month != widget.currentViewedMonth.month;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  // If the user selected a different month, show the hint inline
                  if (isDifferentMonth)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '💡 Saving will switch view to month ${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
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
                final String inputDescription = _descriptionController.text
                    .trim();
                final double? inputAmount = double.tryParse(
                  _amountController.text,
                );

                if (inputAmount == null || inputAmount <= 0) {
                  debugPrint('Invalid Amount!');
                  return;
                } else if (inputDescription.isEmpty) {
                  debugPrint('Empty Description!');
                  return;
                }

                if (widget.transactionToEdit != null) {
                  provider.editTransaction(
                    widget.transactionToEdit!.id,
                    inputDescription,
                    inputAmount,
                    _selectedCategoryId!,
                    _selectedDate,
                  );
                } else {
                  provider.addTransaction(
                    inputDescription,
                    inputAmount,
                    _selectedCategoryId!,
                    _selectedDate,
                  );
                }

                // if they picked an out-of-bounds month, notify the HomeScreen
                if (isDifferentMonth) {
                  widget.onDateChanged(_selectedDate);
                }
                // TODO: handle month switch in edit mode 

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
