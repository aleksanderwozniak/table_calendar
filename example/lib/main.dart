// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TableCalendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final Color textColor = Color(0xFFFFFFFF);
  final Color lineColor = Color(0xFFFFFFFF);

  DateTime selectedDay = DateTime.now();
  bool get isToday => selectedDay.startOfDay == DateTime.now().startOfDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff1D275B),
              border: Border(
                bottom: BorderSide(
                  color: lineColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TableCalendar(
              focusedDay: selectedDay, // initialSelectedDay: date perhaps
              firstDay: DateTime.now().subtract(Duration(days: 10000)),
              lastDay: DateTime.now().add(Duration(days: 10000)),
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: true, // isOpen
              rowHeight: 40,
              locale: "en_EN",
              selectedDayPredicate: (date) {
                return date.startOfDay == selectedDay.startOfDay;
              },
              onDaySelected: (DateTime date, _) {
                setState(() {
                  selectedDay = date;
                });
              },
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.horizontalSwipe,
              calendarStyle: CalendarStyle(
                calendarMargin: EdgeInsets.only(bottom: 5, top: true ? 10 : 0), // isOpen
                isTodayHighlighted: isToday,
                todayTextStyle: TextStyle(color: textColor, fontSize: 16),
                todayDecoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFBD0D)),
                selectedDecoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFBD0D)),
                beforeTodayDecoration: BoxDecoration(),
                defaultDecoration: BoxDecoration(),
                // todayColor: Color(0xFFFFFF),
                // selectedColor: Color(0xFFFFBD0D),
                defaultTextStyle: TextStyle(fontSize: 18, color: textColor),
                weekendTextStyle: TextStyle(fontSize: 18, color: textColor),
                outsideTextStyle: TextStyle(
                  fontSize: 18,
                  color: lineColor.withOpacity(0.4),
                ),
                outsideWeekendStyle: TextStyle(
                  fontSize: 18,
                  color: lineColor.withOpacity(0.4),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date).toUpperCase(),
                weekdayStyle: TextStyle(fontSize: 14, color: textColor),
                weekendStyle: TextStyle(fontSize: 14, color: textColor),
                selectedStyle: TextStyle(fontSize: 14, color: Color(0xFFFFBD0D)),
              ),
              headerStyle: HeaderStyle(
                titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date).toUpperCase(),
                titleTextStyle: TextStyle(fontSize: 22, color: textColor),
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: textColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: textColor,
                ),
                leftChevronPadding: EdgeInsets.symmetric(horizontal: 20),
                rightChevronPadding: EdgeInsets.symmetric(horizontal: 20),
                headerHeight: 47,
                headerMargin: EdgeInsets.only(left: 20, right: 20),
                titleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: lineColor.withOpacity(0.2), width: 1),
                    bottom: BorderSide(color: lineColor.withOpacity(0.2), width: 1),
                  ),
                ),
                leftIconDecoration: BoxDecoration(
                  border: Border.all(
                    color: lineColor.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
                rightIconDecoration: BoxDecoration(
                  border: Border.all(
                    color: lineColor.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                color: Color(0xff1D275B),
                child: Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "morning",
                            style: TextStyle(color: lineColor),
                          ),
                          Container(
                            height: 43,
                            width: 100,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF23252E),
                              border: Border.all(
                                color: lineColor.withOpacity(0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(),
                                Text(
                                  '/',
                                  style: TextStyle(fontSize: 18, color: textColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "noon",
                            style: TextStyle(color: lineColor),
                          ),
                          Container(
                            height: 43,
                            width: 100,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            margin: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: Color(0xFF23252E),
                              border: Border.all(
                                color: lineColor.withOpacity(0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(),
                                Text(
                                  '/',
                                  style: TextStyle(fontSize: 18, color: textColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "evening",
                            style: TextStyle(color: lineColor),
                          ),
                          Container(
                            height: 43,
                            width: 100,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF23252E),
                              border: Border.all(
                                color: lineColor.withOpacity(0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(),
                                Text(
                                  '/',
                                  style: TextStyle(fontSize: 18, color: textColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))),
          ),
        ],
      ),
    );
  }
}
