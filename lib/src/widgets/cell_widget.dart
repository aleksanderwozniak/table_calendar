//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';

import '../customization/calendar_style.dart';

class CellWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool isOutsideMonth;
  final CalendarStyle calendarStyle;

  const CellWidget({
    Key key,
    @required this.text,
    this.isSelected = false,
    this.isToday = false,
    this.isWeekend = false,
    this.isOutsideMonth = false,
    @required this.calendarStyle,
  })  : assert(text != null),
        assert(calendarStyle != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: _buildCellDecoration(),
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style: _buildCellTextStyle(),
      ),
    );
  }

  Decoration _buildCellDecoration() {
    if (isSelected) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: calendarStyle.selectedColor,
      );
    } else if (isToday) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: calendarStyle.todayColor,
      );
    } else {
      return BoxDecoration(shape: BoxShape.circle);
    }
  }

  TextStyle _buildCellTextStyle() {
    if (isSelected) {
      return calendarStyle.selectedStyle;
    } else if (isToday) {
      return calendarStyle.todayStyle;
    } else if (isOutsideMonth && isWeekend) {
      return calendarStyle.outsideWeekendStyle;
    } else if (isOutsideMonth) {
      return calendarStyle.outsideStyle;
    } else if (isWeekend) {
      return calendarStyle.weekendStyle;
    } else {
      return calendarStyle.weekdayStyle;
    }
  }
}
