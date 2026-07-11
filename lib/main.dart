import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';
import 'models/budget_models.dart';

enum AppThemeColor {
  teal('Teal', Colors.teal),
  purple('Purple', Colors.purple),
  orange('Orange', Colors.orange),
  indigo('Indigo', Colors.indigo),
  lime('Lime', Colors.lime),
  green('Green', Colors.green);

  final String label;
  final Color seedColor;

  const AppThemeColor(this.label, this.seedColor);
}

void main() {
  runApp(const MyApp());
}

// InheritedWidget to broadcast theme changes down the widget tree efficiently
class InheritedThemeData extends InheritedWidget {
  final _MyAppState state;

  const InheritedThemeData({
    super.key,
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedThemeData oldWidget) => true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default = dark mode
  AppThemeColor _activeColor = AppThemeColor.teal;

  // Static helper so child elements can easily reach back and trigger updates
  static _MyAppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedThemeData>()!
        .state;
  }

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void changeColorTheme(AppThemeColor color) {
    setState(() {
      _activeColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedThemeData(
      state: this,
      child: BudgetState(
        notifier: BudgetProvider(),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Personal Budget Tracker',
              debugShowCheckedModeBanner: false,

              // Light Theme settings using the active seed color
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _activeColor.seedColor,
                  brightness: Brightness.light,
                ),
              ),

              // Dark Theme settings using the active seed color
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _activeColor.seedColor,
                  brightness: Brightness.dark,
                ),
              ),

              themeMode: _themeMode,
              // Controlled dynamically by our state hook
              home: const HomeScreen(),
            );
          },
        ),
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
  DateTime _inspectedMonth = DateTime.now();

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

    final int targetYear = _inspectedMonth.year;
    final int targetMonth = _inspectedMonth.month;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left Arrow (Previous Month)
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 24),
              tooltip: 'Previous Month',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _inspectedMonth = DateTime(
                    _inspectedMonth.year,
                    _inspectedMonth.month - 1,
                  );
                });
              },
            ),
            const SizedBox(width: 8),

            Text('${_getMonthName(targetMonth)} $targetYear'),
            const SizedBox(width: 8),

            // Right Arrow (Next Month)
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 24),
              tooltip: 'Next Month',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _inspectedMonth = DateTime(
                    _inspectedMonth.year,
                    _inspectedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 28),
            tooltip: 'Change Month',
            onPressed: () async {
              int selectedYear = _inspectedMonth.year;
              int selectedMonthNum = _inspectedMonth.month;

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
                                _inspectedMonth = DateTime(
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

                final double percentSpent = budget > 0 ? (spent / budget) : 0.0;

                final bool isExpanded = category.id == _expandedCategoryId;

                Color _getProgressColor(double percent) {
                  if (percent >= 1.0) {
                    return Colors.redAccent.shade700; // Ultra Warning
                  } else if (percent >= 0.90) {
                    return Colors.red.shade400; // Critical Alert
                  } else if (percent >= 0.70) {
                    return Colors.orangeAccent.shade400; // Caution Alert
                  } else {
                    return Theme.of(context).colorScheme.primary; // Safe Zone
                  }
                }

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
                            value: percentSpent.clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            color: _getProgressColor(percentSpent),
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
                                              const SizedBox(width: 20),

                                              // Edit Button
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                ),
                                                tooltip: 'Edit',
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  // open the same sheet, but pass the transaction data into it
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) => TransactionForm(
                                                      currentViewedMonth:
                                                          _inspectedMonth,
                                                      transactionToEdit:
                                                          transaction,
                                                      // pass this entry to pre-fill the form
                                                      onDateChanged:
                                                          (
                                                            DateTime
                                                            newMonthToView,
                                                          ) {
                                                            setState(() {
                                                              _inspectedMonth =
                                                                  newMonthToView;
                                                            });
                                                          },
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 16),

                                              // Delete Button
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                                tooltip: 'Delete',
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
        tooltip: 'Add Cost',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => TransactionForm(
              currentViewedMonth: _inspectedMonth,
              onDateChanged: (DateTime newMonthToView) {
                setState(() {
                  _inspectedMonth = newMonthToView;
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

  String? _descriptionError;
  String? _amountError;

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
      if (DateTime.now().month == widget.currentViewedMonth.month) {
        // Default = current moment if adding a new transaction belonging to this month.
        _selectedDate = DateTime.now();
      } else {
        // Default = some day in the month we're currently viewing
        _selectedDate = widget.currentViewedMonth;
      }
    }

    _descriptionController.addListener(() {
      if (_descriptionError != null &&
          _descriptionController.text.trim().isNotEmpty) {
        setState(() {
          _descriptionError = null;
        });
      }
    });
    _amountController.addListener(() {
      if (_amountError != null) {
        final double? amt = double.tryParse(_amountController.text);
        if (amt != null && amt > 0) {
          setState(() {
            _amountError = null;
          });
        }
      }
    });
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
          Text(
            widget.transactionToEdit != null ? 'Edit Cost' : 'Add Cost',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Lunch at Feast, Phone bill, Drake concert',
              errorText: _descriptionError,
            ),
          ),
          const SizedBox(height: 12),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText:
                  '\$ ', // Automatically prefixes a dollar sign to the input line
              errorText: _amountError,
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
                tooltip: 'Calendar',
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

                String? tempDescError;
                String? tempAmtError;

                if (inputAmount == null) {
                  tempAmtError = 'Invalid Amount!';
                } else if (inputAmount <= 0) {
                  tempAmtError = 'Enter a Positive Amount!';
                }
                if (inputDescription.isEmpty) {
                  tempDescError = 'Description cannot be empty!';
                }
                if (tempDescError != null || tempAmtError != null) {
                  setState(() {
                    _descriptionError = tempDescError;
                    _amountError = tempAmtError;
                  });
                  return;
                }

                if (widget.transactionToEdit != null) {
                  provider.editTransaction(
                    widget.transactionToEdit!.id,
                    inputDescription,
                    inputAmount!,
                    _selectedCategoryId!,
                    _selectedDate,
                  );
                } else {
                  provider.addTransaction(
                    inputDescription,
                    inputAmount!,
                    _selectedCategoryId!,
                    _selectedDate,
                  );
                }

                // if they picked an out-of-bounds month, notify the HomeScreen
                if (isDifferentMonth) {
                  widget.onDateChanged(_selectedDate);
                }

                // return the user to the dashboard
                Navigator.of(context).pop();
              },
              child: Text(
                widget.transactionToEdit != null ? 'Save' : 'Add Cost',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
