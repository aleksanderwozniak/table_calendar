// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: avoid_redundant_argument_values
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';

class TableWeekNumbersExample extends StatefulWidget {
  const TableWeekNumbersExample({Key? key}) : super(key: key);

  @override
  _TableWeekNumbersExampleState createState() => _TableWeekNumbersExampleState();
}

class _TableWeekNumbersExampleState extends State<TableWeekNumbersExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TableCalendar - Week numbers'),
      ),
      body: TableCalendar(
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
        calendarStyle: const CalendarStyle(
          /// Override week numbers textstyle here, e.g
          weekNumberTextStyle: TextStyle(
            fontSize: 12,
            color: Color(0xFFBFBFBF),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          /// Override week numbers builder here, e.g.
          weekNumberBuilder: (context, weekNumber) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  weekNumber.toString(),
                  /// This will override calendarStyle -> weekNumberTextStyle.
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBFBFBF),
                  ),
                ),
              ),
            );
          },
        ),
        startingDayOfWeek: StartingDayOfWeek.monday,
        /// Show week numbers
        weekNumbersVisible: true,
      ),
    );
  }
}
