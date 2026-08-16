import 'package:flutter/material.dart';
import '../utils/months.dart';

class MonthNavigationHeader extends StatelessWidget {
  final int year;
  final int month;
  final bool isClosed;
  final bool isTooOld;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthNavigationHeader({
    super.key,
    required this.year,
    required this.month,
    required this.isClosed,
    required this.isTooOld,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 24),
          tooltip: 'Previous Month',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onPreviousMonth,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${monthName(month)} $year', textAlign: TextAlign.center),
              if (isTooOld)
                Text(
                  '(Too Old)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (isClosed && !isTooOld)
                Text(
                  '(Closed)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 24),
          tooltip: 'Next Month',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}
