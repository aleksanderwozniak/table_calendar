// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, DateTime day)? dowBuilder;
  final Widget Function(BuildContext context, DateTime day) dayBuilder;
  final List<DateTime> visibleDays;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final bool dowVisible;
  final bool withWeekNum;

  const CalendarPage({
    Key? key,
    required this.visibleDays,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.dowVisible = true,
    this.withWeekNum = false,
  })  : assert(!dowVisible || dowBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (withWeekNum){
      final tempRowAmount = visibleDays.length ~/ 7;
      for ( var i = 0; i < tempRowAmount;i++)
      {
        visibleDays.insert(i * 8, DateTime.utc(1940, 1, i + 1));
      }
    }

    return Table(
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
        withWeekNum? 8 : 7,
            (index) => dowBuilder!(context, visibleDays[index]),
      ).toList(),
    );
  }

  List<TableRow> _buildCalendarDays(BuildContext context) {

    final rowAmount = visibleDays.length ~/ 8;


    return List.generate(rowAmount, (index) => index * 8)
        .map((index) => TableRow(
      decoration: rowDecoration,
      children: List.generate(
        withWeekNum? 8 : 7,
            (id) => dayBuilder(context, visibleDays[index + id]),
      ),
    ))
        .toList();
  }
}
