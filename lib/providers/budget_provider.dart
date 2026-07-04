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
    // TODO: calculate total spent for a specific category
    return 0;
  }

  double getRemainingBudget(Category category) {
    return category.allocatedBudget - getAmountSpentForCategory(category.id);
  }
}
