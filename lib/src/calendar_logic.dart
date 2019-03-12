//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:date_utils/date_utils.dart';
import 'package:intl/intl.dart';

import '../table_calendar.dart';

class CalendarLogic {
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    _focusedDate = value;
    _updateVisible(updateTwoWeeks: _calendarFormat != CalendarFormat.twoWeeks);
  }

  int get pageId => _pageId;
  CalendarFormat get calendarFormat => _calendarFormat;
  List<DateTime> get visibleMonth => _visibleMonth;
  List<DateTime> get visibleWeek => _visibleWeek;
  List<DateTime> get visibleTwoWeeks => _visibleTwoWeeks;
  List<String> get daysOfWeek => _visibleMonth.take(7).map((date) => DateFormat.E().format(date)).toList();
  String get headerText => DateFormat.yMMMM().format(_focusedDate);
  String get headerToggleText {
    switch (_nextFormat()) {
      case CalendarFormat.month:
        return 'Full';
      case CalendarFormat.twoWeeks:
        return 'Compact';
      case CalendarFormat.week:
        return 'Minimal';
      default:
        assert(false);
        return null;
    }
  }

  DateTime _focusedDate;
  DateTime _selectedDate;
  List<DateTime> _visibleMonth;
  List<DateTime> _visibleWeek;
  List<DateTime> _visibleTwoWeeks;
  CalendarFormat _calendarFormat;
  List<CalendarFormat> _availableCalendarFormats;
  int _pageId;

  CalendarLogic(this._calendarFormat, this._availableCalendarFormats, {DateTime initialDate}) : _pageId = 0 {
    final now = DateTime.now();
    _focusedDate = initialDate ?? DateTime(now.year, now.month, now.day);
    _selectedDate = _focusedDate;
    _visibleTwoWeeks = _daysInWeek(_focusedDate)
      ..addAll(_daysInWeek(
        _focusedDate.add(const Duration(days: 7)),
      ));
    _updateVisible();
  }

  CalendarFormat _nextFormat() {
    int id = _availableCalendarFormats.indexOf(_calendarFormat);
    id = (id + 1) % _availableCalendarFormats.length;

    return _availableCalendarFormats[id];
  }

  void toggleCalendarFormat() {
    _calendarFormat = _nextFormat();
  }

  void selectPrevious() {
    if (calendarFormat == CalendarFormat.week) {
      _selectPreviousWeek();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectPreviousTwoWeeks();
    } else {
      _selectPreviousMonth();
    }

    _pageId--;
  }

  void selectNext() {
    if (calendarFormat == CalendarFormat.week) {
      _selectNextWeek();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectNextTwoWeeks();
    } else {
      _selectNextMonth();
    }

    _pageId++;
  }

  void _selectPreviousMonth() {
    _focusedDate = Utils.previousMonth(_focusedDate);
    _updateVisible();
  }

  void _selectNextMonth() {
    _focusedDate = Utils.nextMonth(_focusedDate);
    _updateVisible();
  }

  void _selectPreviousTwoWeeks() {
    if (_visibleTwoWeeks.take(7).contains(_focusedDate)) {
      // in top row
      _focusedDate = Utils.previousWeek(_focusedDate);
    } else {
      // in bottom row OR not visible
      _focusedDate = Utils.previousWeek(_focusedDate.subtract(const Duration(days: 7)));
    }

    _updateVisible();
  }

  void _selectNextTwoWeeks() {
    if (!_visibleTwoWeeks.skip(7).contains(_focusedDate)) {
      // not in bottom row [eg: in top row OR not visible]
      _focusedDate = Utils.nextWeek(_focusedDate);
    }

    _updateVisible();
  }

  void _selectPreviousWeek() {
    _focusedDate = Utils.previousWeek(_focusedDate);

    _updateVisible();
  }

  void _selectNextWeek() {
    _focusedDate = Utils.nextWeek(_focusedDate);
    _updateVisible();
  }

  void _updateVisible({bool updateTwoWeeks: true}) {
    _visibleMonth = _daysInMonth(_focusedDate);
    _visibleWeek = _daysInWeek(_focusedDate);

    if (updateTwoWeeks) {
      _visibleTwoWeeks = _daysInWeek(_focusedDate)
        ..addAll(_daysInWeek(
          _focusedDate.add(const Duration(days: 7)),
        ));
    }
  }

  List<DateTime> _daysInMonth(DateTime month) {
    var first = Utils.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));

    if (firstToDisplay.hour == 23) {
      firstToDisplay = firstToDisplay.add(Duration(hours: 1));
    }

    var last = Utils.lastDayOfMonth(month);

    if (last.hour == 23) {
      last = last.add(Duration(hours: 1));
    }

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(Duration(days: daysAfter));

    if (lastToDisplay.hour == 1) {
      lastToDisplay = lastToDisplay.subtract(Duration(hours: 1));
    }

    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  List<DateTime> _daysInWeek(DateTime week) {
    final first = Utils.firstDayOfWeek(week);
    final last = Utils.lastDayOfWeek(week);

    final days = Utils.daysInRange(first, last);
    return days.map((day) => DateTime(day.year, day.month, day.day)).toList();
  }

  bool isSelected(DateTime day) {
    return Utils.isSameDay(day, selectedDate);
  }

  bool isToday(DateTime day) {
    return Utils.isSameDay(day, DateTime.now());
  }

  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  bool isExtraDay(DateTime day) {
    final isBefore = _visibleMonth.take(7).where((date) => date.day > 10).any((date) => Utils.isSameDay(date, day));
    final isAfter =
        _visibleMonth.skip(_visibleMonth.length - 1 - 7).where((date) => date.day < 10).any((date) => Utils.isSameDay(date, day));

    return isBefore || isAfter;
  }
}
