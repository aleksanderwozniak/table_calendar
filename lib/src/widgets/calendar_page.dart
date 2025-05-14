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
  final EdgeInsets? tablePadding;
  final bool dowVisible;
  final bool weekNumberVisible;
  final double? dowHeight;
  final int daysInWeek;

  const CalendarPage({
    required this.visibleDays,
    required this.dayBuilder,
    this.dowBuilder,
    this.weekNumberBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.tablePadding,
    this.dowVisible = true,
    this.weekNumberVisible = false,
    this.dowHeight,
    this.daysInWeek = DateTime.daysPerWeek,
    super.key,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(!weekNumberVisible || weekNumberBuilder != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: tablePadding ?? EdgeInsets.zero,
      child: Row(
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
      ),
    );
  }

  Widget _buildWeekNumbers(BuildContext context) {
    final rowAmount = visibleDays.length ~/ daysInWeek;

    return Column(
      children: [
        if (dowVisible) SizedBox(height: dowHeight ?? 0),
        ...List.generate(
          rowAmount,
          (index) => Expanded(
            child: weekNumberBuilder!(context, visibleDays[index * daysInWeek]),
          ),
        ),
      ],
    );
  }

  TableRow _buildDaysOfWeek(BuildContext context) {
    return TableRow(
      decoration: dowDecoration,
      children: List.generate(
        daysInWeek,
        (index) => dowBuilder!(context, visibleDays[index]),
      ),
    );
  }

  List<TableRow> _buildCalendarDays(BuildContext context) {
    final rowAmount = visibleDays.length ~/ daysInWeek;

    return List.generate(
      rowAmount,
      (index) => TableRow(
        decoration: rowDecoration,
        children: List.generate(
          daysInWeek,
          (id) => dayBuilder(context, visibleDays[index * daysInWeek + id]),
        ),
      ),
    );
  }
}
