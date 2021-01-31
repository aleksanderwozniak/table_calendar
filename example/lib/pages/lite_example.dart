// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class LiteExample extends StatefulWidget {
  @override
  _LiteExampleState createState() => _LiteExampleState();
}

class _LiteExampleState extends State<LiteExample> {
  final _firstDay = DateTime.utc(2020, 10, 10);
  final _lastDay = DateTime.utc(2021, 3, 14);
  ValueNotifier<DateTime> _focusedDay;
  DateTime _selectedDay;
  CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = ValueNotifier(DateTime.now());
    _calendarFormat = CalendarFormat.month;
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendarLite'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
              valueListenable: _focusedDay,
              builder: (context, value, _) {
                final headerText = DateFormat.yMMMM().format(value);
                return Text(headerText, style: TextStyle(fontSize: 24.0));
              },
            ),
          ),
          TableCalendarLite(
            dowDecoration: const BoxDecoration(color: Colors.tealAccent),
            dowBuilder: (context, day) {
              final text = DateFormat.E().format(day);
              return Center(child: Text(text));
            },
            dayBuilder: (context, day, focusedDay) {
              var decoration = const BoxDecoration();
              var textStyle = const TextStyle();

              if (day.isBefore(_firstDay) || day.isAfter((_lastDay))) {
                textStyle = TextStyle(color: Colors.grey[300]);
              } else if (_selectedDay == day) {
                decoration = const BoxDecoration(
                  color: Colors.tealAccent,
                );
              } else if (day.month != focusedDay.month) {
                textStyle = const TextStyle(color: Colors.grey);
              }

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36.0,
                  height: 36.0,
                  decoration: decoration,
                  child: Center(
                    child: Text('${day.day}', style: textStyle),
                  ),
                ),
              );
            },
            dayHitTestBehavior: HitTestBehavior.opaque,
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay.value,
            calendarFormat: _calendarFormat,
            dowHeight: 24.0,
            rowHeight: 48.0,
            onDaySelected: (selectedDay, focusedDay) {
              if (_selectedDay != selectedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              }

              _focusedDay.value = focusedDay;
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay.value = focusedDay;
            },
          ),
        ],
      ),
    );
  }
}
