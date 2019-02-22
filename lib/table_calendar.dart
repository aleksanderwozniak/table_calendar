library table_calendar;

import 'package:flutter/material.dart';
import 'package:table_calendar/calendar_logic.dart';
import 'package:table_calendar/cell_widget.dart';

class TableCalendar extends StatefulWidget {
  final Map<DateTime, List> events;

  TableCalendar({
    Key key,
    this.events = const {},
  }) : super(key: key);

  @override
  TableCalendarState createState() {
    return new TableCalendarState();
  }
}

class TableCalendarState extends State<TableCalendar> {
  CalendarLogic _calendarLogic;

  @override
  void initState() {
    super.initState();
    _calendarLogic = CalendarLogic();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 12.0),
        _buildHeader(),
        const SizedBox(height: 12.0),
        _buildTable(),
        const SizedBox(height: 12.0),
      ],
    );
  }

  Widget _buildHeader() {
    final headerStyle = TextStyle().copyWith(fontSize: 17.0);

    return Row(
      children: <Widget>[
        const SizedBox(width: 20.0),
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _calendarLogic.selectPreviousMonth();
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              _calendarLogic.headerText,
              style: headerStyle,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _calendarLogic.selectNextMonth();
            });
          },
        ),
        const SizedBox(width: 20.0),
      ],
    );
  }

  Widget _buildTable() {
    final children = <TableRow>[];
    final daysInWeek = 7;

    children.add(_buildDaysOfWeek());

    int x = 0;
    while (x < _calendarLogic.visibleMonth.length) {
      children.add(_buildTableRow(_calendarLogic.visibleMonth.skip(x).take(daysInWeek).toList()));
      x += daysInWeek;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
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
        color: Colors.blueGrey[900],
      ),
    );
  }
}
