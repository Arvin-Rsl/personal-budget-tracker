import 'package:flutter/material.dart';
import '../budget_state.dart';
import '../models/budget_models.dart';

class TransactionForm extends StatefulWidget {
  final DateTime currentViewedMonth;
  final ValueChanged<DateTime> onDateChanged;
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
    if (widget.transactionToEdit != null) {
      final transaction = widget.transactionToEdit!;
      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toString();
      _selectedCategoryId = transaction.categoryId;
      _selectedDate = transaction.date;
    } else {
      if (DateTime.now().month == widget.currentViewedMonth.month &&
          DateTime.now().year == widget.currentViewedMonth.year) {
        _selectedDate = DateTime.now();
      } else {
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
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = BudgetState.of(context);
    _selectedCategoryId ??= provider.categories.first.id;
    final bool isDifferentMonth =
        _selectedDate.year != widget.currentViewedMonth.year ||
        _selectedDate.month != widget.currentViewedMonth.month;

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
            widget.transactionToEdit != null ? 'Edit Cost' : 'Add Cost',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: provider.categories.map((Category choice) {
              return DropdownMenuItem<String>(
                value: choice.id,
                child: Text(choice.name),
              );
            }).toList(),
            onChanged: (String? newlySelectedValue) {
              setState(() {
                _selectedCategoryId = newlySelectedValue;
              });
            },
          ),
          const SizedBox(height: 16),
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
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
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
          SizedBox(
            width: double.infinity,
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

                if (isDifferentMonth) {
                  widget.onDateChanged(_selectedDate);
                }

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
