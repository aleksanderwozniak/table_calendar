//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

/// Callback exposing currently selected day.
typedef void OnDaySelected(DateTime day, List events, List holidays);

/// Callback exposing currently visible days (first and last of them), as well as current `CalendarFormat`.
typedef void OnVisibleDaysChanged(
    DateTime first, DateTime last, CalendarFormat format);

/// Callback exposing initially visible days (first and last of them), as well as initial `CalendarFormat`.
typedef void OnCalendarCreated(
    DateTime first, DateTime last, CalendarFormat format);

/// Signature for reacting to header gestures. Exposes current month and year as a `DateTime` object.
typedef void HeaderGestureCallback(DateTime focusedDay);

/// Builder signature for any text that can be localized and formatted with `DateFormat`.
typedef String TextBuilder(DateTime date, dynamic locale);

/// Signature for enabling days.
typedef bool EnabledDayPredicate(DateTime day);

/// Format to display the `TableCalendar` with.
enum CalendarFormat { month, twoWeeks, week }

/// Available animations to update the `CalendarFormat` with.
enum FormatAnimation { slide, scale }

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

/// Gestures available to interal `TableCalendar`'s logic.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

/// Highly customizable, feature-packed Flutter Calendar with gestures, animations and multiple formats.
class TableCalendar extends StatefulWidget {
  /// Controller required for `TableCalendar`.
  /// Use it to update `events`, `holidays`, etc.
  final CalendarController calendarController;

  /// Locale to format `TableCalendar` dates with, for example: `'en_US'`.
  ///
  /// If nothing is provided, a default locale will be used.
  final dynamic locale;

  /// `Map` of events.
  /// Each `DateTime` inside this `Map` should get its own `List` of objects (i.e. events).
  final Map<DateTime, List> events;

  /// `Map` of holidays.
  /// This property allows you to provide custom holiday rules.
  final Map<DateTime, List> holidays;

  /// Called whenever any day gets tapped.
  final OnDaySelected onDaySelected;

  /// Called whenever any day gets long pressed.
  final OnDaySelected onDayLongPressed;

  /// Called whenever any unavailable day gets tapped.
  /// Replaces `onDaySelected` for those days.
  final VoidCallback onUnavailableDaySelected;

  /// Called whenever any unavailable day gets long pressed.
  /// Replaces `onDaySelected` for those days.
  final VoidCallback onUnavailableDayLongPressed;

  /// Called whenever header gets tapped.
  final HeaderGestureCallback onHeaderTapped;

  /// Called whenever header gets long pressed.
  final HeaderGestureCallback onHeaderLongPressed;

  /// Called whenever the range of visible days changes.
  final OnVisibleDaysChanged onVisibleDaysChanged;

  /// Called once when the CalendarController gets initialized.
  final OnCalendarCreated onCalendarCreated;

  /// Initially selected DateTime. Usually it will be `DateTime.now()`.
  final DateTime initialSelectedDay;

  /// The first day of `TableCalendar`.
  /// Days before it will use `unavailableStyle` and run `onUnavailableDaySelected` callback.
  final DateTime startDay;

  /// The last day of `TableCalendar`.
  /// Days after it will use `unavailableStyle` and run `onUnavailableDaySelected` callback.
  final DateTime endDay;

  /// List of days treated as weekend days.
  /// Use built-in `DateTime` weekday constants (e.g. `DateTime.monday`) instead of `int` literals (e.q. `1`).
  final List<int> weekendDays;

  /// `CalendarFormat` which will be displayed first.
  final CalendarFormat initialCalendarFormat;

  /// `Map` of `CalendarFormat`s and `String` names associated with them.
  /// Those `CalendarFormat`s will be used by internal logic to manage displayed format.
  ///
  /// To ensure proper vertical Swipe behavior, `CalendarFormat`s should be in descending order (eg. from biggest to smallest).
  ///
  /// For example:
  /// ```dart
  /// availableCalendarFormats: const {
  ///   CalendarFormat.month: 'Month',
  ///   CalendarFormat.week: 'Week',
  /// }
  /// ```
  final Map<CalendarFormat, String> availableCalendarFormats;

  /// Used to show/hide Header.
  final bool headerVisible;

  /// Function deciding whether given day should be enabled or not.
  /// If `false` is returned, this day will be unavailable.
  final EnabledDayPredicate enabledDayPredicate;

  /// Used for setting the height of `TableCalendar`'s rows.
  final double rowHeight;

  /// Animation to run when `CalendarFormat` gets changed.
  final FormatAnimation formatAnimation;

  /// `TableCalendar` will start weeks with provided day.
  /// Use `StartingDayOfWeek.monday` for Monday - Sunday week format.
  /// Use `StartingDayOfWeek.sunday` for Sunday - Saturday week format.
  final StartingDayOfWeek startingDayOfWeek;

  /// `HitTestBehavior` for every day cell inside `TableCalendar`.
  final HitTestBehavior dayHitTestBehavior;

  /// Specify Gestures available to `TableCalendar`.
  /// If `AvailableGestures.none` is used, the Calendar will only be interactive via buttons.
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
  final CalendarBuilders builders;

  TableCalendar({
    Key key,
    @required this.calendarController,
    this.locale,
    this.events = const {},
    this.holidays = const {},
    this.onDaySelected,
    this.onDayLongPressed,
    this.onUnavailableDaySelected,
    this.onUnavailableDayLongPressed,
    this.onHeaderTapped,
    this.onHeaderLongPressed,
    this.onVisibleDaysChanged,
    this.onCalendarCreated,
    this.initialSelectedDay,
    this.startDay,
    this.endDay,
    this.weekendDays = const [DateTime.saturday, DateTime.sunday],
    this.initialCalendarFormat = CalendarFormat.month,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.headerVisible = true,
    this.enabledDayPredicate,
    this.rowHeight,
    this.formatAnimation = FormatAnimation.slide,
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
  })  : assert(calendarController != null),
        assert(availableCalendarFormats.keys.contains(initialCalendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        assert(weekendDays != null),
        assert(weekendDays.isNotEmpty
            ? weekendDays.every(
                (day) => day >= DateTime.monday && day <= DateTime.sunday)
            : true),
        super(key: key);

  @override
  _TableCalendarState createState() => _TableCalendarState();
}

class _TableCalendarState extends State<TableCalendar>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    widget.calendarController._init(
      events: widget.events,
      holidays: widget.holidays,
      initialDay: widget.initialSelectedDay,
      initialFormat: widget.initialCalendarFormat,
      availableCalendarFormats: widget.availableCalendarFormats,
      useNextCalendarFormat: widget.headerStyle.formatButtonShowsNext,
      startingDayOfWeek: widget.startingDayOfWeek,
      selectedDayCallback: _selectedDayCallback,
      onVisibleDaysChanged: widget.onVisibleDaysChanged,
      onCalendarCreated: widget.onCalendarCreated,
      includeInvisibleDays: widget.calendarStyle.outsideDaysVisible,
    );
  }

  @override
  void didUpdateWidget(TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.events != widget.events) {
      widget.calendarController._events = widget.events;
    }

    if (oldWidget.holidays != widget.holidays) {
      widget.calendarController._holidays = widget.holidays;
    }

    if (oldWidget.availableCalendarFormats != widget.availableCalendarFormats) {
      widget.calendarController._availableCalendarFormats =
          widget.availableCalendarFormats;
    }
  }

  void _selectedDayCallback(DateTime day) {
    if (widget.onDaySelected != null) {
      widget.onDaySelected(
        day,
        widget.calendarController.visibleEvents[_getEventKey(day)] ?? [],
        widget.calendarController.visibleHolidays[_getHolidayKey(day)] ?? [],
      );
    }
  }

  void _selectPrevious() {
    setState(() {
      widget.calendarController.previousPage();
    });
  }

  void _selectNext() {
    setState(() {
      widget.calendarController.nextPage();
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      widget.calendarController.setSelectedDay(day, isProgrammatic: false);
      _selectedDayCallback(day);
    });
  }

  void _onDayLongPressed(DateTime day) {
    if (widget.onDayLongPressed != null) {
      widget.onDayLongPressed(
        day,
        widget.calendarController.visibleEvents[_getEventKey(day)] ?? [],
        widget.calendarController.visibleHolidays[_getHolidayKey(day)] ?? [],
      );
    }
  }

  void _toggleCalendarFormat() {
    setState(() {
      widget.calendarController.toggleCalendarFormat();
    });
  }

  void _onHorizontalSwipe(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      // Swipe right
      _selectPrevious();
    } else {
      // Swipe left
      _selectNext();
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

  void _onHeaderTapped() {
    if (widget.onHeaderTapped != null) {
      widget.onHeaderTapped(widget.calendarController.focusedDay);
    }
  }

  void _onHeaderLongPressed() {
    if (widget.onHeaderLongPressed != null) {
      widget.onHeaderLongPressed(widget.calendarController.focusedDay);
    }
  }

  bool _isDayUnavailable(DateTime day) {
    return (widget.startDay != null &&
            day.isBefore(
                widget.calendarController._normalizeDate(widget.startDay))) ||
        (widget.endDay != null &&
            day.isAfter(
                widget.calendarController._normalizeDate(widget.endDay))) ||
        (!_isDayEnabled(day));
  }

  bool _isDayEnabled(DateTime day) {
    return widget.enabledDayPredicate == null
        ? true
        : widget.enabledDayPredicate(day);
  }

  DateTime _getEventKey(DateTime day) {
    return widget.calendarController._getEventKey(day);
  }

  DateTime _getHolidayKey(DateTime day) {
    return widget.calendarController._getHolidayKey(day);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.headerVisible) _buildHeader(),
          Padding(
            padding: widget.calendarStyle.contentPadding,
            child: _buildCalendarContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final children = [
      widget.headerStyle.leftChevronVisible
          ? _CustomIconButton(
              icon: widget.headerStyle.leftChevronIcon,
              onTap: _selectPrevious,
              margin: widget.headerStyle.leftChevronMargin,
              padding: widget.headerStyle.leftChevronPadding,
            )
          : Container(),
      Expanded(
        child: GestureDetector(
          onTap: _onHeaderTapped,
          onLongPress: _onHeaderLongPressed,
          child: Text(
            widget.headerStyle.titleTextBuilder != null
                ? widget.headerStyle.titleTextBuilder(
                    widget.calendarController.focusedDay, widget.locale)
                : DateFormat.yMMMM(widget.locale)
                    .format(widget.calendarController.focusedDay),
            style: widget.headerStyle.titleTextStyle,
            textAlign: widget.headerStyle.centerHeaderTitle
                ? TextAlign.center
                : TextAlign.start,
          ),
        ),
      ),
      widget.headerStyle.rightChevronVisible
          ? _CustomIconButton(
              icon: widget.headerStyle.rightChevronIcon,
              onTap: _selectNext,
              margin: widget.headerStyle.rightChevronMargin,
              padding: widget.headerStyle.rightChevronPadding,
            )
          : Container()
    ];

    if (widget.headerStyle.formatButtonVisible &&
        widget.availableCalendarFormats.length > 1) {
      children.insert(2, const SizedBox(width: 8.0));
      children.insert(3, _buildFormatButton());
    }

    return Container(
      decoration: widget.headerStyle.decoration,
      margin: widget.headerStyle.headerMargin,
      padding: widget.headerStyle.headerPadding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }

  Widget _buildFormatButton() {
    return GestureDetector(
      onTap: _toggleCalendarFormat,
      child: Container(
        decoration: widget.headerStyle.formatButtonDecoration,
        padding: widget.headerStyle.formatButtonPadding,
        child: Text(
          widget.calendarController._getFormatButtonText(),
          style: widget.headerStyle.formatButtonTextStyle,
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    if (widget.formatAnimation == FormatAnimation.slide) {
      return AnimatedSize(
        duration: Duration(
            milliseconds:
                widget.calendarController.calendarFormat == CalendarFormat.month
                    ? 330
                    : 220),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment(0, -1),
        vsync: this,
        child: _buildWrapper(),
      );
    } else {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: _buildWrapper(
          key: ValueKey(widget.calendarController.calendarFormat),
        ),
      );
    }
  }

  Widget _buildWrapper({Key key}) {
    Widget wrappedChild = _buildTable();

    switch (widget.availableGestures) {
      case AvailableGestures.all:
        wrappedChild = _buildVerticalSwipeWrapper(
          child: _buildHorizontalSwipeWrapper(
            child: wrappedChild,
          ),
        );
        break;
      case AvailableGestures.verticalSwipe:
        wrappedChild = _buildVerticalSwipeWrapper(
          child: wrappedChild,
        );
        break;
      case AvailableGestures.horizontalSwipe:
        wrappedChild = _buildHorizontalSwipeWrapper(
          child: wrappedChild,
        );
        break;
      case AvailableGestures.none:
        break;
    }

    return Container(
      key: key,
      child: wrappedChild,
    );
  }

  Widget _buildVerticalSwipeWrapper({Widget child}) {
    return SimpleGestureDetector(
      child: child,
      onVerticalSwipe: (direction) {
        setState(() {
          widget.calendarController
              .swipeCalendarFormat(isSwipeUp: direction == SwipeDirection.up);
        });
      },
      swipeConfig: widget.simpleSwipeConfig,
    );
  }

  Widget _buildHorizontalSwipeWrapper({Widget child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.decelerate,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
                  begin: Offset(widget.calendarController._dx, 0),
                  end: Offset(0, 0))
              .animate(animation),
          child: child,
        );
      },
      layoutBuilder: (currentChild, _) => currentChild,
      child: Dismissible(
        key: ValueKey(widget.calendarController._pageId),
        resizeDuration: null,
        onDismissed: _onHorizontalSwipe,
        direction: DismissDirection.horizontal,
        child: child,
      ),
    );
  }

  Widget _buildTable() {
    final daysInWeek = 7;
    final children = <TableRow>[
      if (widget.calendarStyle.renderDaysOfWeek) _buildDaysOfWeek(),
    ];

    int x = 0;
    while (x < widget.calendarController._visibleDays.value.length) {
      children.add(_buildTableRow(widget.calendarController._visibleDays.value
          .skip(x)
          .take(daysInWeek)
          .toList()));
      x += daysInWeek;
    }

    return Table(
      // Makes this Table fill its parent horizontally
      defaultColumnWidth: FractionColumnWidth(1.0 / daysInWeek),
      children: children,
    );
  }

  TableRow _buildDaysOfWeek() {
    return TableRow(
      decoration: widget.daysOfWeekStyle.decoration,
      children:
          widget.calendarController._visibleDays.value.take(7).map((date) {
        final weekdayString = widget.daysOfWeekStyle.dowTextBuilder != null
            ? widget.daysOfWeekStyle.dowTextBuilder(date, widget.locale)
            : DateFormat.E(widget.locale).format(date);
        final isWeekend =
            widget.calendarController._isWeekend(date, widget.weekendDays);

        if (isWeekend && widget.builders.dowWeekendBuilder != null) {
          return widget.builders.dowWeekendBuilder(context, weekdayString);
        }
        if (widget.builders.dowWeekdayBuilder != null) {
          return widget.builders.dowWeekdayBuilder(context, weekdayString);
        }
        return Center(
          child: Text(
            weekdayString,
            style: isWeekend
                ? widget.daysOfWeekStyle.weekendStyle
                : widget.daysOfWeekStyle.weekdayStyle,
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<DateTime> days) {
    return TableRow(
      decoration: widget.calendarStyle.contentDecoration,
      children: days.map((date) => _buildTableCell(date)).toList(),
    );
  }

  // TableCell will have equal width and height
  Widget _buildTableCell(DateTime date) {
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.rowHeight ?? constraints.maxWidth,
          minHeight: widget.rowHeight ?? constraints.maxWidth,
        ),
        child: _buildCell(date),
      ),
    );
  }

  Widget _buildCell(DateTime date) {
    if (!widget.calendarStyle.outsideDaysVisible &&
        widget.calendarController._isExtraDay(date) &&
        widget.calendarController.calendarFormat == CalendarFormat.month) {
      return Container();
    }

    Widget content = _buildCellContent(date);

    final eventKey = _getEventKey(date);
    final holidayKey = _getHolidayKey(date);
    final key = eventKey ?? holidayKey;

    if (key != null) {
      final children = <Widget>[content];
      final events = eventKey != null
          ? widget.calendarController.visibleEvents[eventKey]
          : [];
      final holidays = holidayKey != null
          ? widget.calendarController.visibleHolidays[holidayKey]
          : [];

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
          clipBehavior: widget.calendarStyle.canEventMarkersOverflow
              ? Clip.none
              : Clip.hardEdge,
        );
      }
    }

    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _isDayUnavailable(date)
          ? _onUnavailableDaySelected()
          : _selectDay(date),
      onLongPress: () => _isDayUnavailable(date)
          ? _onUnavailableDayLongPressed()
          : _onDayLongPressed(date),
      child: content,
    );
  }

  Widget _buildCellContent(DateTime date) {
    final eventKey = _getEventKey(date);

    final tIsUnavailable = _isDayUnavailable(date);
    final tIsSelected = widget.calendarController.isSelected(date);
    final tIsToday = widget.calendarController.isToday(date);
    final tIsOutside = widget.calendarController._isExtraDay(date);
    final tIsHoliday = widget.calendarController.visibleHolidays
        .containsKey(_getHolidayKey(date));
    final tIsWeekend =
        widget.calendarController._isWeekend(date, widget.weekendDays);
    final tIsEventDay =
        widget.calendarController.visibleEvents.containsKey(eventKey);

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
      return widget.builders.unavailableDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isSelected && widget.calendarStyle.renderSelectedFirst) {
      return widget.builders.selectedDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isToday) {
      return widget.builders.todayDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isSelected) {
      return widget.builders.selectedDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isOutsideHoliday) {
      return widget.builders.outsideHolidayDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isHoliday) {
      return widget.builders.holidayDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isOutsideWeekend) {
      return widget.builders.outsideWeekendDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isOutside) {
      return widget.builders.outsideDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isWeekend) {
      return widget.builders.weekendDayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (widget.builders.dayBuilder != null) {
      return widget.builders.dayBuilder(
          context, date, widget.calendarController.visibleEvents[eventKey]);
    } else {
      return _CellWidget(
        text: '${date.day}',
        isUnavailable: tIsUnavailable,
        isSelected: tIsSelected,
        isToday: tIsToday,
        isWeekend: tIsWeekend,
        isOutsideMonth: tIsOutside,
        isHoliday: tIsHoliday,
        isEventDay: tIsEventDay,
        calendarStyle: widget.calendarStyle,
      );
    }
  }

  Widget _buildMarker(DateTime date, dynamic event) {
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
