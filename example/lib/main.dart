//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Table Calendar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  DateTime _selectedDay;
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _events = {
      DateTime(2019, 3, 1): ['Event A', 'Event B', 'Event C'],
      DateTime(2019, 3, 4): ['Event A'],
      DateTime(2019, 3, 5): ['Event B', 'Event C'],
      DateTime(2019, 3, 13): ['Event A', 'Event B', 'Event C'],
      DateTime(2019, 3, 15): ['Event A', 'Event B', 'Event C', 'Event D', 'Event E', 'Event F', 'Event G'],
      DateTime(2019, 2, 26): Set.from(['Event A', 'Event A', 'Event B']).toList(),
      DateTime(2019, 2, 18): ['Event A', 'Event A', 'Event B'],
    };
    _selectedEvents = _events[_selectedDay] ?? [];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _controller.forward();
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
      _selectedEvents = _events[_selectedDay] ?? [];
    });

    print('Selected day: $day');
  }

  void _onFormatChanged(CalendarFormat format) {
    print('Current format: $format');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out lines 85 and 86 to play with TableCalendar's settings
          //-----------------------
          // _buildTableCalendar(),
          _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration is here (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      events: _events,
      initialCalendarFormat: CalendarFormat.week,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: [
        CalendarFormat.month,
        CalendarFormat.twoWeeks,
        CalendarFormat.week,
      ],
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        eventMarkerColor: Colors.brown[700],
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onFormatChanged: _onFormatChanged,
    );
  }

  // More advanced TableCalendar configuration is here (using Styles & Builders)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      events: _events,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: [
        CalendarFormat.month,
        CalendarFormat.week,
      ],
      calendarStyle: CalendarStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      selectedDayBuilder: (context, date, _) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: Container(
            margin: const EdgeInsets.all(2.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.orange,
            width: 50,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          ),
        );
      },
      todayDayBuilder: (context, date, _) {
        return Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.only(top: 5.0, left: 6.0),
          color: Colors.amber,
          width: 100,
          height: 50,
          child: Text(
            '${date.day}',
            style: TextStyle().copyWith(fontSize: 16.0),
          ),
        );
      },
      markersBuilder: (context, date, events) {
        return Positioned(
          right: 3,
          bottom: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: date == _selectedDay ? Colors.brown[700] : Colors.blue[600],
            ),
            width: 16.0,
            height: 16.0,
            child: Center(
              child: Text(
                '${events.length}',
                style: TextStyle().copyWith(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        );
      },
      onDaySelected: (date) {
        _onDaySelected(date);
        _controller.forward(from: 0.0);
      },
      onFormatChanged: _onFormatChanged,
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
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}
