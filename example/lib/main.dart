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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: TableCalendar(
        events: {
          DateTime(2019, 2, 22): ['a', 'b', 'c'],
          DateTime(2019, 2, 23): ['a'],
          DateTime(2019, 2, 24): ['b', 'c'],
          DateTime(2019, 3, 1): ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
          DateTime(2019, 1, 29): Set.from(['a', 'a']).toList(),
          DateTime(2019, 1, 30): ['a', 'a'],
        },
      ),
    );
  }
}
