import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/date_format_option.dart';

// TODO: move the theme changing code to here instead of App.dart
// TODO: Add DateFormatOption enum + a manual formatDate() helper
// (no intl package - keep dependency-free, matches existing manual
// date formatting style in TransactionTile/TransactionForm)

// TODO: Add dateFormat state to _MyAppState, persisted like theme

// TODO: Add ThemeMode.system option to the theme picker

// TODO: Build SettingsScreen containing ThemeSettingsSection and
// DateFormatSettingsSection as separate widgets

// TODO: Wire Settings into the drawer

// TODO: finalize color choices (maybe check the UX Book on Colors too)

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
  DateFormatOption _dateFormat = DateFormatOption.isoStyle;
  late final BudgetProvider _budgetProvider;

  ThemeMode get themeMode => _themeMode;

  AppThemeColor get activeColor => _activeColor;

  DateFormatOption get dateFormat => _dateFormat;

  @override
  void initState() {
    super.initState();
    _budgetProvider = BudgetProvider();
    _loadThemePreferences();
  }

  @override
  void dispose() {
    _budgetProvider.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedThemeMode = prefs.getString('themeMode');
    final String? savedColor = prefs.getString('activeColor');
    final String? savedDateFormat = prefs.getString('dateFormat');

    setState(() {
      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values.byName(savedThemeMode);
      }
      if (savedColor != null) {
        _activeColor = AppThemeColor.values.byName(savedColor);
      }
      if (savedDateFormat != null) {
        _dateFormat = DateFormatOption.values.byName(savedDateFormat);
      }
    });
  }

  Future<void> _savePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _savePreference('themeMode', mode.name);
  }

  void changeColorTheme(AppThemeColor color) {
    setState(() {
      _activeColor = color;
    });
    _savePreference('activeColor', color.name);
  }

  void changeDateFormat(DateFormatOption option) {
    setState(() {
      _dateFormat = option;
    });
    _savePreference('dateFormat', option.name);
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
