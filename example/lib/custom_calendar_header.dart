import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TableCalendar Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarController _calendarController;
  DateTime _headerDate;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _headerDate = DateTime.now();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TableCalendar Header Demo')),
      body: Center(
        child: Column(
          children: <Widget>[
            CustomCalendarHeader(headerDate: _headerDate),
            TableCalendar(
              calendarController: _calendarController,
              headerVisible: false,
              onVisibleDaysChanged: (_, __, ___) {
                setState(() {
                  _headerDate = _calendarController.focusedDay;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCalendarHeader extends StatelessWidget {
  final DateTime headerDate;

  const CustomCalendarHeader({
    Key key,
    @required this.headerDate,
  })  : assert(headerDate != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          DateFormat.yMMMM().format(headerDate),
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
