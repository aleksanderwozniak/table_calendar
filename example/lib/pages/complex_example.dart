// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar_example/utils.dart';

class ComplexExamplePage extends StatefulWidget {
  @override
  _ComplexExamplePageState createState() => _ComplexExamplePageState();
}

class _ComplexExamplePageState extends State<ComplexExamplePage>
    with SingleTickerProviderStateMixin {
  Map<DateTime, List<Event>> _events;
  ValueNotifier<List<Event>> _selectedEvents;
  AnimationController _animationController;
  CalendarFormat _calendarFormat;
  DateTime _selectedDay;
  DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();

    // Using a [LinkedHashMap] is highly recommended
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEvents);

    _selectedDay = now;
    _focusedDay = now;
    _selectedEvents = ValueNotifier(_events[_selectedDay] ?? []);
    _calendarFormat = CalendarFormat.month;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List<Event> events, List<Event> holidays) {
    print('===============================');
    print('Callback: _onDaySelected');
    print('SelectedDay: $day');
    print('Events: $events');
    print('Holidays: $holidays');

    if (_selectedDay != day) {
      _selectedDay = day;
      _focusedDay = day;
    }

    // This rebuilds just the [eventList], not the whole page
    _selectedEvents.value = [
      ...holidays,
      ...events,
    ];

    _animationController.forward(from: 0.0);
  }

  void _onPageChanged(DateTime focusedDay, DateTime first, DateTime last) {
    print('===============================');
    print('Callback: _onPageChanged');
    print('FocusedDay: $focusedDay');
    print('First: $first');
    print('Last: $last');

    if (_focusedDay != focusedDay) {
      _focusedDay = focusedDay;
    }
  }

  void _onFormatChanged(CalendarFormat format, DateTime first, DateTime last) {
    print('===============================');
    print('Callback: _onFormatChanged');
    print('CalendarFormat: $format');
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
        title: Text('TableCalendar-Complex'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          _buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar<Event>(
      locale: 'pl_PL',
      events: _events,
      holidays: kHolidays,
      selectedDay: _selectedDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle(color: Colors.blue[800]),
        holidayStyle: TextStyle(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: _onDaySelected,
      onPageChanged: _onPageChanged,
      onFormatChanged: _onFormatChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Event> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: isSameDay(date, _selectedDay)
            ? Colors.brown[500]
            : isSameDay(date, DateTime.now())
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    final dateTime = _events.keys.elementAt(_events.length - 2);

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Month'),
              onPressed: () {
                setState(() {
                  _calendarFormat = CalendarFormat.month;
                });
              },
            ),
            RaisedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarFormat = CalendarFormat.twoWeeks;
                });
              },
            ),
            RaisedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarFormat = CalendarFormat.week;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              child: Text('Select today'),
              onPressed: () {
                setState(() {
                  _selectedDay = DateTime.now().toUtc();
                  _focusedDay = _selectedDay;
                });
              },
            ),
            RaisedButton(
              child: Text(
                'Select ${dateTime.day}/${dateTime.month}/${dateTime.year}',
              ),
              onPressed: () {
                setState(() {
                  _selectedDay = dateTime;
                  _focusedDay = dateTime;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _selectedEvents,
      builder: (context, value, child) => ListView(
        children: value
            .map((event) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(event.toString()),
                    onTap: () => print('$event tapped!'),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
