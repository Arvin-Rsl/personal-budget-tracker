import 'package:flutter/material.dart';
import '../budget_state.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _descriptionError;
  String? _amountError;

  @override
  void initState() {
    super.initState();

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
          const Text(
            'Add Income',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Scholarship installment, Gift from relatives',
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
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

                provider.addIncome(
                  inputDescription,
                  inputAmount!,
                  _selectedDate,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add Income'),
            ),
          ),
        ],
      ),
    );
  }
}
