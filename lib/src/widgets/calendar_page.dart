//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

class _CalendarPage<T> extends StatefulWidget {
  final DateTime baseDay;
  final DateTime focusedDay;
  final dynamic locale;
  final double rowHeight;
  final CalendarController<T> calendarController;
  final CalendarStyle calendarStyle;
  final CalendarBuilders<T> builders;
  final DaysOfWeekStyle daysOfWeekStyle;
  final HitTestBehavior dayHitTestBehavior;
  final Map<DateTime, List<T>> events;
  final Map<DateTime, List<T>> holidays;
  final DateTime startDay;
  final DateTime endDay;
  final List<int> weekendDays;
  final OnDaySelected<T> onDaySelected;
  final OnDaySelected<T> onDayLongPressed;
  final VoidCallback onUnavailableDaySelected;
  final VoidCallback onUnavailableDayLongPressed;
  final EnabledDayPredicate enabledDayPredicate;

  const _CalendarPage({
    Key key,
    @required this.baseDay,
    @required this.focusedDay,
    @required this.locale,
    @required this.rowHeight,
    @required this.calendarController,
    @required this.calendarStyle,
    @required this.builders,
    @required this.daysOfWeekStyle,
    @required this.dayHitTestBehavior,
    @required this.events,
    @required this.holidays,
    @required this.startDay,
    @required this.endDay,
    @required this.weekendDays,
    @required this.onDaySelected,
    @required this.onDayLongPressed,
    @required this.onUnavailableDaySelected,
    @required this.onUnavailableDayLongPressed,
    @required this.enabledDayPredicate,
  }) : super(key: key);

  @override
  _CalendarPageState<T> createState() => _CalendarPageState<T>();
}

class _CalendarPageState<T> extends State<_CalendarPage<T>> {
  DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(_CalendarPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _focusedDay = widget.focusedDay;
  }

  void _selectDay(DateTime day) {
    widget.calendarController._selectedDay = day;
    _selectedDayCallback(day);

    if (widget.calendarController.calendarFormat == CalendarFormat.month) {
      final int previousMonth = widget.calendarController._focusedDay.value.month;

      if (day.month < previousMonth) {
        widget.calendarController.previousPage();
        return;
      } else if (day.month > previousMonth) {
        widget.calendarController.nextPage();
        return;
      }
    }

    widget.calendarController._focusedDay.value = day;
    _focusedDay = day;

    setState(() {});
  }

  void _selectedDayCallback(DateTime day) {
    if (widget.onDaySelected != null) {
      widget.onDaySelected(day, widget.events[_getEventKey(day)] ?? []);
    }
  }

  void _onDayLongPressed(DateTime day) {
    if (widget.onDayLongPressed != null) {
      widget.onDayLongPressed(day, widget.events[_getEventKey(day)] ?? []);
    }
  }

  void _onUnavailableDaySelected() {
    if (widget.onUnavailableDaySelected != null) {
      widget.onUnavailableDaySelected();
    }
  }

  void _onUnavailableDayLongPressed() {
    if (widget.onUnavailableDayLongPressed != null) {
      widget.onUnavailableDayLongPressed();
    }
  }

  bool _isDayUnavailable(DateTime day) {
    return (widget.startDay != null && day.isBefore(widget.calendarController._normalizeDate(widget.startDay))) ||
        (widget.endDay != null && day.isAfter(widget.calendarController._normalizeDate(widget.endDay))) ||
        (!_isDayEnabled(day));
  }

  bool _isDayEnabled(DateTime day) {
    return widget.enabledDayPredicate == null ? true : widget.enabledDayPredicate(day);
  }

  DateTime _getEventKey(DateTime day) {
    return widget.events.keys.firstWhere((it) => widget.calendarController.isSameDay(it, day), orElse: () => null);
  }

  DateTime _getHolidayKey(DateTime day) {
    return widget.holidays.keys.firstWhere((it) => widget.calendarController.isSameDay(it, day), orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = 7;
    final days = widget.calendarController._getVisibleDays(widget.baseDay);

    final children = <TableRow>[
      if (widget.calendarStyle.renderDaysOfWeek) _buildDaysOfWeek(days.take(daysInWeek).toList()),
    ];

    int x = 0;
    while (x < days.length) {
      children.add(_buildTableRow(days.skip(x).take(daysInWeek).toList(), _focusedDay));
      x += daysInWeek;
    }

    return Table(
      defaultColumnWidth: FractionColumnWidth(1.0 / daysInWeek),
      children: children,
    );
  }

  TableRow _buildDaysOfWeek(List<DateTime> days) {
    return TableRow(
      children: days.map((date) {
        final weekdayString = widget.daysOfWeekStyle.dowTextBuilder != null
            ? widget.daysOfWeekStyle.dowTextBuilder(date, widget.locale)
            : DateFormat.E(widget.locale).format(date);
        final isWeekend = widget.calendarController._isWeekend(date, widget.weekendDays);

        if (isWeekend && widget.builders.dowWeekendBuilder != null) {
          return widget.builders.dowWeekendBuilder(context, weekdayString);
        }
        if (widget.builders.dowWeekdayBuilder != null) {
          return widget.builders.dowWeekdayBuilder(context, weekdayString);
        }
        return Center(
          child: Text(
            weekdayString,
            style: isWeekend ? widget.daysOfWeekStyle.weekendStyle : widget.daysOfWeekStyle.weekdayStyle,
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<DateTime> days, DateTime focusedDay) {
    return TableRow(
      children: days.map(
        (date) {
          return SizedBox(
            height: widget.rowHeight,
            child: _buildCell(date, focusedDay),
          );
        },
      ).toList(),
    );
  }

  Widget _buildCell(DateTime date, DateTime focusedDay) {
    if (!widget.calendarStyle.outsideDaysVisible &&
        (date.month < focusedDay.month || date.month > focusedDay.month) &&
        widget.calendarController.calendarFormat == CalendarFormat.month) {
      return Container();
    }

    Widget content = _buildCellContent(date, focusedDay);

    final eventKey = _getEventKey(date);
    final holidayKey = _getHolidayKey(date);
    final key = eventKey ?? holidayKey;

    if (key != null) {
      final children = <Widget>[content];
      final List<T> events = eventKey != null ? widget.events[eventKey] : [];
      final List<T> holidays = holidayKey != null ? widget.holidays[holidayKey] : [];

      if (!_isDayUnavailable(date)) {
        if (widget.builders.markersBuilder != null) {
          children.addAll(
            widget.builders.markersBuilder(
              context,
              key,
              events,
              holidays,
            ),
          );
        } else {
          children.add(
            Positioned(
              top: widget.calendarStyle.markersPositionTop,
              bottom: widget.calendarStyle.markersPositionBottom,
              left: widget.calendarStyle.markersPositionLeft,
              right: widget.calendarStyle.markersPositionRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events
                    .take(widget.calendarStyle.markersMaxAmount)
                    .map((event) => _buildMarker(eventKey, event))
                    .toList(),
              ),
            ),
          );
        }
      }

      if (children.length > 1) {
        content = Stack(
          alignment: widget.calendarStyle.markersAlignment,
          children: children,
          overflow: widget.calendarStyle.canEventMarkersOverflow ? Overflow.visible : Overflow.clip,
        );
      }
    }

    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _isDayUnavailable(date) ? _onUnavailableDaySelected() : _selectDay(date),
      onLongPress: () => _isDayUnavailable(date) ? _onUnavailableDayLongPressed() : _onDayLongPressed(date),
      child: content,
    );
  }

  Widget _buildCellContent(DateTime date, DateTime focusedDay) {
    final eventKey = _getEventKey(date);

    final tIsUnavailable = _isDayUnavailable(date);
    final tIsSelected = widget.calendarController.isSelected(date);
    final tIsToday = widget.calendarController.isToday(date);
    final tIsOutside = date.month < focusedDay.month || date.month > focusedDay.month;
    final tIsHoliday = widget.holidays.containsKey(_getHolidayKey(date));
    final tIsWeekend = widget.calendarController._isWeekend(date, widget.weekendDays);

    final isUnavailable = widget.builders.unavailableDayBuilder != null && tIsUnavailable;
    final isSelected = widget.builders.selectedDayBuilder != null && tIsSelected;
    final isToday = widget.builders.todayDayBuilder != null && tIsToday;
    final isOutsideHoliday = widget.builders.outsideHolidayDayBuilder != null && tIsOutside && tIsHoliday;
    final isHoliday = widget.builders.holidayDayBuilder != null && !tIsOutside && tIsHoliday;
    final isOutsideWeekend =
        widget.builders.outsideWeekendDayBuilder != null && tIsOutside && tIsWeekend && !tIsHoliday;
    final isOutside = widget.builders.outsideDayBuilder != null && tIsOutside && !tIsWeekend && !tIsHoliday;
    final isWeekend = widget.builders.weekendDayBuilder != null && !tIsOutside && tIsWeekend && !tIsHoliday;

    if (isUnavailable) {
      return widget.builders.unavailableDayBuilder(context, date, widget.events[eventKey]);
    } else if (isSelected && widget.calendarStyle.renderSelectedFirst) {
      return widget.builders.selectedDayBuilder(context, date, widget.events[eventKey]);
    } else if (isToday) {
      return widget.builders.todayDayBuilder(context, date, widget.events[eventKey]);
    } else if (isSelected) {
      return widget.builders.selectedDayBuilder(context, date, widget.events[eventKey]);
    } else if (isOutsideHoliday) {
      return widget.builders.outsideHolidayDayBuilder(context, date, widget.events[eventKey]);
    } else if (isHoliday) {
      return widget.builders.holidayDayBuilder(context, date, widget.events[eventKey]);
    } else if (isOutsideWeekend) {
      return widget.builders.outsideWeekendDayBuilder(context, date, widget.events[eventKey]);
    } else if (isOutside) {
      return widget.builders.outsideDayBuilder(context, date, widget.events[eventKey]);
    } else if (isWeekend) {
      return widget.builders.weekendDayBuilder(context, date, widget.events[eventKey]);
    } else if (widget.builders.dayBuilder != null) {
      return widget.builders.dayBuilder(context, date, widget.events[eventKey]);
    } else {
      return _CellWidget(
        text: '${date.day}',
        isUnavailable: tIsUnavailable,
        isSelected: tIsSelected,
        isToday: tIsToday,
        isWeekend: tIsWeekend,
        isOutsideMonth: tIsOutside,
        isHoliday: tIsHoliday,
        calendarStyle: widget.calendarStyle,
      );
    }
  }

  Widget _buildMarker(DateTime date, T event) {
    if (widget.builders.singleMarkerBuilder != null) {
      return widget.builders.singleMarkerBuilder(context, date, event);
    } else {
      return Container(
        width: 8.0,
        height: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 0.3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.calendarStyle.markersColor,
        ),
      );
    }
  }
}
