import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:personal_budget_app/models/budget_models.dart';

class BudgetProvider extends ChangeNotifier {
  final List<Category> _categories = [
    Category(id: '1', name: 'Food, Groceries'),
    Category(id: '2', name: 'Student Fees'),
    Category(id: '3', name: 'Books, Educational Supplies'),
    Category(id: '4', name: 'Sports, Gym'),
    Category(id: '5', name: 'Clothing'),
    Category(id: '6', name: 'Personal, Toiletries, Household Supplies'),
    Category(id: '7', name: 'Transportation (Excluding U-Pass)'),
    Category(id: '8', name: 'Tech Services (Internet, Phone, etc.)'),
    Category(id: '9', name: 'Clubs, Recreation'),
    Category(id: '10', name: 'Having Fun, Social Activities'),
  ];
  List<Transaction> _transactions = [];
  List<Income> _incomes = [];
  List<Transfer> _transfers = [];

  List<Category> get categories => _categories;

  List<Transaction> get transactions => _transactions;

  List<Income> get incomes => _incomes;

  List<Transfer> get transfers => _transfers;

  BudgetProvider() {
    _loadData();
  }

  double getUnallocatedFundsBalance() {
    double balance = 0.0;

    for (Income income in _incomes) {
      balance += income.amount;
    }

    for (Transfer transfer in _transfers) {
      if (transfer.to == FundPool.unallocatedFunds) {
        balance += transfer.amount;
      }
      if (transfer.from == FundPool.unallocatedFunds) {
        balance -= transfer.amount;
      }
    }

    return balance;
  }

  double getSavingsBalance() {
    double balance = 0.0;

    for (Transfer transfer in _transfers) {
      if (transfer.to == FundPool.savings) {
        balance += transfer.amount;
      }
      if (transfer.from == FundPool.savings) {
        balance -= transfer.amount;
      }
    }

    return balance;
  }

  double getAllocatedBudgetForCategoryAndMonth(
    String categoryId,
    int year,
    int month,
  ) {
    double allocated = 0.0;

    for (Transfer transfer in _transfers) {
      if (transfer.to == FundPool.categoryBudget &&
          transfer.categoryId == categoryId &&
          transfer.year == year &&
          transfer.month == month) {
        allocated += transfer.amount;
      }
      if (transfer.from == FundPool.categoryBudget &&
          transfer.categoryId == categoryId &&
          transfer.year == year &&
          transfer.month == month) {
        allocated -= transfer.amount;
      }
    }

    return allocated;
  }

  double getTotalBudget(int year, int month) {
    double totalBudget = 0;
    for (Category category in categories) {
      totalBudget += getAllocatedBudgetForCategoryAndMonth(
        category.id,
        year,
        month,
      );
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
    return getTotalBudget(year, month) - getTotalSpentForMonth(year, month);
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

  /// Updates the properties of an existing transaction
  void editTransaction(
    String transactionId,
    String newDescription,
    double newAmount,
    String newCategoryId,
    DateTime newDate,
  ) {
    final targetIndex = _transactions.indexWhere(
      (transaction) => transaction.id == transactionId,
    );

    if (-1 == targetIndex) {
      debugPrint(
        "editTransaction: no transaction found with id $transactionId",
      );
      return;
    }

    final targetTransaction = _transactions[targetIndex];
    targetTransaction.description = newDescription;
    targetTransaction.amount = newAmount;
    targetTransaction.categoryId = newCategoryId;
    targetTransaction.date = newDate;

    _saveData();
    notifyListeners();
  }

  void addIncome(String description, double amount, DateTime date) {
    final newIncome = Income(
      id: DateTime.now().toString(),
      description: description,
      amount: amount,
      date: date,
    );

    _incomes.add(newIncome);
    _saveData();
    notifyListeners();
  }

  void addTransfer(
    double amount,
    DateTime date,
    FundPool from,
    FundPool to, {
    String? categoryId,
    int? year,
    int? month,
  }) {
    final newTransfer = Transfer(
      id: DateTime.now().toString(),
      amount: amount,
      date: date,
      from: from,
      to: to,
      categoryId: categoryId,
      year: year,
      month: month,
    );

    _transfers.add(newTransfer);
    _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    try {
      final file = await _getLocalStorageFile();

      final List<Map<String, dynamic>> transactionsData = _transactions
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

      final List<Map<String, dynamic>> incomesData = _incomes
          .map(
            (income) => {
              'id': income.id,
              'description': income.description,
              'amount': income.amount,
              'date': income.date.toIso8601String(),
            },
          )
          .toList();

      final List<Map<String, dynamic>> transfersData = _transfers
          .map(
            (transfer) => {
              'id': transfer.id,
              'amount': transfer.amount,
              'date': transfer.date.toIso8601String(),
              'from': transfer.from.name,
              'to': transfer.to.name,
              'categoryId': transfer.categoryId,
              'year': transfer.year,
              'month': transfer.month,
            },
          )
          .toList();

      final Map<String, dynamic> structuredData = {
        'transactions': transactionsData,
        'incomes': incomesData,
        'transfers': transfersData,
      };

      await file.writeAsString(jsonEncode(structuredData));
    } catch (error) {
      debugPrint("Failed to write budget data to disk: $error");
    }
  }

  Future<void> _loadData() async {
    try {
      final file = await _getLocalStorageFile();

      if (await file.exists()) {
        final String rawText = await file.readAsString();
        final Map<String, dynamic> decodedData = jsonDecode(rawText);

        final List<dynamic> transactionsData =
            decodedData['transactions'] ?? [];
        _transactions = transactionsData
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

        final List<dynamic> incomesData = decodedData['incomes'] ?? [];
        _incomes = incomesData
            .map(
              (item) => Income(
                id: item['id'],
                description: item['description'],
                amount: (item['amount'] as num).toDouble(),
                date: DateTime.parse(item['date']),
              ),
            )
            .toList();

        final List<dynamic> transfersData = decodedData['transfers'] ?? [];
        _transfers = transfersData
            .map(
              (item) => Transfer(
                id: item['id'],
                amount: (item['amount'] as num).toDouble(),
                date: DateTime.parse(item['date']),
                from: FundPool.values.byName(item['from']),
                to: FundPool.values.byName(item['to']),
                categoryId: item['categoryId'],
                year: item['year'],
                month: item['month'],
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

Future<File> _getLocalStorageFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/transactions_data.json');
}
