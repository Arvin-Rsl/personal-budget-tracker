import 'package:flutter/material.dart';
import '../app.dart';
import '../utils/date_format_option.dart';

class DateFormatSettingsSection extends StatelessWidget {
  const DateFormatSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = MyApp.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date Format', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<DateFormatOption>(
              initialValue: themeState.dateFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: DateFormatOption.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(labelFor(option)),
                );
              }).toList(),
              onChanged: (DateFormatOption? newOption) {
                if (newOption != null) {
                  themeState.changeDateFormat(newOption);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
