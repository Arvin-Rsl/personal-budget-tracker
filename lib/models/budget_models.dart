// TODO: Add Income model - tracks money coming in, immutable ledger entry

// TODO: Add FundPool enum + Transfer model (tracks money movement between
// Unallocated Funds, Savings, and category/month budgets).
// corrections happen via new offsetting transfers, no edits.

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
