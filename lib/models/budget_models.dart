class Category {
  final String id;
  String name;

  Category({required this.id, required this.name});

  void rename(String newName) {
    this.name = newName;
  }
}
// TODO: Add isConfirmed bool to Transaction (true = real expense, false = predicted).
class Transaction {
  String id;
  String description;
  double amount;
  DateTime date;
  String categoryId;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
  });
}

class Income {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  const Income({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}

enum FundPool { unallocatedFunds, savings, categoryBudget }

class Transfer {
  final String id;
  final double amount;
  final DateTime date;
  final FundPool from;
  final FundPool to;

  // Only when from/to is categoryBudget:
  final String? categoryId;
  final int? year;
  final int? month;

  const Transfer({
    required this.id,
    required this.amount,
    required this.date,
    required this.from,
    required this.to,
    this.categoryId,
    this.year,
    this.month,
  });
}
