// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

part of table_calendar;

/// Highly customizable, feature-packed Flutter Calendar with gestures, animations and multiple formats.
class TableCalendar<T> extends StatefulWidget {
  /// Locale to format `TableCalendar` dates with, for example: `'en_US'`.
  ///
  /// If nothing is provided, a default locale will be used.
  final dynamic locale;

  /// The start of the selected day range.
  final DateTime rangeStartDay;

  /// The end of the selected day range.
  final DateTime rangeEndDay;

  /// DateTime that determines which days are currently visible and focused.
  final DateTime focusedDay;

  /// The first active day of `TableCalendar`.
  /// Blocks swiping to days before it.
  ///
  /// Days before it will use `disabledStyle` and trigger `onDisabledDayTapped` callback.
  final DateTime firstDay;

  /// The last active day of `TableCalendar`.
  /// Blocks swiping to days after it.
  ///
  /// Days after it will use `disabledStyle` and trigger `onDisabledDayTapped` callback.
  final DateTime lastDay;

  /// List of days treated as weekend days.
  /// Use built-in `DateTime` weekday constants (e.g. `DateTime.monday`) instead of `int` literals (e.g. `1`).
  final List<int> weekendDays;

  /// Specifies `TableCalendar`'s current format.
  final CalendarFormat calendarFormat;

  /// `Map` of `CalendarFormat`s and `String` names associated with them.
  /// Those `CalendarFormat`s will be used by internal logic to manage displayed format.
  ///
  /// To ensure proper vertical swipe behavior, `CalendarFormat`s should be in descending order (i.e. from biggest to smallest).
  ///
  /// For example:
  /// ```dart
  /// availableCalendarFormats: const {
  ///   CalendarFormat.month: 'Month',
  ///   CalendarFormat.week: 'Week',
  /// }
  /// ```
  final Map<CalendarFormat, String> availableCalendarFormats;

  /// Determines the visibility of calendar header.
  final bool headerVisible;

  /// Determines the visibility of the row of days of the week.
  final bool daysOfWeekVisible;

  /// When set to true, tapping on an outside day in `CalendarFormat.month` format
  /// will jump to a page related to the tapped month.
  final bool pageJumpingEnabled;

  /// When set to true, `CalendarFormat.month` will always display six weeks,
  /// even if the content would fit in less.
  final bool sixWeekMonthsEnforced;

  /// When set to true, `TableCalendar` will fill available height.
  final bool shouldFillViewport;

  /// Used for setting the height of `TableCalendar`'s rows.
  final double rowHeight;

  /// Used for setting the height of `TableCalendar`'s days of week row.
  final double daysOfWeekHeight;

  /// `TableCalendar` will start weeks with provided day.
  /// Use `StartingDayOfWeek.monday` for Monday - Sunday week format.
  /// Use `StartingDayOfWeek.sunday` for Sunday - Saturday week format.
  final StartingDayOfWeek startingDayOfWeek;

  /// `HitTestBehavior` for every day cell inside `TableCalendar`.
  final HitTestBehavior dayHitTestBehavior;

  /// Specifies swipe gestures available to `TableCalendar`.
  /// If `AvailableGestures.none` is used, the calendar will only be interactive via buttons.
  final AvailableGestures availableGestures;

  /// Configuration for vertical swipe detector.
  final SimpleSwipeConfig simpleSwipeConfig;

  /// Style for `TableCalendar`'s header.
  final HeaderStyle headerStyle;

  /// Style for days of week displayed between `TableCalendar`'s header and content.
  final DaysOfWeekStyle daysOfWeekStyle;

  /// Style for `TableCalendar`'s content.
  final CalendarStyle calendarStyle;

  /// Set of custom builders for `TableCalendar` to work with.
  /// Use those to fully tailor the UI.
  final CalendarBuilders<T> calendarBuilders;

  /// Current mode of range selection.
  final RangeSelectionMode rangeSelectionMode;

  /// Called whenever a day range gets selected.
  final OnRangeSelected onRangeSelected;

  /// Function that assigns a list of events to a specified day.
  final List<T> Function(DateTime day) eventLoader;

  /// Function deciding whether given day should be enabled or not.
  /// If `false` is returned, this day will be disabled.
  final bool Function(DateTime day) enabledDayPredicate;

  /// Function deciding whether given day should be marked as selected.
  final bool Function(DateTime day) selectedDayPredicate;

  /// Function deciding whether given day is treated as a holiday.
  final bool Function(DateTime day) holidayPredicate;

  /// Called whenever any day gets tapped.
  final OnDaySelected onDaySelected;

  /// Called whenever any disabled day gets tapped.
  final void Function(DateTime day) onDisabledDayTapped;

  /// Called whenever any disabled day gets long pressed.
  final void Function(DateTime day) onDisabledDayLongPressed;

  /// Called whenever header gets tapped.
  final void Function(DateTime focusedDay) onHeaderTapped;

  /// Called whenever header gets long pressed.
  final void Function(DateTime focusedDay) onHeaderLongPressed;

  /// Called whenever currently visible calendar page is changed.
  final void Function(DateTime focusedDay) onPageChanged;

  /// Called whenever `calendarFormat` is changed.
  final void Function(CalendarFormat format) onFormatChanged;

  /// Called when the calendar is created. Exposes its PageController.
  final void Function(PageController pageController) onCalendarCreated;

  TableCalendar({
    Key key,
    this.locale,
    this.rangeStartDay,
    this.rangeEndDay,
    @required this.focusedDay,
    @required this.firstDay,
    @required this.lastDay,
    this.weekendDays = const [DateTime.saturday, DateTime.sunday],
    this.calendarFormat = CalendarFormat.month,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.headerVisible = true,
    this.daysOfWeekVisible = true,
    this.pageJumpingEnabled = false,
    this.sixWeekMonthsEnforced = false,
    this.shouldFillViewport = false,
    this.rowHeight = 52.0,
    this.daysOfWeekHeight = 16.0,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.dayHitTestBehavior = HitTestBehavior.deferToChild,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.headerStyle = const HeaderStyle(),
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.calendarStyle = const CalendarStyle(),
    this.calendarBuilders = const CalendarBuilders(),
    this.rangeSelectionMode,
    this.onRangeSelected,
    this.eventLoader,
    this.enabledDayPredicate,
    this.selectedDayPredicate,
    this.holidayPredicate,
    this.onDaySelected,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onHeaderTapped,
    this.onHeaderLongPressed,
    this.onPageChanged,
    this.onFormatChanged,
    this.onCalendarCreated,
  })  : assert(calendarFormat != null),
        assert(rowHeight != null),
        assert(firstDay != null),
        assert(lastDay != null),
        assert(focusedDay != null),
        assert(availableCalendarFormats.keys.contains(calendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        assert(weekendDays != null),
        assert(weekendDays.isNotEmpty
            ? weekendDays.every(
                (day) => day >= DateTime.monday && day <= DateTime.sunday)
            : true),
        super(key: key);

  @override
  _TableCalendarState<T> createState() => _TableCalendarState<T>();
}

class _TableCalendarState<T> extends State<TableCalendar<T>> {
  ValueNotifier<DateTime> _focusedDay;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _focusedDay = ValueNotifier(widget.focusedDay);
  }

  @override
  void didUpdateWidget(TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_focusedDay.value != widget.focusedDay) {
      _focusedDay.value = widget.focusedDay;
    }
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.headerVisible)
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedMonth: value,
                onLeftChevronTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                onRightChevronTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                onHeaderTap: () => widget.onHeaderTapped(value),
                onHeaderLongPress: () => widget.onHeaderLongPressed(value),
                headerStyle: widget.headerStyle,
                availableCalendarFormats: widget.availableCalendarFormats,
                calendarFormat: widget.calendarFormat,
                locale: widget.locale,
                onFormatButtonTap: (format) {
                  widget.onFormatChanged(format);
                },
              );
            },
          ),
        Flexible(
          flex: widget.shouldFillViewport ? 1 : 0,
          child: TableCalendarLite(
            onCalendarCreated: (pageController) {
              _pageController = pageController;
              widget.onCalendarCreated?.call(pageController);
            },
            focusedDay: _focusedDay.value,
            calendarFormat: widget.calendarFormat,
            availableGestures: widget.availableGestures,
            firstDay: widget.firstDay,
            lastDay: widget.lastDay,
            startingDayOfWeek: widget.startingDayOfWeek,
            dowDecoration: widget.daysOfWeekStyle.decoration,
            rowDecoration: widget.calendarStyle.rowDecoration,
            dowVisible: widget.daysOfWeekVisible,
            dowHeight: widget.daysOfWeekHeight,
            rowHeight: widget.rowHeight,
            availableCalendarFormats: widget.availableCalendarFormats,
            simpleSwipeConfig: widget.simpleSwipeConfig,
            dayHitTestBehavior: widget.dayHitTestBehavior,
            enabledDayPredicate: widget.enabledDayPredicate,
            rangeSelectionMode: widget.rangeSelectionMode,
            sixWeekMonthsEnforced: widget.sixWeekMonthsEnforced,
            pageJumpingEnabled: widget.pageJumpingEnabled,
            onDisabledDayTapped: widget.onDisabledDayTapped,
            onDisabledDayLongPressed: widget.onDisabledDayLongPressed,
            onDaySelected: (selectedDay, focusedDay) {
              _focusedDay.value = focusedDay;
              widget.onDaySelected?.call(selectedDay, focusedDay);
            },
            onRangeSelected: widget.onRangeSelected != null
                ? (start, end, focusedDay) {
                    _focusedDay.value = focusedDay;
                    widget.onRangeSelected(start, end, focusedDay);
                  }
                : null,
            onFormatChanged: (format) {
              widget.onFormatChanged?.call(format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay.value = focusedDay;
              widget.onPageChanged?.call(focusedDay);
            },
            dowBuilder: (BuildContext context, DateTime day) {
              Widget dowCell =
                  widget.calendarBuilders.dowBuilder?.call(context, day);

              if (dowCell == null) {
                final weekdayString = widget.daysOfWeekStyle.dowTextFormatter
                        ?.call(day, widget.locale) ??
                    DateFormat.E(widget.locale).format(day);

                final isWeekend =
                    _isWeekend(day, weekendDays: widget.weekendDays);

                dowCell = Center(
                  child: Text(
                    weekdayString,
                    style: isWeekend
                        ? widget.daysOfWeekStyle.weekendStyle
                        : widget.daysOfWeekStyle.weekdayStyle,
                  ),
                );
              }

              return dowCell;
            },
            dayBuilder: (context, day, focusedMonth) {
              return _buildCell(day, focusedMonth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCell(DateTime date, DateTime focusedDay) {
    final isOutside = date.month != focusedDay.month;

    if (isOutside &&
        !widget.calendarStyle.outsideDaysVisible &&
        widget.calendarFormat == CalendarFormat.month) {
      return Container();
    }

    final children = <Widget>[];

    final isWithinRange = widget.rangeStartDay != null &&
        widget.rangeEndDay != null &&
        _isWithinRange(date, widget.rangeStartDay, widget.rangeEndDay);

    final isRangeStart = isSameDay(date, widget.rangeStartDay);
    final isRangeEnd = isSameDay(date, widget.rangeEndDay);

    final startOffset =
        widget.calendarStyle.rangeFillOffset.start ?? widget.rowHeight / 2;

    final endOffset =
        widget.calendarStyle.rangeFillOffset.end ?? widget.rowHeight / 2;

    final rangeColor = isWithinRange
        ? widget.calendarStyle.rangeFillColor
        : Colors.transparent;

    children.add(
      PositionedDirectional(
        top: widget.calendarStyle.rangeFillOffset.top,
        bottom: widget.calendarStyle.rangeFillOffset.bottom,
        start: isRangeStart ? startOffset : 0.0,
        end: isRangeEnd ? endOffset : 0.0,
        child: Container(color: rangeColor),
      ),
    );

    final isToday = isSameDay(date, DateTime.now());
    final isDisabled = _isDayDisabled(date);
    final isWeekend = _isWeekend(date, weekendDays: widget.weekendDays);

    Widget content = _CellContent(
      day: date,
      focusedDay: focusedDay,
      calendarStyle: widget.calendarStyle,
      calendarBuilders: widget.calendarBuilders,
      isTodayHighlighted: widget.calendarStyle.isTodayHighlighted,
      isToday: isToday,
      isSelected: widget.selectedDayPredicate?.call(date) ?? false,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
      isWithinRange: isWithinRange,
      isOutside: isOutside,
      isDisabled: isDisabled,
      isWeekend: isWeekend,
      isHoliday: widget.holidayPredicate?.call(date) ?? false,
    );

    children.add(content);

    if (!isDisabled) {
      final events = widget.eventLoader?.call(date) ?? [];
      Widget markerWidget =
          widget.calendarBuilders.markerBuilder?.call(context, date, events);

      if (events.isNotEmpty && markerWidget == null) {
        markerWidget = PositionedDirectional(
          top: widget.calendarStyle.markersOffset.top,
          bottom: widget.calendarStyle.markersOffset.bottom,
          start: widget.calendarStyle.markersOffset.start,
          end: widget.calendarStyle.markersOffset.end,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: events
                .take(widget.calendarStyle.markersMaxAmount)
                .map((event) => _buildSingleMarker(date, event))
                .toList(),
          ),
        );
      }

      if (markerWidget != null) {
        children.add(markerWidget);
      }
    }

    if (children.length > 1) {
      content = Stack(
        alignment: widget.calendarStyle.markersAlignment,
        children: children,
        clipBehavior:
            widget.calendarStyle.canMarkersOverflow ? Clip.none : Clip.hardEdge,
      );
    }

    return content;
  }

  Widget _buildSingleMarker(DateTime date, T event) {
    return widget.calendarBuilders.singleMarkerBuilder
            ?.call(context, date, event) ??
        Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 0.3),
          decoration: widget.calendarStyle.markerDecoration,
        );
  }

  bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
    if (isSameDay(date, start) || isSameDay(date, end)) {
      return true;
    }

    if (date.isAfter(start) && date.isBefore(end)) {
      return true;
    }

    return false;
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

  bool _isWeekend(
    DateTime day, {
    List<int> weekendDays = const [DateTime.saturday, DateTime.sunday],
  }) {
    return weekendDays.contains(day.weekday);
  }
}
