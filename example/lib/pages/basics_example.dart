// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class TableBasicsExample extends StatefulWidget {
  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar - Basics'),
      ),
      body: TableCalendar(
        locale: 'ko_KR',
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: new HeaderStyle(
          leftChevronIcon: Image.asset(
            'assets/images/icons8-go-back-64.png',
            width: 32,
          ),
          leftChevronMargin: EdgeInsets.only(left: 60.0),
          rightChevronIcon: Image.asset(
            'assets/images/icons8-circled-right-64.png',
            width: 32,
          ),
          rightChevronMargin: EdgeInsets.only(right: 60.0),
          headerMargin: EdgeInsets.all(10.0),
          titleCentered: true,
          titleYearTextStyle: new TextStyle(
            fontSize: 18.0,
            fontFamily: 'ACCKidsHeart',
            fontWeight: FontWeight.normal,
          ),
          titleMonthTextStyle: new TextStyle(
            fontSize: 24.0,
            fontFamily: 'ACCKidsHeart',
            fontWeight: FontWeight.bold,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: const TextStyle(
            color: const Color(0xFF4F4F4F),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          sundayStyle: const TextStyle(
            color: Color.fromARGB(255, 255, 0, 0),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          saturdayStyle: const TextStyle(
            color: Color.fromARGB(255, 0, 89, 255),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        daysOfWeekHeight: 50,
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
      ),
    );
  }
}
