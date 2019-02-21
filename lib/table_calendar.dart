library table_calendar;

import 'package:flutter/material.dart';
import 'package:table_calendar/calendar_logic.dart';

class TableCalendar extends StatefulWidget {
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

    int x = 0;
    while (x < _calendarLogic.visibleMonth.length) {
      children.add(_buildTableRow(_calendarLogic.visibleMonth.skip(x).take(7).toList()));
      x += 7;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Table(
        border: TableBorder.all(), // TODO
        defaultColumnWidth: FractionColumnWidth(1.0 / 7.0),
        children: children,
      ),
    );
  }

  TableRow _buildTableRow(List<DateTime> days) {
    return TableRow(
      children: days
          .map(
            (date) => LayoutBuilder(
                  builder: (context, constraints) => ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxWidth,
                          minHeight: constraints.maxWidth,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue, // TODO
                          ),
                          margin: const EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          child: Text('${date.day}'),
                        ),
                      ),
                ),
          )
          .toList(),
    );
  }
}
