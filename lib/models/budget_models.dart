class Category {
  final String id;
  final String name;
  final double allocatedBudget;

  Category({
    required this.id,
    required this.name,
    required this.allocatedBudget,
  });
}

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
