library table_calendar;

import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/calendar_logic.dart';

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
        const SizedBox(height: 16.0),
        _buildHeader(),
        const SizedBox(height: 16.0),
        _buildTable(),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildHeader() {
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
          child: Center(child: Text(_calendarLogic.headerText)),
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

  TableRow _buildTableRow(List<DateTime> days) {
    return TableRow(children: days.map((date) => _buildTableCell(date)).toList());
  }

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
    Widget content;

    if (Utils.isSameDay(date, _calendarLogic.selectedDate)) {
      content = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
        margin: const EdgeInsets.all(6.0),
        alignment: Alignment.center,
        child: Text('${date.day}'),
      );
    } else if (Utils.isSameDay(date, DateTime.now())) {
      content = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber[200],
        ),
        margin: const EdgeInsets.all(6.0),
        alignment: Alignment.center,
        child: Text('${date.day}'),
      );
    } else {
      content = Container(
        margin: const EdgeInsets.all(6.0),
        alignment: Alignment.center,
        child: Text('${date.day}'),
      );
    }

    if (widget.events.containsKey(date) && widget.events[date].isNotEmpty) {
      final children = <Widget>[content];
      final maxMarks = 4;

      children.add(
        Positioned(
          bottom: 5.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.events[date]
                .take(maxMarks)
                .map(
                  (_) => Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                )
                .toList(),
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
}
