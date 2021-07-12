import 'package:flutter/material.dart';
import 'package:table_calendar/src/customization/header_style.dart';

import '../shared/utils.dart' show CalendarFormat, DayBuilder;

import 'package:intl/intl.dart';

class CalendarTitle extends StatelessWidget {
  final DayBuilder? headerTitleBuilder;
  final DateTime focusedMonth;
  final VoidCallback onHeaderTap;
  final VoidCallback onHeaderLongPress;
  final HeaderStyle headerStyle;
  final dynamic locale;

  const CalendarTitle({
    Key? key,
    this.locale,
    required this.focusedMonth,
    required this.headerStyle,
    required this.onHeaderTap,
    required this.onHeaderLongPress,
    this.headerTitleBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = headerStyle.titleTextFormatter?.call(focusedMonth, locale) ??
        DateFormat.yMMMM(locale).format(focusedMonth);

    return Expanded(
      child: headerTitleBuilder?.call(context, focusedMonth) ??
          GestureDetector(
            onTap: onHeaderTap,
            onLongPress: onHeaderLongPress,
            child: Text(
              text,
              style: headerStyle.titleTextStyle,
              textAlign: headerStyle.titleCentered
                  ? TextAlign.center
                  : TextAlign.start,
            ),
          ),
    );
  }
}
