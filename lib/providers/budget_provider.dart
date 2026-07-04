import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_budget_app/models/budget_models.dart';

class BudgetProvider extends ChangeNotifier {
  final List<Category> _categories = [
    Category(id: '1', name: 'Food', allocatedBudget: 500.0),
    Category(id: '2', name: 'Transportation', allocatedBudget: 100.0),
    Category(id: '3', name: 'Sports', allocatedBudget: 80.0),
    Category(id: '4', name: 'Clothes', allocatedBudget: 150.0),
    Category(id: '5', name: 'Household Essentials', allocatedBudget: 80.0),
    Category(id: '6', name: 'Having Fun', allocatedBudget: 150.0),
    Category(id: '7', name: 'Savings', allocatedBudget: 1000.0),
  ];

  List<Transaction> _transactions = [];

  List<Category> get categories => _categories;

  List<Transaction> get transactions => _transactions;

  double getAmountSpentForCategory(String categoryId) {
    double total = 0;
    for (Transaction t in transactions) {
      if (t.categoryId == categoryId) {
        total += t.amount;
      }
    }
    return total;
  }

  double getRemainingBudget(Category category) {
    return category.allocatedBudget - getAmountSpentForCategory(category.id);
  }

  void addTransaction(
    String description,
    double amount,
    String categoryId,
    DateTime selectedDate,
  ) {
    final newTransaction = Transaction(
      // unique timestamp ID, for my (currently) offline local app
      id: DateTime.now().toString(),
      description: description,
      amount: amount,
      date: selectedDate,
      categoryId: categoryId,
    );

    _transactions.add(newTransaction);

    _saveData();

    notifyListeners();
  }

  void _saveData() {
    try {
      final file = _getLocalStorageFile();
      // Convert our list of Transaction objects into a List of Maps (JSON format)
      final List<Map<String, dynamic>> structuredData = _transactions
          .map(
            (transaction) => {
              'id': transaction.id,
              'description': transaction.description,
              'amount': transaction.amount,
              'date': transaction.date.toIso8601String(),
              'categoryId': transaction.categoryId,
            },
          )
          .toList();

      // Encode the structured map data into a long single string text and write it
      file.writeAsStringSync(jsonEncode(structuredData));
    } catch (error) {
      debugPrint("Failed to write budget data to disk: $error");
    }
  }

  void _loadData() {
    try {
      final file = _getLocalStorageFile();

      // Safety check: if the file doesn't exist yet (first-time launch), stop here
      if (file.existsSync()) {
        final String rawText = file.readAsStringSync();

        // Convert the raw string text back into a dynamic Dart List of Maps
        final List<dynamic> decodedData = jsonDecode(rawText);

        // Reconstruct our structured Transaction objects from the map values
        _transactions = decodedData
            .map(
              (item) => Transaction(
                id: item['id'],
                description: item['description'],
                amount: (item['amount'] as num).toDouble(),
                date: DateTime.parse(item['date']),
                categoryId: item['categoryId'],
              ),
            )
            .toList();

        notifyListeners();
      }
    } catch (error) {
      debugPrint("Failed to recover budget data from disk: $error");
    }
  }
}

// Locates a secure local system file address for persistent storage
File _getLocalStorageFile() {
  // Accesses a safe, sandbox environment directory provided by the operating system
  final systemDirectory = Directory.systemTemp.path;
  return File('$systemDirectory/my_smart_budget_data.json');
}
