//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

const double _dxMax = 1.2;
const double _dxMin = -1.2;

typedef void _SelectedDayCallback(DateTime day);

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
  DateTime get focusedDay => _focusedDay;

  /// Currently selected day.
  DateTime get selectedDay => _selectedDay;

  /// Currently visible calendar format.
  CalendarFormat get calendarFormat => _calendarFormat.value;

  /// List of currently visible days.
  List<DateTime> get visibleDays =>
      _includeInvisibleDays ? _visibleDays.value : _visibleDays.value.where((day) => !_isExtraDay(day)).toList();

  /// Map of currently visible events.
  Map<DateTime, List> get visibleEvents => Map.fromEntries(
        _events.entries.where((entry) {
          for (final day in visibleDays) {
            if (Utils.isSameDay(day, entry.key)) {
              return true;
            }
          }

          return false;
        }),
      );

  /// Map of currently visible holidays.
  Map<DateTime, List> get visibleHolidays => Map.fromEntries(
        _holidays.entries.where((entry) {
          for (final day in visibleDays) {
            if (Utils.isSameDay(day, entry.key)) {
              return true;
            }
          }

          return false;
        }),
      );

  Map<DateTime, List> _events;
  Map<DateTime, List> _holidays;
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
  bool _includeInvisibleDays;
  _SelectedDayCallback _selectedDayCallback;

  void _init({
    @required Map<DateTime, List> events,
    @required Map<DateTime, List> holidays,
    @required DateTime initialDay,
    @required CalendarFormat initialFormat,
    @required Map<CalendarFormat, String> availableCalendarFormats,
    @required bool useNextCalendarFormat,
    @required StartingDayOfWeek startingDayOfWeek,
    @required _SelectedDayCallback selectedDayCallback,
    @required OnVisibleDaysChanged onVisibleDaysChanged,
    @required bool includeInvisibleDays,
  }) {
    _events = events;
    _holidays = holidays;
    _availableCalendarFormats = availableCalendarFormats;
    _startingDayOfWeek = startingDayOfWeek;
    _useNextCalendarFormat = useNextCalendarFormat;
    _selectedDayCallback = selectedDayCallback;
    _includeInvisibleDays = includeInvisibleDays;

    _pageId = 0;
    _dx = 0;

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
            _getFirstDay(includeInvisible: _includeInvisibleDays),
            _getLastDay(includeInvisible: _includeInvisibleDays),
            _calendarFormat.value,
          );
        }
      });
    }
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
    _calendarFormat.dispose();
    _visibleDays.dispose();
  }

  /// Toggles calendar format. Same as using `FormatButton`.
  void toggleCalendarFormat() {
    _calendarFormat.value = _nextFormat();
  }

  /// Sets calendar format by emulating swipe.
  void swipeCalendarFormat({@required bool isSwipeUp}) {
    assert(isSwipeUp != null);

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

  /// Sets calendar format to a given `value`.
  void setCalendarFormat(CalendarFormat value) {
    _calendarFormat.value = value;
  }

  /// Sets selected day to a given `value`.
  /// Use `runCallback: true` if this should trigger `OnDaySelected` callback.
  void setSelectedDay(
    DateTime value, {
    bool isProgrammatic = true,
    bool animate = true,
    bool runCallback = false,
  }) {
    if (animate) {
      if (value.isBefore(_getFirstDay(includeInvisible: false))) {
        _decrementPage();
      } else if (value.isAfter(_getLastDay(includeInvisible: false))) {
        _incrementPage();
      }
    }

    _selectedDay = value;
    _focusedDay = value;
    _updateVisibleDays(isProgrammatic);

    if (isProgrammatic && runCallback && _selectedDayCallback != null) {
      _selectedDayCallback(value);
    }
  }

  /// Sets displayed month/year without changing the currently selected day.
  void setFocusedDay(DateTime value) {
    _focusedDay = value;
    _updateVisibleDays(true);
  }

  void _updateVisibleDays(bool isProgrammatic) {
    if (calendarFormat != CalendarFormat.twoWeeks || isProgrammatic) {
      _visibleDays.value = _getVisibleDays();
    }
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

  void _selectPrevious() {
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

  void _selectNext() {
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
      return _firstDayOfMonth(_focusedDay);
    } else {
      return _visibleDays.value.first;
    }
  }

  DateTime _getLastDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return _lastDayOfMonth(_focusedDay);
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
    final first = _firstDayOfMonth(month);
    final daysBefore = _startingDayOfWeek == StartingDayOfWeek.sunday ? first.weekday % 7 : first.weekday - 1;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = _lastDayOfMonth(month);
    var daysAfter = 7 - last.weekday;

    if (_startingDayOfWeek == StartingDayOfWeek.sunday) {
      // If the last day is Sunday (7) the entire week must be rendered
      if (daysAfter == 0) {
        daysAfter = 7;
      }
    } else {
      daysAfter++;
    }

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  List<DateTime> _daysInWeek(DateTime week) {
    final first = _firstDayOfWeek(week);
    final last = _lastDayOfWeek(week);

    return Utils.daysInRange(first, last).toList();
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

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1, 12);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date =
        month.month < 12 ? DateTime.utc(month.year, month.month + 1, 1, 12) : DateTime.utc(month.year + 1, 1, 1, 12);
    return date.subtract(const Duration(days: 1));
  }

  /// Returns true if `day` is currently selected.
  bool isSelected(DateTime day) {
    return Utils.isSameDay(day, selectedDay);
  }

  /// Returns true if `day` is the same day as `DateTime.now()`.
  bool isToday(DateTime day) {
    return Utils.isSameDay(day, DateTime.now());
  }

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  bool _isExtraDay(DateTime day) {
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
