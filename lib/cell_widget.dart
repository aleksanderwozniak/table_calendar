import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool isOutsideMonth;

  const CellWidget({
    Key key,
    @required this.text,
    this.isSelected = false,
    this.isToday = false,
    this.isWeekend = false,
    this.isOutsideMonth = false,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        color: Colors.indigo[400],
      );
    } else if (isToday) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.indigo[200],
      );
    } else {
      return BoxDecoration();
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
