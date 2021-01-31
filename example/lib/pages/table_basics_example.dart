// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TableBasicsExample extends StatefulWidget {
  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar - Basics'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2021, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.
          return _selectedDay == day;
        },
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) {
          if (_selectedDay != selectedDay) {
            // Call `setState()` to update the selected day
            setState(() {
              _selectedDay = selectedDay;
            });
          }

          // Don't call `setState()` just to update the focused day
          _focusedDay = focusedDay;
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` to update calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // Don't call `setState()` just to update the focused day
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
