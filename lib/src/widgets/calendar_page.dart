// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import 'package:table_calendar/src/shared/utils.dart';

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, DateTime day)? dowBuilder;
  final Widget Function(BuildContext context, DateTime day) dayBuilder;
  final List<DateTime> visibleDays;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final bool dowVisible;
  final CalendarFormat calendarFormat;

  const CalendarPage({
    Key? key,
    required this.visibleDays,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.dowVisible = true,
    required this.calendarFormat,
  })  : assert(!dowVisible || dowBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: tableBorder,
      children: [
        if (dowVisible) _buildDaysOfWeek(context),
        ..._buildCalendarDays(context),
      ],
    );
  }

  TableRow _buildDaysOfWeek(BuildContext context) {
    return TableRow(
      decoration: dowDecoration,
      children: List.generate(
        _rowSize,
        (index) => dowBuilder!(context, visibleDays[index]),
      ).toList(),
    );
  }

  int get _rowSize => calendarFormat == CalendarFormat.threeDays ? 3 : 7;

  List<TableRow> _buildCalendarDays(BuildContext context) {
    final rowAmount = visibleDays.length ~/ _rowSize;

    return List.generate(rowAmount, (index) => index * _rowSize)
        .map((index) => TableRow(
              decoration: rowDecoration,
              children: List.generate(
                _rowSize,
                (id) => dayBuilder(context, visibleDays[index + id]),
              ),
            ))
        .toList();
  }
}
