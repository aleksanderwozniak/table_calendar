// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, DateTime day)? dowBuilder;
  final Widget Function(BuildContext context, DateTime day) dayBuilder;
  final List<DateTime> visibleDays;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final bool dowVisible;
  final bool isLunarCalendar;

  const CalendarPage({
    Key? key,
    this.isLunarCalendar = false,
    required this.visibleDays,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.dowVisible = true,
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
    var list = [
      DateTime(2022, 6, 6),
      DateTime(2022, 6, 7),
      DateTime(2022, 6, 8),
      DateTime(2022, 6, 9),
      DateTime(2022, 6, 10),
      DateTime(2022, 6, 11),
      DateTime(2022, 6, 12),
    ];
    return TableRow(
      decoration: dowDecoration,
      children: List.generate(
        7,
        (index) {
          return dowBuilder!(context,
              isLunarCalendar == true ? list[index] : visibleDays[index]);
        },
      ).toList(),
    );
  }

  List<TableRow> _buildCalendarDays(BuildContext context) {
    final rowAmount = (visibleDays.length) ~/ 7;
    return List.generate(rowAmount, (index) => index * 7)
        .map((index) => TableRow(
              decoration: rowDecoration,
              children: List.generate(
                7,
                (id) => dayBuilder(context, visibleDays[index + id]),
              ),
            ))
        .toList();
  }
}
