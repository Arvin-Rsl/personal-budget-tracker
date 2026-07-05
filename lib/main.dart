import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BudgetState(
      notifier: BudgetProvider(),
      child: MaterialApp(
        title: 'Personal Budget Tracker',
        debugShowCheckedModeBanner: false, // hide the red development banner
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Extract budget state provider data and layout the scannable scaffold dashboard
    return const Scaffold(body: Center(child: Text('Dashboard Stub')));
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  // TODO: Define Input controllers and state properties for category selection

  @override
  Widget build(BuildContext context) {
    // TODO: Build custom input fields and submit actions inside form sheet view
    return const SizedBox.shrink();
  }
}
