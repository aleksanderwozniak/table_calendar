//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:date_utils/date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../table_calendar.dart';

class CalendarLogic {
  DateTime get selectedDate => _selectedDate.value;
  set selectedDate(DateTime value) {
    _selectedDate.value = value;
    _focusedDate = value;
    _updateVisible(updateTwoWeeks: _calendarFormat.value != CalendarFormat.twoWeeks);
  }

  int get pageId => _pageId;
  CalendarFormat get calendarFormat => _calendarFormat.value;
  List<DateTime> get visibleMonth => _visibleMonth;
  List<DateTime> get visibleWeek => _visibleWeek;
  List<DateTime> get visibleTwoWeeks => _visibleTwoWeeks;
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
  List<DateTime> _visibleMonth;
  List<DateTime> _visibleWeek;
  List<DateTime> _visibleTwoWeeks;
  StartingDayOfWeek _startingDayOfWeek;
  ValueNotifier<CalendarFormat> _calendarFormat;
  ValueNotifier<DateTime> _selectedDate;
  List<CalendarFormat> _availableCalendarFormats;
  int _pageId;

  CalendarLogic(
    this._availableCalendarFormats,
    this._startingDayOfWeek, {
    DateTime initialDate,
    CalendarFormat initialFormat,
    OnFormatChanged onFormatChanged,
    OnDaySelected onDaySelected,
  }) : _pageId = 0 {
    final now = DateTime.now();
    _focusedDate = initialDate ?? DateTime(now.year, now.month, now.day);
    _calendarFormat = ValueNotifier(initialFormat);
    _selectedDate = ValueNotifier(_focusedDate);

    _updateVisible(updateTwoWeeks: true);

    if (onFormatChanged != null) {
      _calendarFormat.addListener(
        () => onFormatChanged(_calendarFormat.value),
      );
    }

    if (onDaySelected != null) {
      _selectedDate.addListener(
        () => onDaySelected(_selectedDate.value),
      );
    }
  }

  void dispose() {
    _calendarFormat.dispose();
  }

  CalendarFormat _nextFormat() {
    int id = _availableCalendarFormats.indexOf(_calendarFormat.value);
    id = (id + 1) % _availableCalendarFormats.length;

    return _availableCalendarFormats[id];
  }

  void toggleCalendarFormat() {
    _calendarFormat.value = _nextFormat();
  }

  void swipeCalendarFormat(bool isSwipeUp) {
    int id = _availableCalendarFormats.indexOf(_calendarFormat.value);

    // Order of CalendarFormats must be from biggest to smallest,
    // eg.: [month, twoWeeks, week]
    if (isSwipeUp) {
      id = _clamp(0, _availableCalendarFormats.length - 1, id + 1);
    } else {
      id = _clamp(0, _availableCalendarFormats.length - 1, id - 1);
    }
    _calendarFormat.value = _availableCalendarFormats[id];
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
    var daysBefore = _startingDayOfWeek == StartingDayOfWeek.sunday ? first.weekday : first.weekday - 1;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));

    if (firstToDisplay.hour == 23) {
      firstToDisplay = firstToDisplay.add(Duration(hours: 1));
    }

    var last = Utils.lastDayOfMonth(month);

    if (last.hour == 23) {
      last = last.add(Duration(hours: 1));
    }

    var daysAfter = 7 - last.weekday;

    if (_startingDayOfWeek == StartingDayOfWeek.sunday) {
      // If the last day is Sunday (7) the entire week must be rendered
      if (daysAfter == 0) {
        daysAfter = 7;
      }
    } else {
      daysAfter++;
    }

    var lastToDisplay = last.add(Duration(days: daysAfter));

    if (lastToDisplay.hour == 1) {
      lastToDisplay = lastToDisplay.subtract(Duration(hours: 1));
    }

    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  List<DateTime> _daysInWeek(DateTime week) {
    final first = _firstDayOfWeek(week);
    final last = _lastDayOfWeek(week);

    final days = Utils.daysInRange(first, last);
    return days.map((day) => DateTime(day.year, day.month, day.day)).toList();
  }

  DateTime _firstDayOfWeek(DateTime day) {
    day = DateTime.utc(day.year, day.month, day.day, 12);

    final decreaseNum = _startingDayOfWeek == StartingDayOfWeek.sunday ? day.weekday % 7 : day.weekday - 1;
    return day.subtract(Duration(days: decreaseNum));
  }

  DateTime _lastDayOfWeek(DateTime day) {
    day = DateTime.utc(day.year, day.month, day.day, 12);

    final increaseNum = _startingDayOfWeek == StartingDayOfWeek.sunday ? day.weekday % 7 : day.weekday - 1;
    return day.add(Duration(days: 7 - increaseNum));
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

  int _clamp(int min, int max, int value) {
    if (value > max) {
      return max;
    } else if (value < min) {
      return min;
    } else {
      return value;
    }
  }
}
