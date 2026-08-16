import 'package:flutter/material.dart';
import '../utils/months.dart';

class MonthCloseBanner extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onWrapUp;

  const MonthCloseBanner({
    super.key,
    required this.year,
    required this.month,
    required this.onWrapUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.event_busy),
        title: Text('${monthName(month)} $year has ended'),
        subtitle: const Text(
          'Wrap up this month? Unspent budget moves to Unallocated Funds.',
        ),
        trailing: FilledButton(
          onPressed: onWrapUp,
          child: const Text('Wrap up'),
        ),
      ),
    );
  }
}
