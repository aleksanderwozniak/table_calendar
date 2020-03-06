//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  Event(this.title);
  String title;

  String toString() => title;
}

// Example holidays
final Map<DateTime, List<Event>> _holidays = {
  DateTime(2020, 1, 1): [Event('New Year\'s Day')],
  DateTime(2020, 1, 6): [Event('Epiphany')],
  DateTime(2020, 2, 14): [Event('Valentine\'s Day')],
  DateTime(2020, 4, 21): [Event('Easter Sunday')],
  DateTime(2020, 4, 22): [Event('Easter Monday')],
};

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

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
  Map<DateTime, List<Event>> _events;
  List<Event> _selectedEvents;
  DateTime _selectedDay;
  CalendarFormat _calendarFormat;
  AnimationController _animationController;
  CalendarController<Event> _calendarController;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): [Event('Event A0'), Event('Event B0'), Event('Event C0')],
      _selectedDay.subtract(Duration(days: 27)): [Event('Event A1')],
      _selectedDay.subtract(Duration(days: 20)): [Event('Event A2'), Event('Event B2'), Event('Event C2'), Event('Event D2')],
      _selectedDay.subtract(Duration(days: 16)): [Event('Event A3'), Event('Event B3')],
      _selectedDay.subtract(Duration(days: 10)): [Event('Event A4'), Event('Event B4'), Event('Event C4')],
      _selectedDay.subtract(Duration(days: 4)): [Event('Event A5'), Event('Event B5'), Event('Event C5')],
      _selectedDay.subtract(Duration(days: 2)): [Event('Event A6'), Event('Event B6')],
      _selectedDay: [Event('Event A7'), Event('Event B7'), Event('Event C7'), Event('Event D7')],
      _selectedDay.add(Duration(days: 1)): [Event('Event A8'), Event('Event B8'), Event('Event C8'), Event('Event D8')],
      _selectedDay.add(Duration(days: 3)): Set.of([Event('Event A9'), Event('Event A9'), Event('Event B9')]).toList(),
      _selectedDay.add(Duration(days: 7)): [Event('Event A10'), Event('Event B10'), Event('Event C10')],
      _selectedDay.add(Duration(days: 11)): [Event('Event A11'), Event('Event B11')],
      _selectedDay.add(Duration(days: 17)): [Event('Event A12'), Event('Event B12'), Event('Event C12'), Event('Event D12')],
      _selectedDay.add(Duration(days: 22)): [Event('Event A13'), Event('Event B13')],
      _selectedDay.add(Duration(days: 26)): [Event('Event A14'), Event('Event B14'), Event('Event C14')],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarFormat = CalendarFormat.week;
    _calendarController = CalendarController<Event>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List<Event> events) {
    print('CALLBACK: _onDaySelected');

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedDay = day;
        _selectedEvents = events;
      });
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');

    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
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
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          _buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar<Event>(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      selectedDay: _selectedDay,
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar<Event>(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      calendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders<Event>(
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
                style: TextStyle().copyWith(fontSize: 16.0),
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
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, List<Event> events, List<Event> holidays) {
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
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Event> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date) ? Colors.brown[300] : Colors.blue[400],
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
        RaisedButton(
          child: Text('Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            setState(() {
              _selectedDay = dateTime;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((Event event) => Container(
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
