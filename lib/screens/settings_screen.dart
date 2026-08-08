import 'package:flutter/material.dart';
import '../widgets/theme_settings_section.dart';
import '../widgets/date_format_settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ThemeSettingsSection(),
          SizedBox(height: 16),
          DateFormatSettingsSection(),
        ],
      ),
    );
  }
}
