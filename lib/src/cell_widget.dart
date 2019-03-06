//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool isOutsideMonth;
  final Color selectedColor;
  final Color todayColor;

  const CellWidget({
    Key key,
    @required this.text,
    this.isSelected = false,
    this.isToday = false,
    this.isWeekend = false,
    this.isOutsideMonth = false,
    this.selectedColor,
    this.todayColor,
  })  : assert(text != null),
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
        color: selectedColor ?? Colors.indigo[400],
      );
    } else if (isToday) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: todayColor ?? Colors.indigo[200],
      );
    } else {
      return BoxDecoration(shape: BoxShape.circle);
    }
  }

  TextStyle _buildCellTextStyle() {
    final highlightStyle = TextStyle().copyWith(color: Colors.grey[50], fontSize: 16.0);
    final outsideStyle = TextStyle().copyWith(color: Colors.grey[500]);
    final weekendStyle = TextStyle().copyWith(color: Colors.red[500]);
    final outsideWeekendStyle = TextStyle().copyWith(color: Colors.red[200]);

    if (isSelected || isToday) {
      return highlightStyle;
    }

    if (isWeekend && isOutsideMonth) {
      return outsideWeekendStyle;
    } else if (isWeekend) {
      return weekendStyle;
    } else if (isOutsideMonth) {
      return outsideStyle;
    } else {
      return TextStyle();
    }
  }
}
