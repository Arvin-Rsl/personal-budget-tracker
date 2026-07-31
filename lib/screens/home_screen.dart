import 'package:flutter/material.dart';
import '../budget_state.dart';
import '../app.dart';
import '../widgets/category_card.dart';
import '../widgets/income_form.dart';
import '../widgets/transaction_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _inspectedMonth = DateTime.now();
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
    final double totalBudget = provider.getTotalBudget(targetYear, targetMonth);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            icon: const Icon(Icons.palette_outlined, size: 26),
            tooltip: 'Theme',
            onPressed: () => _showThemeSettingsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 28),
            tooltip: 'Change Month',
            onPressed: () => _showMonthPickerDialog(context),
          ),
          const Padding(padding: EdgeInsets.only(right: 8.0)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                final transactions = provider
                    .getTransactionsForCategoryAndMonth(
                      category.id,
                      targetYear,
                      targetMonth,
                    );
                final bool isExpanded = category.id == _expandedCategoryId;
                final allocatedBudget = provider
                    .getAllocatedBudgetForCategoryAndMonth(
                      category.id,
                      targetYear,
                      targetMonth,
                    );

                return CategoryCard(
                  category: category,
                  allocatedBudget: allocatedBudget,
                  spentAmount: spent,
                  transactions: transactions,
                  isExpanded: isExpanded,
                  onTap: () {
                    setState(() {
                      _expandedCategoryId = isExpanded ? null : category.id;
                    });
                  },
                  onEditTransaction: (transaction) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => TransactionForm(
                        currentViewedMonth: _inspectedMonth,
                        transactionToEdit: transaction,
                        onDateChanged: (newMonth) {
                          setState(() {
                            _inspectedMonth = newMonth;
                          });
                        },
                      ),
                    );
                  },
                  onDeleteTransaction: (transactionId) {
                    provider.deleteTransaction(transactionId);
                  },
                );
              },
            ),
          ],
        ),
      ),
      // TODO: Replace single "Add Cost" FAB with a choice: Add Expense / Add Income
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showThemeSettingsDialog(BuildContext context) {
    final themeState = MyApp.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Theme Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Mode',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                  ),
                ],
                selected: {themeState.themeMode},
                onSelectionChanged: (Set<ThemeMode> selection) {
                  themeState.changeThemeMode(selection.first);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Accent Color Palette',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AppThemeColor>(
                initialValue: themeState.activeColor,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: AppThemeColor.values.map((AppThemeColor color) {
                  return DropdownMenuItem<AppThemeColor>(
                    value: color,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color.seedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(color.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (AppThemeColor? newColor) {
                  if (newColor != null) {
                    themeState.changeColorTheme(newColor);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMonthPickerDialog(BuildContext context) async {
    int selectedYear = _inspectedMonth.year;
    int selectedMonthNum = _inspectedMonth.month;
    final List<int> yearsList = List.generate(16, (index) => 2020 + index);

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
                        setDialogState(() => selectedMonthNum = newValue);
                      }
                    },
                  ),
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
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: const Text('Add Expense'),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => TransactionForm(
                      currentViewedMonth: _inspectedMonth,
                      onDateChanged: (newMonth) {
                        setState(() {
                          _inspectedMonth = newMonth;
                        });
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Add Income'),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const IncomeForm(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
