// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar_example/utils.dart';

class SimpleExamplePage extends StatefulWidget {
  @override
  _SimpleExamplePageState createState() => _SimpleExamplePageState();
}

class _SimpleExamplePageState extends State<SimpleExamplePage> {
  Map<DateTime, List<Event>> _events;

  @override
  void initState() {
    super.initState();

    // Using a [LinkedHashMap] is highly recommended
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEvents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar-Simple'),
      ),
      body: TableCalendar<Event>(
        events: _events,
        // Use to customize calendar's body style
        calendarStyle: CalendarStyle(
          selectedColor: Colors.deepOrange[400],
          todayColor: Colors.deepOrange[200],
          markersColor: Colors.brown[700],
          outsideDaysVisible: false,
        ),
        // Use to customize calendar's header style
        headerStyle: HeaderStyle(
          formatButtonTextStyle:
              const TextStyle(color: Colors.white, fontSize: 15.0),
          formatButtonDecoration: BoxDecoration(
            color: Colors.deepOrange[400],
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        onDaySelected: (day, events, holidays) {
          print('Callback: onDaySelected');
          print('SelectedDay: $day');
          print('Events: $events');
        },
      ),
    );
  }
}
