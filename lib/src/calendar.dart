//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

/// Callback exposing currently selected day.
typedef void OnDaySelected<T>(DateTime day, List<T> events, List<T> holidays);

/// Callback exposing currently focused day along with first and last visible day.
typedef void OnPageChanged(DateTime focusedDay, DateTime first, DateTime last);

/// Callback exposing currently used `CalendarFormat` along with first and last visible day.
typedef void OnFormatChanged(
    CalendarFormat format, DateTime first, DateTime last);

/// Callback exposing first and last initially visible day.
typedef void OnCalendarCreated(DateTime first, DateTime last);

/// Signature for reacting to header gestures. Exposes current month and year as a `DateTime` object.
typedef void HeaderGestureCallback(DateTime focusedDay);

/// Builder signature for any text that can be localized and formatted with `DateFormat`.
typedef String TextBuilder(DateTime date, dynamic locale);

/// Signature for enabling days.
typedef bool EnabledDayPredicate(DateTime day);

/// Format to display the `TableCalendar` with.
enum CalendarFormat { month, twoWeeks, week }

/// Gestures available to `TableCalendar`.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

/// Available day of week formats. `TableCalendar` will start the week with chosen day.
/// * `StartingDayOfWeek.monday`: Monday - Sunday
/// * `StartingDayOfWeek.tuesday`: Tuesday - Monday
/// * `StartingDayOfWeek.wednesday`: Wednesday - Tuesday
/// * `StartingDayOfWeek.thursday`: Thursday - Wednesday
/// * `StartingDayOfWeek.friday`: Friday - Thursday
/// * `StartingDayOfWeek.saturday`: Saturday - Friday
/// * `StartingDayOfWeek.sunday`: Sunday - Saturday
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

int _getWeekdayNumber(StartingDayOfWeek weekday) {
  return StartingDayOfWeek.values.indexOf(weekday) + 1;
}

const int _initialPage = 10000;

/// Highly customizable, feature-packed Flutter Calendar with gestures, animations and multiple formats.
class TableCalendar<T> extends StatefulWidget {
  /// Locale to format `TableCalendar` dates with, for example: `'en_US'`.
  ///
  /// If nothing is provided, a default locale will be used.
  final dynamic locale;

  /// `Map` of events.
  /// Each `DateTime` inside this `Map` should get its own `List` of objects (i.e. events).
  ///
  /// Use of `LinkedHashMap` is highly encouraged.
  final Map<DateTime, List<T>> events;

  /// `Map` of holidays.
  /// This property allows you to provide custom holiday rules.
  ///
  /// Use of `LinkedHashMap` is highly encouraged.
  final Map<DateTime, List<T>> holidays;

  /// Called whenever any day gets tapped.
  final OnDaySelected<T> onDaySelected;

  /// Called whenever any day gets long pressed.
  final OnDaySelected<T> onDayLongPressed;

  /// Called whenever any unavailable day gets tapped.
  /// Replaces `onDaySelected` for those days.
  final Function(DateTime) onUnavailableDaySelected;

  /// Called whenever any unavailable day gets long pressed.
  /// Replaces `onDaySelected` for those days.
  final Function(DateTime) onUnavailableDayLongPressed;

  /// Called whenever header gets tapped.
  final HeaderGestureCallback onHeaderTapped;

  /// Called whenever header gets long pressed.
  final HeaderGestureCallback onHeaderLongPressed;

  /// Called whenever currently visible calendar page is changed.
  final OnPageChanged onPageChanged;

  /// Called whenever `calendarFormat` is changed.
  final OnFormatChanged onFormatChanged;

  /// Called once when the `TableCalendar` widget gets initialized.
  final OnCalendarCreated onCalendarCreated;

  /// DateTime to highlight as currently selected.
  final DateTime selectedDay;

  /// DateTime that determines which days are currently visible and focused.
  final DateTime focusedDay;

  /// The first day of `TableCalendar`.
  /// Days before it will use `unavailableStyle` and run `onUnavailableDaySelected` callback.
  final DateTime startDay;

  /// The last day of `TableCalendar`.
  /// Days after it will use `unavailableStyle` and run `onUnavailableDaySelected` callback.
  final DateTime endDay;

  /// List of days treated as weekend days.
  /// Use built-in `DateTime` weekday constants (e.g. `DateTime.monday`) instead of `int` literals (e.g. `1`).
  final List<int> weekendDays;

  /// Specifies `TableCalendar`'s format.
  final CalendarFormat calendarFormat;

  /// `Map` of `CalendarFormat`s and `String` names associated with them.
  /// Those `CalendarFormat`s will be used by internal logic to manage displayed format.
  ///
  /// To ensure proper vertical Swipe behavior, `CalendarFormat`s should be in descending order (i.e. from biggest to smallest).
  ///
  /// For example:
  /// ```dart
  /// availableCalendarFormats: const {
  ///   CalendarFormat.month: 'Month',
  ///   CalendarFormat.week: 'Week',
  /// }
  /// ```
  final Map<CalendarFormat, String> availableCalendarFormats;

  /// Determines whether calendar header should be visible.
  final bool headerVisible;

  /// Determines whether the row of days of the week should be visible.
  final bool daysOfWeekVisible;

  /// Function deciding whether given day should be enabled or not.
  /// If `false` is returned, this day will be unavailable.
  final EnabledDayPredicate enabledDayPredicate;

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

  /// Specifies gestures available to `TableCalendar`.
  /// If `AvailableGestures.none` is used, the calendar will only be interactive via buttons.
  final AvailableGestures availableGestures;

  /// Configuration for vertical Swipe detector.
  final SimpleSwipeConfig simpleSwipeConfig;

  /// Style for `TableCalendar`'s content.
  final CalendarStyle calendarStyle;

  /// Style for DaysOfWeek displayed between `TableCalendar`'s Header and content.
  final DaysOfWeekStyle daysOfWeekStyle;

  /// Style for `TableCalendar`'s Header.
  final HeaderStyle headerStyle;

  /// Set of Builders for `TableCalendar` to work with.
  final CalendarBuilders<T> builders;

  TableCalendar({
    Key key,
    this.locale,
    this.events = const {},
    this.holidays = const {},
    this.onDaySelected,
    this.onDayLongPressed,
    this.onUnavailableDaySelected,
    this.onUnavailableDayLongPressed,
    this.onHeaderTapped,
    this.onHeaderLongPressed,
    this.onPageChanged,
    this.onFormatChanged,
    this.onCalendarCreated,
    this.selectedDay,
    this.focusedDay,
    this.startDay,
    this.endDay,
    this.weekendDays = const [DateTime.saturday, DateTime.sunday],
    this.calendarFormat = CalendarFormat.month,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.headerVisible = true,
    this.daysOfWeekVisible = true,
    this.enabledDayPredicate,
    this.rowHeight = 52.0,
    this.daysOfWeekHeight = 16.0,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.dayHitTestBehavior = HitTestBehavior.deferToChild,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.calendarStyle = const CalendarStyle(),
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.headerStyle = const HeaderStyle(),
    this.builders = const CalendarBuilders(),
  })  : assert(calendarFormat != null),
        assert(availableCalendarFormats.keys.contains(calendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        assert(weekendDays != null),
        assert(weekendDays.isNotEmpty
            ? weekendDays.every(
                (day) => day >= DateTime.monday && day <= DateTime.sunday)
            : true),
        super(key: key);

  @override
  TableCalendarState<T> createState() => TableCalendarState<T>();
}

class TableCalendarState<T> extends State<TableCalendar<T>>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  CalendarFormat _calendarFormat;
  ValueNotifier<double> _calendarHeight;
  ValueNotifier<DateTime> _focusedDay;
  DateTime _selectedDay;
  DateTime _baseDay;
  DateTime _firstActiveDay;
  DateTime _lastActiveDay;
  int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);

    final now = DateTime.now();
    _baseDay = widget.focusedDay ?? DateTime.utc(now.year, now.month, now.day);
    _focusedDay = ValueNotifier(_baseDay);
    _selectedDay = widget.selectedDay;

    _pageIndex = _initialPage;
    _calendarFormat = widget.calendarFormat;

    final days = _getVisibleDays(_baseDay);

    if (_calendarFormat == CalendarFormat.month) {
      _firstActiveDay = _firstDayOfMonth(_baseDay);
      _lastActiveDay = _lastDayOfMonth(_baseDay);
    } else {
      _firstActiveDay = days.first;
      _lastActiveDay = days.last;
    }

    _calendarHeight = ValueNotifier(_getPageHeight(dayCount: days.length));

    if (widget.onCalendarCreated != null) {
      if (!widget.calendarStyle.outsideDaysVisible &&
          _calendarFormat == CalendarFormat.month) {
        widget.onCalendarCreated(
            _firstDayOfMonth(_baseDay), _lastDayOfMonth(_baseDay));
      } else {
        widget.onCalendarCreated(days.first, days.last);
      }
    }
  }

  @override
  void didUpdateWidget(TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDay == null) {
      _selectedDay = null;
    } else {
      if (_selectedDay != widget.selectedDay) {
        final day = widget.selectedDay;
        _selectedDay = day;

        if (widget.onDaySelected != null) {
          widget.onDaySelected(
            day,
            widget.events[day] ?? [],
            widget.holidays[day] ?? [],
          );
        }
      }
    }

    if (widget.focusedDay != null && _focusedDay.value != widget.focusedDay) {
      final day = widget.focusedDay;

      _focusedDay.value = day;
      _baseDay = day;
      _calendarHeight.value = _getPageHeight(baseDay: _baseDay);
    }

    if (_calendarFormat != widget.calendarFormat) {
      _calendarFormat = widget.calendarFormat;

      final days = _getVisibleDays(_baseDay);

      if (_calendarFormat == CalendarFormat.month) {
        _firstActiveDay = _firstDayOfMonth(_baseDay);
        _lastActiveDay = _lastDayOfMonth(_baseDay);
      } else {
        _firstActiveDay = days.first;
        _lastActiveDay = days.last;
      }

      _calendarHeight.value = _getPageHeight(dayCount: days.length);

      if (widget.onFormatChanged != null) {
        if (!widget.calendarStyle.outsideDaysVisible &&
            _calendarFormat == CalendarFormat.month) {
          widget.onFormatChanged(_calendarFormat, _firstDayOfMonth(_baseDay),
              _lastDayOfMonth(_baseDay));
        } else {
          widget.onFormatChanged(_calendarFormat, days.first, days.last);
        }
      }
    }

    if (oldWidget.rowHeight != widget.rowHeight ||
        oldWidget.daysOfWeekHeight != widget.daysOfWeekHeight) {
      _calendarHeight.value = _getPageHeight(baseDay: _baseDay);
    }
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _calendarHeight.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void previousPage({
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOut,
  }) {
    if (widget.startDay != null) {
      if (widget.startDay.isAfter(_firstActiveDay) ||
          _isSameDay(widget.startDay, _firstActiveDay)) {
        return;
      }
    }

    _pageController.previousPage(duration: duration, curve: curve);
  }

  void nextPage({
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOut,
  }) {
    if (widget.endDay != null) {
      if (widget.endDay.isBefore(_lastActiveDay) ||
          _isSameDay(widget.endDay, _lastActiveDay)) {
        return;
      }
    }

    _pageController.nextPage(duration: duration, curve: curve);
  }

  void toggleCalendarFormat() {
    if (widget.availableCalendarFormats.keys.length <= 1) {
      return;
    }

    setState(() {
      _calendarFormat = _nextFormat();
    });

    final days = _getVisibleDays(_baseDay);

    if (_calendarFormat == CalendarFormat.month) {
      _firstActiveDay = _firstDayOfMonth(_baseDay);
      _lastActiveDay = _lastDayOfMonth(_baseDay);
    } else {
      _firstActiveDay = days.first;
      _lastActiveDay = days.last;
    }

    _calendarHeight.value = _getPageHeight(dayCount: days.length);

    if (widget.onFormatChanged != null) {
      if (!widget.calendarStyle.outsideDaysVisible &&
          _calendarFormat == CalendarFormat.month) {
        widget.onFormatChanged(_calendarFormat, _firstDayOfMonth(_baseDay),
            _lastDayOfMonth(_baseDay));
      } else {
        widget.onFormatChanged(_calendarFormat, days.first, days.last);
      }
    }
  }

  void swipeCalendarFormat({@required bool isSwipeUp}) {
    assert(isSwipeUp != null);

    final formats = widget.availableCalendarFormats.keys.toList();

    if (formats.length <= 1) {
      return;
    }

    int id = formats.indexOf(_calendarFormat);

    // Order of CalendarFormats must be from biggest to smallest,
    // eg.: [month, twoWeeks, week]
    if (isSwipeUp) {
      id = min(formats.length - 1, id + 1);
    } else {
      id = max(0, id - 1);
    }

    if (_calendarFormat == formats[id]) {
      return;
    }

    setState(() {
      _calendarFormat = formats[id];
    });

    final days = _getVisibleDays(_baseDay);

    if (_calendarFormat == CalendarFormat.month) {
      _firstActiveDay = _firstDayOfMonth(_baseDay);
      _lastActiveDay = _lastDayOfMonth(_baseDay);
    } else {
      _firstActiveDay = days.first;
      _lastActiveDay = days.last;
    }

    _calendarHeight.value = _getPageHeight(dayCount: days.length);

    if (widget.onFormatChanged != null) {
      if (!widget.calendarStyle.outsideDaysVisible &&
          _calendarFormat == CalendarFormat.month) {
        widget.onFormatChanged(_calendarFormat, _firstDayOfMonth(_baseDay),
            _lastDayOfMonth(_baseDay));
      } else {
        widget.onFormatChanged(_calendarFormat, days.first, days.last);
      }
    }
  }

  void _onDaySelected(DateTime day, List<T> events, List<T> holidays) {
    setState(() {
      _focusedDay.value = day;
      _selectedDay = day;

      if (_calendarFormat == CalendarFormat.month) {
        _baseDay = day;
        _calendarHeight.value = _getPageHeight(baseDay: _baseDay);
      }
    });

    if (widget.onDaySelected != null) {
      widget.onDaySelected(day, events, holidays);
    }
  }

  void _onDayLongPressed(DateTime day, List<T> events, List<T> holidays) {
    if (widget.onDayLongPressed != null) {
      widget.onDayLongPressed(day, events, holidays);
    }
  }

  void _onUnavailableDaySelected(DateTime day) {
    if (widget.onUnavailableDaySelected != null) {
      widget.onUnavailableDaySelected(day);
    }
  }

  void _onUnavailableDayLongPressed(DateTime day) {
    if (widget.onUnavailableDayLongPressed != null) {
      widget.onUnavailableDayLongPressed(day);
    }
  }

  void _onHeaderTapped() {
    if (widget.onHeaderTapped != null) {
      widget.onHeaderTapped(_focusedDay.value);
    }
  }

  void _onHeaderLongPressed() {
    if (widget.onHeaderLongPressed != null) {
      widget.onHeaderLongPressed(_focusedDay.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.headerVisible) _buildHeader(),
        Padding(
          padding: widget.calendarStyle.contentPadding,
          child: _buildPageView(),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return SimpleGestureDetector(
      onVerticalSwipe: widget.availableGestures == AvailableGestures.all ||
              widget.availableGestures == AvailableGestures.verticalSwipe
          ? (swipeDirection) => swipeCalendarFormat(
              isSwipeUp: swipeDirection == SwipeDirection.up)
          : null,
      swipeConfig: widget.simpleSwipeConfig,
      child: ValueListenableBuilder(
        valueListenable: _calendarHeight,
        builder: (context, value, child) {
          return AnimatedSize(
            vsync: this,
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(height: value, child: child),
          );
        },
        child: PageView.custom(
          controller: _pageController,
          physics: widget.availableGestures == AvailableGestures.all ||
                  widget.availableGestures == AvailableGestures.horizontalSwipe
              ? PageScrollPhysics()
              : NeverScrollableScrollPhysics(),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              final baseDay = _getPageBaseDay(index, _calendarFormat);
              final days = _getVisibleDays(baseDay);

              final focusedDay = _getPageFocusedDay(index, _calendarFormat);

              final daysInWeek = 7;

              final children = <TableRow>[
                if (widget.daysOfWeekVisible)
                  _buildDaysOfWeek(days.take(daysInWeek).toList()),
              ];

              int x = 0;
              while (x < days.length) {
                children.add(_buildTableRow(
                    days.skip(x).take(daysInWeek).toList(), focusedDay));
                x += daysInWeek;
              }

              return Table(
                defaultColumnWidth: FractionColumnWidth(1.0 / daysInWeek),
                children: children,
              );
            },
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
          ),
          onPageChanged: (index) {
            _baseDay = _getPageBaseDay(index, _calendarFormat);
            _focusedDay.value = _baseDay;
            _pageIndex = index;

            final days = _getVisibleDays(_baseDay);
            _calendarHeight.value = _getPageHeight(dayCount: days.length);

            if (_calendarFormat == CalendarFormat.month) {
              _firstActiveDay = _firstDayOfMonth(_baseDay);
              _lastActiveDay = _lastDayOfMonth(_baseDay);
            } else {
              _firstActiveDay = days.first;
              _lastActiveDay = days.last;
            }

            if (widget.onPageChanged != null) {
              if (!widget.calendarStyle.outsideDaysVisible &&
                  _calendarFormat == CalendarFormat.month) {
                widget.onPageChanged(_focusedDay.value,
                    _firstDayOfMonth(_baseDay), _lastDayOfMonth(_baseDay));
              } else {
                widget.onPageChanged(_focusedDay.value, days.first, days.last);
              }
            }
          },
        ),
      ),
    );
  }

  TableRow _buildDaysOfWeek(List<DateTime> days) {
    return TableRow(
      decoration: widget.daysOfWeekStyle.decoration,
      children: days.map((date) {
        final weekdayString = widget.daysOfWeekStyle.dowTextBuilder != null
            ? widget.daysOfWeekStyle.dowTextBuilder(date, widget.locale)
            : DateFormat.E(widget.locale).format(date);
        final isWeekend = _isWeekend(date, widget.weekendDays);

        Widget child;

        if (isWeekend && widget.builders.dowWeekendBuilder != null) {
          child = widget.builders.dowWeekendBuilder(context, weekdayString);
        } else if (widget.builders.dowWeekdayBuilder != null) {
          child = widget.builders.dowWeekdayBuilder(context, weekdayString);
        } else {
          child = Center(
            child: Text(
              weekdayString,
              style: isWeekend
                  ? widget.daysOfWeekStyle.weekendStyle
                  : widget.daysOfWeekStyle.weekdayStyle,
            ),
          );
        }

        return SizedBox(height: widget.daysOfWeekHeight, child: child);
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<DateTime> days, DateTime focusedDay) {
    return TableRow(
      decoration: widget.calendarStyle.contentDecoration,
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

  Widget _buildHeader() {
    return Container(
      decoration: widget.headerStyle.decoration,
      margin: widget.headerStyle.headerMargin,
      padding: widget.headerStyle.headerPadding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (widget.headerStyle.leftChevronVisible)
            _CustomIconButton(
              icon: widget.headerStyle.leftChevronIcon,
              onTap: previousPage,
              margin: widget.headerStyle.leftChevronMargin,
              padding: widget.headerStyle.leftChevronPadding,
            ),
          Expanded(
            child: GestureDetector(
              onTap: _onHeaderTapped,
              onLongPress: _onHeaderLongPressed,
              child: ValueListenableBuilder(
                valueListenable: _focusedDay,
                builder: (context, value, child) => Text(
                  widget.headerStyle.titleTextBuilder != null
                      ? widget.headerStyle
                          .titleTextBuilder(value, widget.locale)
                      : DateFormat.yMMMM(widget.locale).format(value),
                  style: widget.headerStyle.titleTextStyle,
                  textAlign: widget.headerStyle.centerHeaderTitle
                      ? TextAlign.center
                      : TextAlign.start,
                ),
              ),
            ),
          ),
          if (widget.headerStyle.formatButtonVisible &&
              widget.availableCalendarFormats.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildFormatButton(),
            ),
          if (widget.headerStyle.rightChevronVisible)
            _CustomIconButton(
              icon: widget.headerStyle.rightChevronIcon,
              onTap: nextPage,
              margin: widget.headerStyle.rightChevronMargin,
              padding: widget.headerStyle.rightChevronPadding,
            ),
        ],
      ),
    );
  }

  Widget _buildFormatButton() {
    return GestureDetector(
      onTap: toggleCalendarFormat,
      child: Container(
        decoration: widget.headerStyle.formatButtonDecoration,
        padding: widget.headerStyle.formatButtonPadding,
        child: Text(
          _getFormatButtonText(),
          style: widget.headerStyle.formatButtonTextStyle,
        ),
      ),
    );
  }

  Widget _buildCell(DateTime date, DateTime focusedDay) {
    if (!widget.calendarStyle.outsideDaysVisible &&
        date.month != focusedDay.month &&
        _calendarFormat == CalendarFormat.month) {
      return Container();
    }

    final events = widget.events[date] ?? [];
    final holidays = widget.holidays[date] ?? [];

    Widget content = _buildCellContent(date, focusedDay, events);
    final children = <Widget>[content];

    if (!_isDayUnavailable(date)) {
      if (widget.builders.markersBuilder != null) {
        children.addAll(
          widget.builders.markersBuilder(
            context,
            date,
            events,
            holidays,
          ),
        );
      } else if (events.isNotEmpty) {
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
                  .map((event) => _buildMarker(date, event))
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
        clipBehavior: widget.calendarStyle.canEventMarkersOverflow
            ? Clip.none
            : Clip.hardEdge,
      );
    }

    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _isDayUnavailable(date)
          ? _onUnavailableDaySelected(date)
          : _onDaySelected(date, events, holidays),
      onLongPress: () => _isDayUnavailable(date)
          ? _onUnavailableDayLongPressed(date)
          : _onDayLongPressed(date, events, holidays),
      child: content,
    );
  }

  Widget _buildCellContent(DateTime date, DateTime focusedDay, List<T> events) {
    final tIsUnavailable = _isDayUnavailable(date);
    final tIsSelected = _isSameDay(date, _selectedDay);
    final tIsToday = _isSameDay(date, DateTime.now().toUtc());
    final tIsOutside = date.month != focusedDay.month;
    final tIsHoliday = widget.holidays.containsKey(date);
    final tIsWeekend = _isWeekend(date, widget.weekendDays);

    final isUnavailable =
        widget.builders.unavailableDayBuilder != null && tIsUnavailable;
    final isSelected =
        widget.builders.selectedDayBuilder != null && tIsSelected;
    final isToday = widget.builders.todayDayBuilder != null && tIsToday;
    final isOutsideHoliday = widget.builders.outsideHolidayDayBuilder != null &&
        tIsOutside &&
        tIsHoliday;
    final isHoliday =
        widget.builders.holidayDayBuilder != null && !tIsOutside && tIsHoliday;
    final isOutsideWeekend = widget.builders.outsideWeekendDayBuilder != null &&
        tIsOutside &&
        tIsWeekend &&
        !tIsHoliday;
    final isOutside = widget.builders.outsideDayBuilder != null &&
        tIsOutside &&
        !tIsWeekend &&
        !tIsHoliday;
    final isWeekend = widget.builders.weekendDayBuilder != null &&
        !tIsOutside &&
        tIsWeekend &&
        !tIsHoliday;

    if (isUnavailable) {
      return widget.builders.unavailableDayBuilder(context, date, events);
    } else if (isSelected && widget.calendarStyle.renderSelectedFirst) {
      return widget.builders.selectedDayBuilder(context, date, events);
    } else if (isToday) {
      return widget.builders.todayDayBuilder(context, date, events);
    } else if (isSelected) {
      return widget.builders.selectedDayBuilder(context, date, events);
    } else if (isOutsideHoliday) {
      return widget.builders.outsideHolidayDayBuilder(context, date, events);
    } else if (isHoliday) {
      return widget.builders.holidayDayBuilder(context, date, events);
    } else if (isOutsideWeekend) {
      return widget.builders.outsideWeekendDayBuilder(context, date, events);
    } else if (isOutside) {
      return widget.builders.outsideDayBuilder(context, date, events);
    } else if (isWeekend) {
      return widget.builders.weekendDayBuilder(context, date, events);
    } else if (widget.builders.dayBuilder != null) {
      return widget.builders.dayBuilder(context, date, events);
    } else {
      return _CellWidget(
        text: '${date.day}',
        isUnavailable: tIsUnavailable,
        isSelected: tIsSelected,
        isToday: tIsToday,
        isWeekend: tIsWeekend,
        isOutsideMonth: tIsOutside,
        isHoliday: tIsHoliday,
        isEventDay: events.isNotEmpty,
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

  DateTime _getPageBaseDay(int index, CalendarFormat format) {
    if (index == _pageIndex) {
      if (format == CalendarFormat.month) {
        return _focusedDay.value;
      }

      return _baseDay;
    }

    final pageDifference = index - _pageIndex;

    if (format == CalendarFormat.month) {
      return DateTime.utc(
          _baseDay.year, _baseDay.month + pageDifference, _baseDay.day);
    } else if (format == CalendarFormat.twoWeeks) {
      return DateTime.utc(
        _baseDay.year,
        _baseDay.month,
        _baseDay.day + pageDifference * 14,
      );
    } else {
      return DateTime.utc(
          _baseDay.year, _baseDay.month, _baseDay.day + pageDifference * 7);
    }
  }

  DateTime _getPageFocusedDay(int index, CalendarFormat format) {
    if (index == _pageIndex) {
      return _focusedDay.value;
    }

    final pageDifference = index - _pageIndex;

    if (format == CalendarFormat.month) {
      return DateTime.utc(_focusedDay.value.year,
          _focusedDay.value.month + pageDifference, _focusedDay.value.day);
    } else if (format == CalendarFormat.twoWeeks) {
      return DateTime.utc(
        _focusedDay.value.year,
        _focusedDay.value.month,
        _focusedDay.value.day + pageDifference * 14,
      );
    } else {
      return DateTime.utc(_focusedDay.value.year, _focusedDay.value.month,
          _focusedDay.value.day + pageDifference * 7);
    }
  }

  List<DateTime> _getVisibleDays(DateTime baseDay) {
    if (_calendarFormat == CalendarFormat.month) {
      return _daysInMonth(baseDay);
    } else if (_calendarFormat == CalendarFormat.twoWeeks) {
      return _daysInWeek(baseDay)
        ..addAll(_daysInWeek(
          baseDay.add(const Duration(days: 7)),
        ));
    } else {
      return _daysInWeek(baseDay);
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
    return (firstDay.weekday +
            7 -
            _getWeekdayNumber(widget.startingDayOfWeek)) %
        7;
  }

  int _getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday =
        8 - _getWeekdayNumber(widget.startingDayOfWeek);

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
    final decreaseNum = _getDaysBefore(day);
    return day.subtract(Duration(days: decreaseNum));
  }

  DateTime _lastDayOfWeek(DateTime day) {
    final increaseNum = _getDaysBefore(day);
    return day.add(Duration(days: 7 - increaseNum));
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

  Iterable<DateTime> _daysInRange(DateTime firstDay, DateTime lastDay) sync* {
    var temp = firstDay;

    while (temp.isBefore(lastDay)) {
      yield temp;
      temp = temp.add(const Duration(days: 1));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDayUnavailable(DateTime day) {
    return (widget.startDay != null && day.isBefore(widget.startDay)) ||
        (widget.endDay != null && day.isAfter(widget.endDay)) ||
        (!_isDayEnabled(day));
  }

  bool _isDayEnabled(DateTime day) {
    return widget.enabledDayPredicate == null
        ? true
        : widget.enabledDayPredicate(day);
  }

  bool _isWeekend(DateTime day, List<int> weekendDays) {
    return weekendDays.contains(day.weekday);
  }

  CalendarFormat _nextFormat() {
    final formats = widget.availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat);
    id = (id + 1) % formats.length;

    return formats[id];
  }

  String _getFormatButtonText() => widget.headerStyle.formatButtonShowsNext
      ? widget.availableCalendarFormats[_nextFormat()]
      : widget.availableCalendarFormats[_calendarFormat];

  double _getPageHeight({int dayCount, DateTime baseDay}) {
    var rowCount;

    if (dayCount != null) {
      rowCount = dayCount ~/ 7;
    } else {
      final base = baseDay ?? _getPageBaseDay(_pageIndex, _calendarFormat);
      final days = _getVisibleDays(base);
      rowCount = days.length ~/ 7;
    }

    final dowHeight = widget.daysOfWeekVisible ? widget.daysOfWeekHeight : 0.0;
    return rowCount * widget.rowHeight + dowHeight;
  }
}
