import 'package:flutter/material.dart';
import '../budget_state.dart';
import '../models/budget_models.dart';
import '../providers/budget_provider.dart';

class TransferForm extends StatefulWidget {
  final FundPool sourcePool;
  final List<FundPool> allowedDestinations;

  const TransferForm({
    super.key,
    required this.sourcePool,
    required this.allowedDestinations,
  });

  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _amountController = TextEditingController();

  late FundPool _selectedDestination;
  String? _selectedCategoryId;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  String? _amountError;

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

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.allowedDestinations.first;

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
    _amountController.dispose();
    super.dispose();
  }

  String _labelFor(FundPool pool) {
    switch (pool) {
      case FundPool.unallocatedFunds:
        return 'Unallocated Funds';
      case FundPool.savings:
        return 'Savings';
      case FundPool.categoryBudget:
        return 'A Category Budget';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);
    final bool needsCategoryPicker =
        _selectedDestination == FundPool.categoryBudget;

    _selectedCategoryId ??= provider.categories.first.id;

    final List<int> yearsList = List.generate(16, (index) => 2020 + index);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.allowedDestinations.length > 1
                ? 'Transfer from ${_labelFor(widget.sourcePool)}'
                : 'Transfer from ${_labelFor(widget.sourcePool)} to ${_labelFor(widget.allowedDestinations.first)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              errorText: _amountError,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.allowedDestinations.length > 1)
            DropdownButtonFormField<FundPool>(
              initialValue: _selectedDestination,
              decoration: const InputDecoration(labelText: 'Transfer To'),
              items: widget.allowedDestinations.map((pool) {
                return DropdownMenuItem(
                  value: pool,
                  child: Text(_labelFor(pool)),
                );
              }).toList(),
              onChanged: (FundPool? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDestination = newValue;
                  });
                }
              },
            ),
          if (needsCategoryPicker) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: provider.categories.map((Category choice) {
                return DropdownMenuItem(
                  value: choice.id,
                  child: Text(choice.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategoryId = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Budget Month', style: Theme.of(context).textTheme.bodySmall),
            Row(
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(MONTHS[index]),
                    );
                  }),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: yearsList.map((int year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final double? inputAmount = double.tryParse(
                  _amountController.text,
                );

                if (inputAmount == null || inputAmount <= 0) {
                  setState(() {
                    _amountError = 'Enter a Positive Amount!';
                  });
                  return;
                }
                if (needsCategoryPicker &&
                    provider.isMonthClosed(_selectedYear, _selectedMonth)) {
                  _showClosedMonthWarning(context, provider, inputAmount);
                  return;
                }
                _performTransfer(provider, inputAmount);
              },
              child: const Text('Transfer'),
            ),
          ),
        ],
      ),
    );
  }

  void _showClosedMonthWarning(
    BuildContext context,
    BudgetProvider provider,
    double amount,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Month is Closed'),
          content: Text(
            '${MONTHS[_selectedMonth - 1]} $_selectedYear is closed. You can\'t '
            'allocate money to a closed month. Reopen it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.reopenMonth(_selectedYear, _selectedMonth);
                Navigator.of(dialogContext).pop();
                _performTransfer(provider, amount);
              },
              child: const Text('Reopen Month'),
            ),
          ],
        );
      },
    );
  }

  void _performTransfer(BudgetProvider provider, double amount) {
    final bool needsCategoryPicker =
        _selectedDestination == FundPool.categoryBudget;

    provider.addTransfer(
      amount,
      DateTime.now(),
      widget.sourcePool,
      _selectedDestination,
      categoryId: needsCategoryPicker ? _selectedCategoryId : null,
      year: needsCategoryPicker ? _selectedYear : null,
      month: needsCategoryPicker ? _selectedMonth : null,
    );

    Navigator.of(context).pop();
  }
}
