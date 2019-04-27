//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:date_utils/date_utils.dart';
import 'package:flutter/foundation.dart';

import '../../table_calendar.dart';

const double _dxMax = 1.2;
const double _dxMin = -1.2;

class CalendarLogic {
  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  int get pageId => _pageId;
  double get dx => _dx;
  CalendarFormat get calendarFormat => _calendarFormat.value;
  List<DateTime> get visibleDays => _visibleDays.value;
  String get formatButtonText => _useNextCalendarFormat
      ? _availableCalendarFormats[_nextFormat()]
      : _availableCalendarFormats[_calendarFormat.value];

  DateTime _focusedDay;
  DateTime _selectedDay;
  StartingDayOfWeek _startingDayOfWeek;
  ValueNotifier<CalendarFormat> _calendarFormat;
  ValueNotifier<List<DateTime>> _visibleDays;
  Map<CalendarFormat, String> _availableCalendarFormats;
  DateTime _previousFirstDay;
  DateTime _previousLastDay;
  int _pageId;
  double _dx;
  bool _useNextCalendarFormat;

  CalendarLogic(
    this._availableCalendarFormats,
    this._startingDayOfWeek,
    this._useNextCalendarFormat, {
    DateTime initialDay,
    CalendarFormat initialFormat,
    OnVisibleDaysChanged onVisibleDaysChanged,
    bool includeInvisibleDays = false,
  })  : _pageId = 0,
        _dx = 0 {
    final now = DateTime.now();
    _focusedDay = initialDay ?? DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _calendarFormat = ValueNotifier(initialFormat);
    _visibleDays = ValueNotifier(_getVisibleDays());
    _previousFirstDay = _visibleDays.value.first;
    _previousLastDay = _visibleDays.value.last;

    _calendarFormat.addListener(() {
      _visibleDays.value = _getVisibleDays();
    });

    if (onVisibleDaysChanged != null) {
      _visibleDays.addListener(() {
        if (!Utils.isSameDay(_visibleDays.value.first, _previousFirstDay) ||
            !Utils.isSameDay(_visibleDays.value.last, _previousLastDay)) {
          _previousFirstDay = _visibleDays.value.first;
          _previousLastDay = _visibleDays.value.last;
          onVisibleDaysChanged(
            _getFirstDay(includeInvisible: includeInvisibleDays),
            _getLastDay(includeInvisible: includeInvisibleDays),
            _calendarFormat.value,
          );
        }
      });
    }
  }

  void dispose() {
    _calendarFormat.dispose();
    _visibleDays.dispose();
  }

  CalendarFormat _nextFormat() {
    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);
    id = (id + 1) % formats.length;

    return formats[id];
  }

  void toggleCalendarFormat() {
    _calendarFormat.value = _nextFormat();
  }

  void swipeCalendarFormat(bool isSwipeUp) {
    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);

    // Order of CalendarFormats must be from biggest to smallest,
    // eg.: [month, twoWeeks, week]
    if (isSwipeUp) {
      id = _clamp(0, formats.length - 1, id + 1);
    } else {
      id = _clamp(0, formats.length - 1, id - 1);
    }
    _calendarFormat.value = formats[id];
  }

  bool setSelectedDay(DateTime value, {bool isAnimated = true, bool isProgrammatic = false}) {
    if (Utils.isSameDay(value, _selectedDay)) {
      return false;
    }

    if (isAnimated) {
      if (value.isBefore(_getFirstDay(includeInvisible: false))) {
        _decrementPage();
      } else if (value.isAfter(_getLastDay(includeInvisible: false))) {
        _incrementPage();
      }
    }

    _selectedDay = value;
    _focusedDay = value;

    if (calendarFormat != CalendarFormat.twoWeeks || isProgrammatic) {
      _visibleDays.value = _getVisibleDays();
    }

    return true;
  }

  void selectPrevious() {
    if (calendarFormat == CalendarFormat.month) {
      _selectPreviousMonth();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectPreviousTwoWeeks();
    } else {
      _selectPreviousWeek();
    }

    _visibleDays.value = _getVisibleDays();
    _decrementPage();
  }

  void selectNext() {
    if (calendarFormat == CalendarFormat.month) {
      _selectNextMonth();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectNextTwoWeeks();
    } else {
      _selectNextWeek();
    }

    _visibleDays.value = _getVisibleDays();
    _incrementPage();
  }

  void _selectPreviousMonth() {
    _focusedDay = Utils.previousMonth(_focusedDay);
  }

  void _selectNextMonth() {
    _focusedDay = Utils.nextMonth(_focusedDay);
  }

  void _selectPreviousTwoWeeks() {
    if (_visibleDays.value.take(7).contains(_focusedDay)) {
      // in top row
      _focusedDay = Utils.previousWeek(_focusedDay);
    } else {
      // in bottom row OR not visible
      _focusedDay = Utils.previousWeek(_focusedDay.subtract(const Duration(days: 7)));
    }
  }

  void _selectNextTwoWeeks() {
    if (!_visibleDays.value.skip(7).contains(_focusedDay)) {
      // not in bottom row [eg: in top row OR not visible]
      _focusedDay = Utils.nextWeek(_focusedDay);
    }
  }

  void _selectPreviousWeek() {
    _focusedDay = Utils.previousWeek(_focusedDay);
  }

  void _selectNextWeek() {
    _focusedDay = Utils.nextWeek(_focusedDay);
  }

  DateTime _getFirstDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return Utils.firstDayOfMonth(_focusedDay);
    } else {
      return _visibleDays.value.first;
    }
  }

  DateTime _getLastDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      var last = Utils.lastDayOfMonth(_focusedDay);
      if (last.hour == 23) {
        last = last.add(Duration(hours: 1));
      }
      return last;
    } else {
      return _visibleDays.value.last;
    }
  }

  List<DateTime> _getVisibleDays() {
    if (calendarFormat == CalendarFormat.month) {
      return _daysInMonth(_focusedDay);
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      return _daysInWeek(_focusedDay)
        ..addAll(_daysInWeek(
          _focusedDay.add(const Duration(days: 7)),
        ));
    } else {
      return _daysInWeek(_focusedDay);
    }
  }

  void _decrementPage() {
    _pageId--;
    _dx = _dxMin;
  }

  void _incrementPage() {
    _pageId++;
    _dx = _dxMax;
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = Utils.firstDayOfMonth(month);
    final daysBefore = _startingDayOfWeek == StartingDayOfWeek.sunday ? first.weekday % 7 : first.weekday - 1;
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
    return Utils.isSameDay(day, selectedDay);
  }

  bool isToday(DateTime day) {
    return Utils.isSameDay(day, DateTime.now());
  }

  bool isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  bool isExtraDay(DateTime day) {
    return _isExtraDayBefore(day) || _isExtraDayAfter(day);
  }

  bool _isExtraDayBefore(DateTime day) {
    return day.month < _focusedDay.month;
  }

  bool _isExtraDayAfter(DateTime day) {
    return day.month > _focusedDay.month;
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
