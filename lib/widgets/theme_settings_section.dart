import 'package:flutter/material.dart';
import '../app.dart';

class ThemeSettingsSection extends StatelessWidget {
  const ThemeSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = MyApp.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Display Mode',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('Auto'),
                ),
              ],
              selected: {themeState.themeMode},
              onSelectionChanged: (Set<ThemeMode> selection) {
                themeState.changeThemeMode(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Accent Color Palette',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AppThemeColor>(
              initialValue: themeState.activeColor,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: AppThemeColor.values.map((AppThemeColor color) {
                return DropdownMenuItem(
                  value: color,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color.seedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(color.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (AppThemeColor? newColor) {
                if (newColor != null) {
                  themeState.changeColorTheme(newColor);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
