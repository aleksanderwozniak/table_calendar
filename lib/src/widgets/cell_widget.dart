//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

class _CellWidget extends StatelessWidget {
  final String text;
  final bool isUnavailable;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool isOutsideMonth;
  final bool isHoliday;
  final bool isEventDay;
  final CalendarStyle calendarStyle;

  const _CellWidget({
    Key key,
    @required this.text,
    this.isUnavailable = false,
    this.isSelected = false,
    this.isToday = false,
    this.isWeekend = false,
    this.isOutsideMonth = false,
    this.isHoliday = false,
    this.isEventDay = false,
    @required this.calendarStyle,
  })  : assert(text != null),
        assert(calendarStyle != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: _buildCellDecoration(),
      margin: calendarStyle.cellMargin,
      alignment: Alignment.center,
      child: Text(
        text,
        style: _buildCellTextStyle(),
      ),
    );
  }

  Decoration _buildCellDecoration() {
    if (isSelected && calendarStyle.renderSelectedFirst && calendarStyle.highlightSelected) {
      return BoxDecoration(shape: BoxShape.circle, color: calendarStyle.selectedColor);
    } else if (isToday && calendarStyle.highlightToday) {
      return BoxDecoration(shape: BoxShape.circle, color: calendarStyle.todayColor);
    } else if (isSelected && calendarStyle.highlightSelected) {
      return BoxDecoration(shape: BoxShape.circle, color: calendarStyle.selectedColor);
    } else {
      return BoxDecoration(shape: BoxShape.circle);
    }
  }

  TextStyle _buildCellTextStyle() {
    if (isUnavailable) {
      return calendarStyle.unavailableStyle;
    } else if (isSelected && calendarStyle.renderSelectedFirst && calendarStyle.highlightSelected) {
      return calendarStyle.selectedStyle;
    } else if (isToday && calendarStyle.highlightToday) {
      return calendarStyle.todayStyle;
    } else if (isSelected && calendarStyle.highlightSelected) {
      return calendarStyle.selectedStyle;
    } else if (isOutsideMonth && isHoliday) {
      return calendarStyle.outsideHolidayStyle;
    } else if (isHoliday) {
      return calendarStyle.holidayStyle;
    } else if (isOutsideMonth && isWeekend) {
      return calendarStyle.outsideWeekendStyle;
    } else if (isOutsideMonth) {
      return calendarStyle.outsideStyle;
    } else if (isWeekend) {
      return calendarStyle.weekendStyle;
    } else if (isEventDay) {
      return calendarStyle.eventDayStyle;
    } else {
      return calendarStyle.weekdayStyle;
    }
  }
}
