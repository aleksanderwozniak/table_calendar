//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

library table_calendar;

import 'package:flutter/material.dart';

import 'src/calendar_logic.dart';
import 'src/cell_widget.dart';

typedef void OnDaySelected(DateTime day);

enum CalendarFormat { month, week }

class TableCalendar extends StatefulWidget {
  final Map<DateTime, List> events;
  final OnDaySelected onDaySelected;
  final Color selectedColor;
  final Color todayColor;
  final Color eventMarkerColor;
  final Color iconColor;
  final CalendarFormat calendarFormat;
  final TextStyle formatToggleTextStyle;
  final Decoration formatToggleDecoration;
  final EdgeInsets formatTogglePadding;
  final bool formatToggleVisible;
  final bool centerHeaderTitle;

  TableCalendar({
    Key key,
    this.events = const {},
    this.onDaySelected,
    this.selectedColor,
    this.todayColor,
    this.eventMarkerColor,
    this.iconColor = Colors.black,
    this.calendarFormat = CalendarFormat.month,
    this.formatToggleTextStyle,
    this.formatToggleDecoration,
    this.formatTogglePadding,
    this.formatToggleVisible = false,
    this.centerHeaderTitle = true,
  }) : super(key: key);

  @override
  _TableCalendarState createState() {
    return new _TableCalendarState();
  }
}

class _TableCalendarState extends State<TableCalendar> {
  CalendarLogic _calendarLogic;

  @override
  void initState() {
    super.initState();
    _calendarLogic = CalendarLogic(widget.calendarFormat);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 6.0),
        _buildHeader(),
        const SizedBox(height: 10.0),
        _buildTable(),
        const SizedBox(height: 4.0),
      ],
    );
  }

  Widget _buildHeader() {
    final headerStyle = TextStyle().copyWith(fontSize: 17.0);
    final children = [
      const SizedBox(width: 20.0),
      IconButton(
        icon: Icon(Icons.chevron_left, color: widget.iconColor),
        onPressed: () {
          setState(() {
            if (_calendarLogic.calendarFormat == CalendarFormat.week) {
              _calendarLogic.selectPreviousWeek();
            } else {
              _calendarLogic.selectPreviousMonth();
            }
          });
        },
      ),
      const SizedBox(width: 12.0),
      Expanded(
        child: Text(
          _calendarLogic.headerText,
          style: headerStyle,
          textAlign: widget.centerHeaderTitle ? TextAlign.center : TextAlign.start,
        ),
      ),
      const SizedBox(width: 12.0),
      IconButton(
        icon: Icon(Icons.chevron_right, color: widget.iconColor),
        onPressed: () {
          setState(() {
            if (_calendarLogic.calendarFormat == CalendarFormat.week) {
              _calendarLogic.selectNextWeek();
            } else {
              _calendarLogic.selectNextMonth();
            }
          });
        },
      ),
      const SizedBox(width: 20.0),
    ];

    if (widget.formatToggleVisible) {
      children.insert(4, _buildHeaderToggle());
    }

    return Row(children: children);
  }

  Widget _buildHeaderToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _calendarLogic.toggleCalendarFormat();
        });
      },
      child: Container(
        decoration: widget.formatToggleDecoration ??
            BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12.0),
            ),
        padding: widget.formatTogglePadding ?? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Text(
          _calendarLogic.headerToggleText,
          style: widget.formatToggleTextStyle ?? TextStyle(),
        ),
      ),
    );
  }

  Widget _buildTable() {
    final children = <TableRow>[];
    final daysInWeek = 7;

    children.add(_buildDaysOfWeek());

    if (_calendarLogic.calendarFormat == CalendarFormat.week) {
      children.add(_buildTableRow(_calendarLogic.visibleWeek.toList()));
    } else {
      int x = 0;
      while (x < _calendarLogic.visibleMonth.length) {
        children.add(_buildTableRow(_calendarLogic.visibleMonth.skip(x).take(daysInWeek).toList()));
        x += daysInWeek;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Table(
        // Makes this Table fill its parent horizontally
        defaultColumnWidth: FractionColumnWidth(1.0 / daysInWeek),
        children: children,
      ),
    );
  }

  TableRow _buildDaysOfWeek() {
    final daysOfWeek = _calendarLogic.daysOfWeek;
    final children = <Widget>[];

    final weekdayStyle = TextStyle().copyWith(color: Colors.grey[700], fontSize: 15.0);
    final weekendStyle = TextStyle().copyWith(color: Colors.red[500], fontSize: 15.0);

    children.add(Center(child: Text(daysOfWeek.first, style: weekendStyle)));
    children.addAll(
      daysOfWeek.sublist(1, daysOfWeek.length - 1).map(
            (text) => Center(
                  child: Text(text, style: weekdayStyle),
                ),
          ),
    );
    children.add(Center(child: Text(daysOfWeek.last, style: weekendStyle)));

    return TableRow(children: children);
  }

  TableRow _buildTableRow(List<DateTime> days) {
    return TableRow(children: days.map((date) => _buildTableCell(date)).toList());
  }

  // TableCell will have equal width and height
  Widget _buildTableCell(DateTime date) {
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxWidth,
              minHeight: constraints.maxWidth,
            ),
            child: _buildCellContent(date),
          ),
    );
  }

  Widget _buildCellContent(DateTime date) {
    Widget content = CellWidget(
      text: '${date.day}',
      isSelected: _calendarLogic.isSelected(date),
      isToday: _calendarLogic.isToday(date),
      isWeekend: _calendarLogic.isWeekend(date),
      isOutsideMonth: _calendarLogic.isExtraDay(date),
      selectedColor: widget.selectedColor,
      todayColor: widget.todayColor,
    );

    if (widget.events.containsKey(date) && widget.events[date].isNotEmpty) {
      final children = <Widget>[content];
      final maxMarkers = 4;

      children.add(
        Positioned(
          bottom: 5.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.events[date].take(maxMarkers).map((_) => _buildMarker()).toList(),
          ),
        ),
      );

      content = Stack(
        alignment: Alignment.bottomCenter,
        children: children,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _calendarLogic.selectedDate = date;
        });

        widget.onDaySelected(date);
      },
      child: content,
    );
  }

  Widget _buildMarker() {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 0.3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.eventMarkerColor ?? Colors.blueGrey[900],
      ),
    );
  }
}
