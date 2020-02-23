//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

const _initialPage = 10000;

/// Controller required for `TableCalendar`.
///
/// Should be created in `initState()`, and then disposed in `dispose()`:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   _calendarController = CalendarController();
/// }
///
/// @override
/// void dispose() {
///   _calendarController.dispose();
///   super.dispose();
/// }
/// ```
class CalendarController {
  /// Currently focused day (used to determine which year/month should be visible).
  DateTime get focusedDay => _focusedDay.value;

  /// Currently selected day.
  DateTime get selectedDay => _selectedDay;

  /// Currently visible calendar format.
  CalendarFormat get calendarFormat => _calendarFormat.value;

  List<DateTime> get visibleDays => calendarFormat == CalendarFormat.month && !_includeInvisibleDays
      ? _visibleDays.where((day) => !_isExtraDay(day)).toList()
      : _visibleDays;

  /// `Map` of currently visible events.
  Map<DateTime, List> get visibleEvents {
    if (_events == null) {
      return {};
    }

    return Map.fromEntries(
      _events.entries.where((entry) {
        for (final day in visibleDays) {
          if (isSameDay(day, entry.key)) {
            return true;
          }
        }

        return false;
      }),
    );
  }

  /// `Map` of currently visible holidays.
  Map<DateTime, List> get visibleHolidays {
    if (_holidays == null) {
      return {};
    }

    return Map.fromEntries(
      _holidays.entries.where((entry) {
        for (final day in visibleDays) {
          if (isSameDay(day, entry.key)) {
            return true;
          }
        }

        return false;
      }),
    );
  }

  Map<DateTime, List> _events;
  Map<DateTime, List> _holidays;
  List<DateTime> _visibleDays;
  DateTime _selectedDay;
  StartingDayOfWeek _startingDayOfWeek;
  ValueNotifier<double> _calendarHeight;
  ValueNotifier<DateTime> _focusedDay;
  ValueNotifier<CalendarFormat> _calendarFormat;
  Map<CalendarFormat, String> _availableCalendarFormats;
  DateTime _previousFirstDay;
  DateTime _previousLastDay;
  bool _useNextCalendarFormat;
  bool _includeInvisibleDays;
  double _rowHeight;
  int _previousPageIndex;
  OnVisibleDaysChanged _onVisibleDaysChanged;
  PageController _pageController;

  void _init({
    @required Map<DateTime, List> events,
    @required Map<DateTime, List> holidays,
    @required DateTime initialDay,
    @required CalendarFormat initialFormat,
    @required Map<CalendarFormat, String> availableCalendarFormats,
    @required bool useNextCalendarFormat,
    @required StartingDayOfWeek startingDayOfWeek,
    @required OnVisibleDaysChanged onVisibleDaysChanged,
    @required bool includeInvisibleDays,
    @required double rowHeight,
  }) {
    _events = events;
    _holidays = holidays;
    _availableCalendarFormats = availableCalendarFormats;
    _startingDayOfWeek = startingDayOfWeek;
    _useNextCalendarFormat = useNextCalendarFormat;
    _includeInvisibleDays = includeInvisibleDays;
    _rowHeight = rowHeight;
    _onVisibleDaysChanged = onVisibleDaysChanged;

    final day = initialDay != null ? _normalizeDate(initialDay) : _normalizeDate(DateTime.now());
    _focusedDay = ValueNotifier(day);
    _selectedDay = _focusedDay.value;
    _calendarFormat = ValueNotifier(initialFormat);
    _previousPageIndex = _initialPage;

    _visibleDays = _getVisibleDays(day);
    _calendarHeight = ValueNotifier(_getCalendarHeight());

    _previousFirstDay = _visibleDays.first;
    _previousLastDay = _visibleDays.last;

    _pageController = PageController(initialPage: _initialPage, keepPage: false);
  }

  /// Disposes the controller.
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _calendarController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _calendarFormat?.dispose();
    _focusedDay?.dispose();
    _calendarHeight?.dispose();
    _pageController?.dispose();
  }

  /// Toggles calendar format. Same as using `FormatButton`.
  void toggleCalendarFormat() {
    _calendarFormat.value = _nextFormat();
    _updateVisibleDays(pageIndex: _previousPageIndex);
  }

  /// Sets calendar format by emulating swipe.
  void swipeCalendarFormat({@required bool isSwipeUp}) {
    assert(isSwipeUp != null);

    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);

    // Order of CalendarFormats must be from biggest to smallest,
    // ie.: [month, twoWeeks, week]
    if (isSwipeUp) {
      id = _clamp(0, formats.length - 1, id + 1);
    } else {
      id = _clamp(0, formats.length - 1, id - 1);
    }

    _calendarFormat.value = formats[id];
    _updateVisibleDays(pageIndex: _previousPageIndex);
  }

  void _setCalendarFormat(CalendarFormat value, {bool triggerCallback = true}) {
    _calendarFormat.value = value;
    _updateVisibleDays(pageIndex: _previousPageIndex, triggerCallback: triggerCallback);
  }

  void _updateVisibleDays({@required int pageIndex, bool triggerCallback = true}) {
    _updateFocusedDay(pageIndex: pageIndex);
    _visibleDays = _getVisibleDays(_focusedDay.value);
    _updateCalendarHeight();

    if (!isSameDay(_visibleDays.first, _previousFirstDay) || !isSameDay(_visibleDays.last, _previousLastDay)) {
      _previousFirstDay = _visibleDays.first;
      _previousLastDay = _visibleDays.last;

      if (_onVisibleDaysChanged != null && triggerCallback) {
        _onVisibleDaysChanged(
          _getFirstDay(includeInvisible: _includeInvisibleDays),
          _getLastDay(includeInvisible: _includeInvisibleDays),
          _calendarFormat.value,
        );
      }
    }
  }

  void _updateCalendarHeight() {
    _calendarHeight.value = _getCalendarHeight();
  }

  double _getCalendarHeight() {
    final dowHeight = 16.0;
    final contentHeight = _visibleDays.length ~/ 7 * _rowHeight;

    return dowHeight + contentHeight;
  }

  List<DateTime> _getVisibleDays(DateTime focusedDay) {
    if (calendarFormat == CalendarFormat.month) {
      return _daysInMonth(focusedDay);
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      return _daysInWeek(focusedDay)
        ..addAll(_daysInWeek(
          focusedDay.add(const Duration(days: 7)),
        ));
    } else {
      return _daysInWeek(focusedDay);
    }
  }

  DateTime _getFocusedDay({@required int pageIndex}) {
    final delta = pageIndex - _previousPageIndex;

    switch (calendarFormat) {
      case CalendarFormat.month:
        return DateTime.utc(
            _focusedDay.value.year, _focusedDay.value.month + delta, delta == 0 ? _focusedDay.value.day : 1);
      case CalendarFormat.twoWeeks:
        final firstDay = visibleDays.firstWhere((day) => !_isExtraDay(day), orElse: () => _previousFirstDay);
        return DateTime.utc(firstDay.year, firstDay.month, firstDay.day + delta * 7);
      case CalendarFormat.week:
        return DateTime.utc(_focusedDay.value.year, _focusedDay.value.month, _focusedDay.value.day + delta * 7);
      default:
        assert(false);
        return null;
    }
  }

  void _updateFocusedDay({@required int pageIndex}) {
    _focusedDay.value = _getFocusedDay(pageIndex: pageIndex);
    _previousPageIndex = pageIndex;
  }

  void _selectPrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  void _selectNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  CalendarFormat _nextFormat() {
    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);
    id = (id + 1) % formats.length;

    return formats[id];
  }

  String _getFormatButtonText() => _useNextCalendarFormat
      ? _availableCalendarFormats[_nextFormat()]
      : _availableCalendarFormats[_calendarFormat.value];

  DateTime _getFirstDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return _firstDayOfMonth(_focusedDay.value);
    } else {
      return _visibleDays.first;
    }
  }

  DateTime _getLastDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return _lastDayOfMonth(_focusedDay.value);
    } else {
      return _visibleDays.last;
    }
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = _firstDayOfMonth(month);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = _lastDayOfMonth(month);
    final daysAfter = _getDaysAfter(last);

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return _daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - _getWeekdayNumber(_startingDayOfWeek)) % 7;
  }

  int _getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday = 8 - _getWeekdayNumber(_startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7) + 1;
    if (daysAfter == 8) {
      daysAfter = 1;
    }

    return daysAfter;
  }

  List<DateTime> _daysInWeek(DateTime week) {
    final first = _firstDayOfWeek(week);
    final last = _lastDayOfWeek(week);

    return _daysInRange(first, last).toList();
  }

  DateTime _firstDayOfWeek(DateTime day) {
    day = _normalizeDate(day);

    final decreaseNum = _getDaysBefore(day);
    return day.subtract(Duration(days: decreaseNum));
  }

  DateTime _lastDayOfWeek(DateTime day) {
    day = _normalizeDate(day);

    final increaseNum = _getDaysBefore(day);
    return day.add(Duration(days: 7 - increaseNum));
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1, 12);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date =
        month.month < 12 ? DateTime.utc(month.year, month.month + 1, 1, 12) : DateTime.utc(month.year + 1, 1, 1, 12);
    return date.subtract(const Duration(days: 1));
  }

  Iterable<DateTime> _daysInRange(DateTime firstDay, DateTime lastDay) sync* {
    var temp = firstDay;

    while (temp.isBefore(lastDay)) {
      yield _normalizeDate(temp);
      temp = temp.add(const Duration(days: 1));
    }
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day, 12);
  }

  /// Returns true if `day` is currently selected.
  bool isSelected(DateTime day) {
    return isSameDay(day, selectedDay);
  }

  /// Returns true if `day` is the same day as `DateTime.now()`.
  bool isToday(DateTime day) {
    return isSameDay(day, DateTime.now());
  }

  /// Returns true if `dayA` is the same day as `dayB`.
  bool isSameDay(DateTime dayA, DateTime dayB) {
    if (dayA == null || dayB == null) {
      return false;
    }

    return dayA.year == dayB.year && dayA.month == dayB.month && dayA.day == dayB.day;
  }

  bool _isWeekend(DateTime day, List<int> weekendDays) {
    return weekendDays.contains(day.weekday);
  }

  bool _isExtraDay(DateTime day) {
    return _isExtraDayBefore(day) || _isExtraDayAfter(day);
  }

  bool _isExtraDayBefore(DateTime day) {
    return day.month < _focusedDay.value.month;
  }

  bool _isExtraDayAfter(DateTime day) {
    return day.month > _focusedDay.value.month;
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
