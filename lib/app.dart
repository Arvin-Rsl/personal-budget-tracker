import 'package:flutter/material.dart';
import 'package:personal_budget_app/providers/budget_provider.dart';
import 'budget_state.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/date_format_option.dart';

// TODO: finalize color choices and name artistically!

enum AppThemeColor {
  teal('Teal', Colors.teal),
  cyan('Cyan', Colors.cyan),
  lightBLue('Light Blue', Colors.lightBlue),
  blue('Blue', Colors.blue),
  blueGrey('Blue Grey', Colors.blueGrey),
  indigo('Indigo', Colors.indigo),
  deepPurple('Deep Purple', Colors.deepPurple),
  purple('Purple', Colors.purple),
  pink('Pink', Colors.pink),
  red('Red', Colors.red),
  brown('Brown', Colors.brown),
  deepOrange('Deep Orange', Colors.deepOrange),
  orange('Orange', Colors.orange),
  amber('Amber', Colors.amber),
  lime('Lime', Colors.lime),
  lightGreen('Light Green', Colors.lightGreen),
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
