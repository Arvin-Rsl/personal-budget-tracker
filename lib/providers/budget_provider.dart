import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_budget_app/models/budget_models.dart';

class BudgetProvider extends ChangeNotifier {
  final List<Category> _categories = [
    Category(id: '1', name: 'Food, Groceries', allocatedBudget: 200.0),
    Category(id: '2', name: 'Student Fees', allocatedBudget: 200.0),
    Category(
      id: '3',
      name: 'Books, Educational Supplies',
      allocatedBudget: 200.0,
    ),
    Category(id: '4', name: 'Sports, Gym', allocatedBudget: 200.0),
    Category(id: '5', name: 'Clothing', allocatedBudget: 200.0),
    Category(
      id: '6',
      name: 'Personal, Toiletries, Household Supplies',
      allocatedBudget: 200.0,
    ),
    Category(
      id: '7',
      name: 'Transportation (Excluding U-Pass)',
      allocatedBudget: 200.0,
    ),
    Category(
      id: '8',
      name: 'Tech Services (Internet, Phone, etc.)',
      allocatedBudget: 200.0,
    ),
    Category(id: '9', name: 'Clubs, Recreation', allocatedBudget: 200.0),
    Category(
      id: '10',
      name: 'Having Fun, Social Activities',
      allocatedBudget: 200.0,
    ),
    Category(id: '11', name: 'Savings', allocatedBudget: 200.0),
  ];

  List<Transaction> _transactions = [];

  List<Category> get categories => _categories;

  List<Transaction> get transactions => _transactions;

  BudgetProvider() {
    _loadData();
  }

  double getTotalBudget() {
    double totalBudget = 0;
    for (Category category in categories) {
      totalBudget += category.allocatedBudget;
    }
    return totalBudget;
  }

  double getTotalSpentForMonth(int year, int month) {
    double total = 0.0;
    for (Transaction transaction in _transactions) {
      if (year == transaction.date.year && month == transaction.date.month) {
        total += transaction.amount;
      }
    }
    return total;
  }

  double getOverallRemainingBudgetForMonth(int year, int month) {
    double totalBudget = 0.0;
    for (Category category in categories) {
      totalBudget += category.allocatedBudget;
    }
    return totalBudget - getTotalSpentForMonth(year, month);
  }

  double getAmountSpentForCategoryAndMonth(
    String categoryId,
    int year,
    int month,
  ) {
    double total = 0.0;
    for (Transaction transaction in getTransactionsForCategoryAndMonth(
      categoryId,
      year,
      month,
    )) {
      total += transaction.amount;
    }
    return total;
  }

  /// Returns a list of transactions filtered by category, year, and month, sorted by date
  List<Transaction> getTransactionsForCategoryAndMonth(
    String categoryId,
    int year,
    int month,
  ) {
    final filtered = _transactions.where((transaction) {
      return transaction.categoryId == categoryId &&
          transaction.date.year == year &&
          transaction.date.month == month;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
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

  /// Permanently removes a transaction from the state bucket and alerts the UI layer
  void deleteTransaction(String transactionId) {
    _transactions.removeWhere((transaction) => transaction.id == transactionId);

    _saveData();

    notifyListeners();
  }

  /// Updates the core properties of an existing transaction entry
  void editTransaction(
    String transactionId,
    String newDescription,
    double newAmount,
    String newCategoryId,
    DateTime newDate,
  ) {
    final targetTransaction = _transactions.firstWhere(
      (transaction) => transaction.id == transactionId,
    );

    targetTransaction.description = newDescription;
    targetTransaction.amount = newAmount;
    targetTransaction.categoryId = newCategoryId;
    targetTransaction.date = newDate;

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
