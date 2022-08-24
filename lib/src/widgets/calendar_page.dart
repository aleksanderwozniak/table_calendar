// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, DateTime day)? dowBuilder;
  final Widget Function(BuildContext context, DateTime day) dayBuilder;
  final Widget Function(BuildContext context, DateTime day)? weekNumberBuilder;
  final List<DateTime> visibleDays;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final bool dowVisible;
  final bool weekNumberVisible;
  final double? dowHeight;
  final int displayDaysNumber;

  const CalendarPage({
    Key? key,
    required this.visibleDays,
    this.dowBuilder,
    required this.dayBuilder,
    this.weekNumberBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.dowVisible = true,
    this.weekNumberVisible = false,
    this.dowHeight,
    this.displayDaysNumber = 7,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(!weekNumberVisible || weekNumberBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (weekNumberVisible) _buildWeekNumbers(context),
        Expanded(
          child: Table(
            border: tableBorder,
            children: [
              if (dowVisible) _buildDaysOfWeek(context),
              ..._buildCalendarDays(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNumbers(BuildContext context) {
    final rowAmount = visibleDays.length ~/ 7;
    return Column(
      children: [
        if (dowVisible) SizedBox(height: dowHeight ?? 0),
        ...List.generate(rowAmount, (index) => index * 7)
            .map((index) => Expanded(child: weekNumberBuilder!(context, visibleDays[index])))
            .toList()
      ],
    );
  }

  TableRow _buildDaysOfWeek(BuildContext context) {
    return TableRow(
      decoration: dowDecoration,
      children: List.generate(
        displayDaysNumber,
        (index) => dowBuilder!(context, visibleDays[index]),
      ).toList(),
    );
  }

  List<TableRow> _buildCalendarDays(BuildContext context) {
    final rowAmount = visibleDays.length ~/ 7;

    return List.generate(rowAmount, (index) => index * 7)
        .map((index) => TableRow(
              decoration: rowDecoration,
              children: List.generate(
                displayDaysNumber,
                (id) => dayBuilder(context, visibleDays[index + id]),
              ),
            ))
        .toList();
  }
}
