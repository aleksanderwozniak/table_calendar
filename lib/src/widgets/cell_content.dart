// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

part of table_calendar;

class _CellContent extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final bool isTodayHighlighted;
  final bool isToday;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isOutside;
  final bool isDisabled;
  final bool isHoliday;
  final bool isWeekend;
  final CalendarStyle calendarStyle;
  final CalendarBuilders calendarBuilders;

  const _CellContent({
    Key key,
    @required this.day,
    @required this.focusedDay,
    @required this.calendarStyle,
    @required this.calendarBuilders,
    @required this.isTodayHighlighted,
    @required this.isToday,
    @required this.isSelected,
    @required this.isRangeStart,
    @required this.isRangeEnd,
    @required this.isWithinRange,
    @required this.isOutside,
    @required this.isDisabled,
    @required this.isHoliday,
    @required this.isWeekend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cell =
        calendarBuilders.prioritizedBuilder?.call(context, day, focusedDay);

    if (cell != null) {
      return cell;
    }

    final text = '${day.day}';
    final margin = calendarStyle.cellMargin;

    if (isDisabled) {
      cell = calendarBuilders.disabledBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.disabledTextStyle,
            decoration: calendarStyle.disabledDecoration,
            margin: margin,
          );
    } else if (isSelected) {
      cell = calendarBuilders.selectedBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.selectedTextStyle,
            decoration: calendarStyle.selectedDecoration,
            margin: margin,
          );
    } else if (isRangeStart) {
      cell =
          calendarBuilders.rangeStartBuilder?.call(context, day, focusedDay) ??
              _DefaultCellWidget(
                text: text,
                textStyle: calendarStyle.rangeStartTextStyle,
                decoration: calendarStyle.rangeStartDecoration,
                margin: margin,
              );
    } else if (isRangeEnd) {
      cell = calendarBuilders.rangeEndBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.rangeEndTextStyle,
            decoration: calendarStyle.rangeEndDecoration,
            margin: margin,
          );
    } else if (isToday && isTodayHighlighted) {
      cell = calendarBuilders.todayBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.todayTextStyle,
            decoration: calendarStyle.todayDecoration,
            margin: margin,
          );
    } else if (isHoliday) {
      cell = calendarBuilders.holidayBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.holidayTextStyle,
            decoration: calendarStyle.holidayDecoration,
            margin: margin,
          );
    } else if (isWithinRange) {
      cell =
          calendarBuilders.withinRangeBuilder?.call(context, day, focusedDay) ??
              _DefaultCellWidget(
                text: text,
                textStyle: calendarStyle.withinRangeTextStyle,
                decoration: calendarStyle.withinRangeDecoration,
                margin: margin,
              );
    } else if (isOutside) {
      cell = calendarBuilders.outsideBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.outsideTextStyle,
            decoration: calendarStyle.outsideDecoration,
            margin: margin,
          );
    } else if (isWeekend) {
      cell = calendarBuilders.weekendBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.weekendTextStyle,
            decoration: calendarStyle.weekendDecoration,
            margin: margin,
          );
    } else {
      cell = calendarBuilders.defaultBuilder?.call(context, day, focusedDay) ??
          _DefaultCellWidget(
            text: text,
            textStyle: calendarStyle.defaultTextStyle,
            decoration: calendarStyle.defaultDecoration,
            margin: margin,
          );
    }

    return cell;
  }
}

class _DefaultCellWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;

  const _DefaultCellWidget({
    Key key,
    @required this.text,
    @required this.textStyle,
    @required this.decoration,
    @required this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: margin,
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(text, style: textStyle),
    );
  }
}
