// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PersistenceExamplePage extends StatefulWidget {
  @override
  _PersistenceExamplePageState createState() => _PersistenceExamplePageState();
}

class _PersistenceExamplePageState extends State<PersistenceExamplePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isVisible = true;
  DateTime _selectedDay;
  DateTime _focusedDay;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(title: Text('TableCalendar-Persistence')),
      body: Column(
        children: [
          Visibility(
            visible: _isVisible,
            child: TableCalendar(
              rowHeight: orientation == Orientation.portrait ? 52.0 : 30.0,
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onDaySelected: (day, _, __) {
                if (_selectedDay != day) {
                  // Note that this does not rebuild the widget
                  // Values are updated only in case widget gets rebuilt in future
                  // (for example by toggling [_isVisible])
                  _selectedDay = day;
                  _focusedDay = day;
                }
              },
              onPageChanged: (focusedDay, _, __) {
                if (_focusedDay != focusedDay) {
                  _focusedDay = focusedDay;
                }
              },
              onFormatChanged: (format, _, __) {
                if (_calendarFormat != format) {
                  _calendarFormat = format;
                }
              },
            ),
          ),
          Spacer(),
          Center(
            child: RaisedButton(
              child: Text('Toggle visibility'),
              onPressed: () {
                setState(() {
                  _isVisible = !_isVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
