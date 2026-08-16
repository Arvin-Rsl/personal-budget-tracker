import 'package:flutter/material.dart';
import '../budget_state.dart';
import '../models/budget_models.dart';
import '../widgets/category_card.dart';
import '../widgets/income_form.dart';
import '../widgets/transaction_form.dart';
import '../widgets/month_navigation_header.dart';
import '../widgets/home_drawer.dart';
import '../widgets/month_close_banner.dart';
import '../widgets/overdue_predictions_banner.dart';
import '../widgets/budget_summary_card.dart';
import '../utils/months.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _inspectedMonth = DateTime.now();
  String? _expandedCategoryId;

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
    final double totalBudget = provider.getTotalMonthlyBudget(
      targetYear,
      targetMonth,
    );

    double totalPredicted = 0.0;
    for (final category in provider.categories) {
      totalPredicted += provider.getPredictedAmountForCategoryAndMonth(
        category.id,
        targetYear,
        targetMonth,
      );
    }

    final bool isTooOld = provider.isMonthTooOldToEdit(targetYear, targetMonth);
    final bool isClosed = provider.isMonthClosed(targetYear, targetMonth);
    final int monthsAgo =
        (DateTime.now().year - targetYear) * 12 +
        DateTime.now().month -
        targetMonth;
    final bool isPreviousMonth = monthsAgo == 1;
    final overdueTransactions = provider.getOverdueUnconfirmedTransactions();

    return Scaffold(
      appBar: AppBar(
        title: MonthNavigationHeader(
          year: targetYear,
          month: targetMonth,
          isClosed: isClosed,
          isTooOld: isTooOld,
          onPreviousMonth: () {
            setState(() {
              _inspectedMonth = DateTime(
                _inspectedMonth.year,
                _inspectedMonth.month - 1,
              );
            });
          },
          onNextMonth: () {
            setState(() {
              _inspectedMonth = DateTime(
                _inspectedMonth.year,
                _inspectedMonth.month + 1,
              );
            });
          },
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 28),
            tooltip: 'Change Month',
            onPressed: () => _showMonthPickerDialog(context),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overdueTransactions.isNotEmpty) ...[
              OverduePredictionsBanner(
                overdueTransactions: overdueTransactions,
                onConfirm: (transactionId) =>
                    _confirmTransaction(context, transactionId),
                onReschedule: (transaction) {
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
                onDelete: (transactionId) =>
                    provider.deleteTransaction(transactionId),
              ),
              const SizedBox(height: 16),
            ],
            if (isPreviousMonth && !isClosed) ...[
              MonthCloseBanner(
                year: targetYear,
                month: targetMonth,
                onWrapUp: () =>
                    _handleCloseMonth(context, targetYear, targetMonth),
              ),
              const SizedBox(height: 16),
            ],
            BudgetSummaryCard(
              remaining: remaining,
              totalBudget: totalBudget,
              totalSpent: totalSpent,
              totalPredicted: totalPredicted,
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
                final predicted = provider
                    .getPredictedAmountForCategoryAndMonth(
                      category.id,
                      targetYear,
                      targetMonth,
                    );

                return CategoryCard(
                  category: category,
                  allocatedBudget: allocatedBudget,
                  spentAmount: spent,
                  predictedAmount: predicted,
                  transactions: transactions,
                  isExpanded: isExpanded,
                  isMonthClosed: isClosed,
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
                  onDeleteTransaction: (transactionId) =>
                      provider.deleteTransaction(transactionId),
                  onConfirmTransaction: (transactionId) =>
                      _confirmTransaction(context, transactionId),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isTooOld
          ? null
          : isClosed
          ? FloatingActionButton(
              tooltip: 'Month Closed',
              onPressed: () => _showClosedMonthDialog(
                context,
                targetYear,
                targetMonth,
                monthsAgo,
              ),
              child: const Icon(Icons.priority_high),
            )
          : FloatingActionButton(
              tooltip: 'Add',
              onPressed: () => _showAddOptions(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _handleCloseMonth(
    BuildContext context,
    int year,
    int month,
  ) async {
    final provider = BudgetState.of(context);
    final unconfirmed = provider.getUnconfirmedTransactionsForMonth(
      year,
      month,
    );

    if (unconfirmed.isEmpty) {
      provider.closeMonth(year, month);
      return;
    }

    final bool? shouldClose = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Unhandled Predicted Expenses'),
          content: Text(
            'You have ${unconfirmed.length} unconfirmed predicted expense'
            '${unconfirmed.length == 1 ? '' : 's'} in this month. Closing the '
            'month will cancel and delete ${unconfirmed.length == 1 ? 'it' : 'them'}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Close Month and Delete Unconfirmed Expenses'),
            ),
          ],
        );
      },
    );

    if (shouldClose == true) {
      provider.closeMonth(year, month, deleteUnconfirmed: true);
    }
  }

  void _showClosedMonthDialog(
    BuildContext context,
    int year,
    int month,
    int monthsAgo,
  ) {
    final provider = BudgetState.of(context);
    final bool canReopen = monthsAgo <= 24;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Month Closed'),
          content: Text(
            '${monthName(month)} $year has been closed. Any unspent '
            'budget was moved to Unallocated Funds.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (canReopen)
              TextButton(
                onPressed: () {
                  provider.reopenMonth(year, month);
                  Navigator.of(context).pop();
                },
                child: const Text('Reopen Month'),
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
                        child: Text(monthNames[index]),
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

Future<void> _confirmTransaction(
  BuildContext context,
  String transactionId,
) async {
  final provider = BudgetState.of(context);
  final transaction = provider.transactions.firstWhere(
    (t) => t.id == transactionId,
  );
  final year = transaction.date.year;
  final month = transaction.date.month;

  final allocated = provider.getAllocatedBudgetForCategoryAndMonth(
    transaction.categoryId,
    year,
    month,
  );
  final alreadySpent = provider.getAmountSpentForCategoryAndMonth(
    transaction.categoryId,
    year,
    month,
  );
  final shortfall = (alreadySpent + transaction.amount) - allocated;

  if (shortfall > 0) {
    final monthIsClosed = provider.isMonthClosed(year, month);
    final unallocated = provider.getUnallocatedFundsBalance();
    final canTopUp = !monthIsClosed && unallocated >= shortfall;

    final bool? choice = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Over Budget'),
          content: Text(
            canTopUp
                ? 'Confirming this expense goes \$${shortfall.toStringAsFixed(2)} over '
                      'budget for this category. Cover it from Unallocated Funds?'
                : 'Confirming this expense goes \$${shortfall.toStringAsFixed(2)} over '
                      'budget for this category, and there isn\'t enough in Unallocated '
                      'Funds to cover it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            if (canTopUp)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Cover Shortfall'),
              ),
          ],
        );
      },
    );

    if (choice != true) return;

    provider.addTransfer(
      shortfall,
      DateTime.now(),
      FundPool.unallocatedFunds,
      FundPool.categoryBudget,
      categoryId: transaction.categoryId,
      year: year,
      month: month,
    );
  }

  provider.confirmTransaction(transactionId);
}
