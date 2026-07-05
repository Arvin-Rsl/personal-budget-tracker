import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';

// specialized widget that holds our BudgetProvider and updates its children
class BudgetState extends InheritedNotifier<BudgetProvider> {
  const BudgetState({
    super.key,
    required BudgetProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  // static look-up tool allowing child widgets to instantly find this state
  static BudgetProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<BudgetState>();
    assert(
      result != null,
      'No BudgetState found in the current widget context',
    );
    return result!.notifier!;
  }
}
