import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';
import 'screens/home_screen.dart';

enum AppThemeColor {
  teal('Teal', Colors.teal),
  purple('Purple', Colors.purple),
  orange('Orange', Colors.orange),
  indigo('Indigo', Colors.indigo),
  lime('Lime', Colors.lime),
  green('Green', Colors.green);

  final String label;
  final Color seedColor;

  const AppThemeColor(this.label, this.seedColor);
}

class InheritedThemeData extends InheritedWidget {
  final _MyAppState state;

  const InheritedThemeData({
    super.key,
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedThemeData oldWidget) => true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedThemeData>();
    assert(
      result != null,
      'No InheritedThemeData found in the current widget context',
    );
    return result!.state;
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  AppThemeColor _activeColor = AppThemeColor.teal;
  late final BudgetProvider _budgetProvider;

  ThemeMode get themeMode => _themeMode;

  AppThemeColor get activeColor => _activeColor;

  @override
  void initState() {
    super.initState();
    _budgetProvider = BudgetProvider();
  }

  @override
  void dispose() {
    _budgetProvider.dispose();
    super.dispose();
  }

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void changeColorTheme(AppThemeColor color) {
    setState(() {
      _activeColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedThemeData(
      state: this,
      child: BudgetState(
        notifier: _budgetProvider,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Personal Budget Tracker',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _activeColor.seedColor,
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _activeColor.seedColor,
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: _themeMode,
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
