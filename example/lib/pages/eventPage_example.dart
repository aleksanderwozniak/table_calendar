import 'package:flutter/material.dart';
import 'package:table_calendar_example/utils.dart';

// ignore: must_be_immutable
class RedirectPage extends StatefulWidget {
  DateTime dayOfEvent;
  RedirectPage(this.dayOfEvent, {Key? key}) : super(key: key);

  @override
  State<RedirectPage> createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  late List<Event> _listEvent;
  List<Event> _fetchEvents(DateTime day) {
    List<Event> listEvent = [Event('Event 1'), Event('Event 2')];
    return listEvent;
  }

  @override
  void initState() {
    _listEvent = _fetchEvents(widget.dayOfEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TableCalendar - Page after redirection'),
        ),
        body: Column(
            children: _listEvent.map((e) {
          return Text(e.title);
        }).toList()));
  }
}
