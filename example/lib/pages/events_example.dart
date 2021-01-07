// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar_example/utils.dart';

class EventsExamplePage extends StatefulWidget {
  @override
  _EventsExamplePageState createState() => _EventsExamplePageState();
}

class _EventsExamplePageState extends State<EventsExamplePage> {
  Map<DateTime, List<Event>> _events;
  List<Event> _selectedEvents;
  DateTime _selectedDay;
  CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    final selectedDay = DateTime.now().toUtc();

    // Using a [LinkedHashMap] is highly recommended
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEvents);

    _selectedEvents = _events[selectedDay] ?? [];
    _selectedDay = selectedDay;
    _calendarFormat = CalendarFormat.month;
  }

  void _onDaySelected(DateTime day, List<Event> events, List<Event> holidays) {
    print('===============================');
    print('Callback: _onDaySelected');
    print('SelectedDay: $day');
    print('Events: $events');
    print('Holidays: $holidays');

    if (_selectedDay != day) {
      _selectedDay = day;
    }

    // Only [eventList] requires rebuilding, so this can be improved
    // -> check out "complex_example.dart" file
    setState(() {
      _selectedEvents = [
        ...holidays,
        ...events,
      ];
    });
  }

  void _onFormatChanged(CalendarFormat format, DateTime first, DateTime last) {
    print('===============================');
    print('Callback: _onFormatChanged');
    print('Format: $format');
    print('First: $first');
    print('Last: $last');

    if (_calendarFormat != format) {
      _calendarFormat = format;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar-Events'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          TableCalendar<Event>(
            events: _events,
            holidays: kHolidays,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: _onDaySelected,
            onFormatChanged: _onFormatChanged,
          ),
          const SizedBox(height: 8.0),
          RaisedButton(
            child: Text('Clear selection'),
            onPressed: () {
              setState(() {
                _selectedDay = null;
                _selectedEvents = [];
              });
            },
          ),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}
