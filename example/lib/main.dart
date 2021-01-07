// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar_example/pages/complex_example.dart';
import 'package:table_calendar_example/pages/events_example.dart';
import 'package:table_calendar_example/pages/persistence_example.dart';
import 'package:table_calendar_example/pages/simple_example.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text('Simple'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SimpleExamplePage()),
              ),
            ),
            const SizedBox(height: 12.0),
            RaisedButton(
              child: Text('Persistence'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PersistenceExamplePage()),
              ),
            ),
            const SizedBox(height: 12.0),
            RaisedButton(
              child: Text('Events'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventsExamplePage()),
              ),
            ),
            const SizedBox(height: 12.0),
            RaisedButton(
              child: Text('Complex'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ComplexExamplePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
