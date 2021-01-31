// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

part of table_calendar;

typedef OnDaySelected = void Function(
    DateTime selectedDay, DateTime focusedDay);

typedef OnRangeSelected = void Function(
    DateTime start, DateTime end, DateTime focusedDay);

enum RangeSelectionMode {
  disable, // always off
  toggledOff, // currently off, can be toggled
  toggledOn, // currently on, can be toggled
  enforced, // always on
}

class TableCalendarLite extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final DayBuilder dowBuilder;
  final FocusedDayBuilder dayBuilder;
  final double dowHeight;
  final double rowHeight;
  final bool dowVisible;
  final bool pageJumpingEnabled;
  final Decoration dowDecoration;
  final Decoration rowDecoration;
  final StartingDayOfWeek startingDayOfWeek;
  final AvailableGestures availableGestures;
  final SimpleSwipeConfig simpleSwipeConfig;
  final HitTestBehavior dayHitTestBehavior;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final RangeSelectionMode rangeSelectionMode;
  final OnDaySelected onDaySelected;
  final OnRangeSelected onRangeSelected;
  final bool Function(DateTime day) enabledDayPredicate;
  final void Function(CalendarFormat format) onFormatChanged;
  final void Function(DateTime focusedDay) onPageChanged;
  final void Function(DateTime day) onDisabledDayTapped;
  final void Function(DateTime day) onDisabledDayLongPressed;
  final void Function(PageController pageController) onCalendarCreated;

  const TableCalendarLite({
    Key key,
    @required this.firstDay,
    @required this.lastDay,
    @required this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
    this.dowBuilder,
    @required this.dayBuilder,
    this.dowHeight,
    @required this.rowHeight,
    this.dowVisible = true,
    this.pageJumpingEnabled = false,
    this.dowDecoration,
    this.rowDecoration,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.dayHitTestBehavior = HitTestBehavior.deferToChild,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.rangeSelectionMode,
    this.onDaySelected,
    this.onRangeSelected,
    this.enabledDayPredicate,
    this.onFormatChanged,
    this.onPageChanged,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onCalendarCreated,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(dayBuilder != null),
        assert(rowHeight != null),
        assert(firstDay != null),
        assert(lastDay != null),
        assert(focusedDay != null),
        super(key: key);

  @override
  _TableCalendarLiteState createState() => _TableCalendarLiteState();
}

class _TableCalendarLiteState extends State<TableCalendarLite> {
  DateTime _focusedDay;
  DateTime _firstSelectedDay;
  RangeSelectionMode _rangeSelectionMode;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _rangeSelectionMode =
        widget.rangeSelectionMode ?? RangeSelectionMode.toggledOff;
  }

  @override
  void didUpdateWidget(TableCalendarLite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_focusedDay != widget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }

    if (widget.rangeSelectionMode != null &&
        _rangeSelectionMode != widget.rangeSelectionMode) {
      _rangeSelectionMode = widget.rangeSelectionMode;
    }
  }

  bool get _isRangeSelectionToggleable =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn ||
      _rangeSelectionMode == RangeSelectionMode.toggledOff;

  bool get _isRangeSelectionOn =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn ||
      _rangeSelectionMode == RangeSelectionMode.enforced;

  void _swipeCalendarFormat(SwipeDirection direction) {
    if (widget.onFormatChanged != null) {
      final formats = widget.availableCalendarFormats.keys.toList();

      final isSwipeUp = direction == SwipeDirection.up;
      int id = formats.indexOf(widget.calendarFormat);

      // Order of CalendarFormats must be from biggest to smallest,
      // e.g.: [month, twoWeeks, week]
      if (isSwipeUp) {
        id = min(formats.length - 1, id + 1);
      } else {
        id = max(0, id - 1);
      }

      widget.onFormatChanged(formats[id]);
    }
  }

  void _onDaySelected(DateTime day) {
    if (_isDayDisabled(day)) {
      return widget.onDisabledDayTapped?.call(day);
    }

    _updateFocusOnTap(day);

    if (_isRangeSelectionOn) {
      if (_firstSelectedDay == null) {
        _firstSelectedDay = day;
        widget.onRangeSelected?.call(_firstSelectedDay, null, _focusedDay);
      } else {
        if (day.isAfter(_firstSelectedDay)) {
          widget.onRangeSelected?.call(_firstSelectedDay, day, _focusedDay);
          _firstSelectedDay = null;
        } else if (day.isBefore(_firstSelectedDay)) {
          widget.onRangeSelected?.call(day, _firstSelectedDay, _focusedDay);
          _firstSelectedDay = null;
        }
      }
    } else {
      widget.onDaySelected?.call(day, _focusedDay);
    }
  }

  void _onLongPress(DateTime day) {
    if (_isDayDisabled(day)) {
      return widget.onDisabledDayLongPressed?.call(day);
    }

    if (widget.onRangeSelected != null) {
      if (_isRangeSelectionToggleable) {
        _updateFocusOnTap(day);
        _toggleRangeSelection();

        if (_isRangeSelectionOn) {
          _firstSelectedDay = day;
          widget.onRangeSelected(_firstSelectedDay, null, _focusedDay);
        } else {
          _firstSelectedDay = null;
          widget.onDaySelected?.call(day, _focusedDay);
        }
      }
    }
  }

  void _updateFocusOnTap(DateTime day) {
    if (widget.pageJumpingEnabled) {
      _focusedDay = day;
      return;
    }

    if (widget.calendarFormat == CalendarFormat.month) {
      if (_isBeforeMonth(day, _focusedDay)) {
        _focusedDay = _firstDayOfMonth(_focusedDay);
      } else if (_isAfterMonth(day, _focusedDay)) {
        _focusedDay = _lastDayOfMonth(_focusedDay);
      } else {
        _focusedDay = day;
      }
    } else {
      _focusedDay = day;
    }
  }

  void _toggleRangeSelection() {
    if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    } else {
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendarBase(
      availableCalendarFormats: widget.availableCalendarFormats,
      simpleSwipeConfig: widget.simpleSwipeConfig,
      onCalendarCreated: widget.onCalendarCreated,
      focusedDay: _focusedDay,
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      startingDayOfWeek: widget.startingDayOfWeek,
      availableGestures: widget.availableGestures,
      calendarFormat: widget.calendarFormat,
      onVerticalSwipe: _swipeCalendarFormat,
      onPageChanged: (focusedMonth) {
        _focusedDay = focusedMonth;
        widget.onPageChanged?.call(focusedMonth);
      },
      dowVisible: widget.dowVisible,
      dowDecoration: widget.dowDecoration,
      rowDecoration: widget.rowDecoration,
      dowHeight: widget.dowHeight,
      dowBuilder: widget.dowBuilder,
      rowHeight: widget.rowHeight,
      dayBuilder: (context, day, focusedMonth) {
        return GestureDetector(
          behavior: widget.dayHitTestBehavior,
          onTap: () => _onDaySelected(day),
          onLongPress: () => _onLongPress(day),
          child: widget.dayBuilder(context, day, focusedMonth),
        );
      },
    );
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1)
        : DateTime.utc(month.year + 1, 1, 1);
    return date.subtract(const Duration(days: 1));
  }

  bool _isDayDisabled(DateTime day) {
    return day.isBefore(widget.firstDay) ||
        day.isAfter(widget.lastDay) ||
        !_isDayAvailable(day);
  }

  bool _isDayAvailable(DateTime day) {
    return widget.enabledDayPredicate == null
        ? true
        : widget.enabledDayPredicate(day);
  }

  bool _isBeforeMonth(DateTime day, DateTime month) {
    if (day.year == month.year) {
      return day.month < month.month;
    } else {
      return day.isBefore(month);
    }
  }

  bool _isAfterMonth(DateTime day, DateTime month) {
    if (day.year == month.year) {
      return day.month > month.month;
    } else {
      return day.isAfter(month);
    }
  }
}
