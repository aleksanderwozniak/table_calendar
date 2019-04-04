//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

library table_calendar;

import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import 'src/customization/customization.dart';
import 'src/logic/calendar_logic.dart';
import 'src/widgets/widgets.dart';

export 'src/customization/customization.dart';

/// Callback exposing currently selected day.
typedef void OnDaySelected(DateTime day, List events);

/// Callback exposing currently visible days (first and last of them), as well as current `CalendarFormat`.
typedef void OnVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format);

/// Builder signature for any text that can be localized and formatted with `DateFormat`.
typedef String TextBuilder(DateTime date, dynamic locale);

/// Format to display the `TableCalendar` with.
enum CalendarFormat { month, twoWeeks, week }

/// Available animations to update the `CalendarFormat` with.
enum FormatAnimation { slide, scale }

/// Available day of week formats. `TableCalendar` will start the week with chosen day.
/// * `StartingDayOfWeek.monday`: Monday - Sunday
/// * `StartingDayOfWeek.sunday`: Sunday - Saturday
enum StartingDayOfWeek { monday, sunday }

/// Gestures available to interal `TableCalendar`'s logic.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

/// Highly customizable, feature-packed Flutter Calendar with gestures, animations and multiple formats.
class TableCalendar extends StatefulWidget {
  /// Locale to format `TableCalendar` dates with, for example: `'en_US'`.
  ///
  /// If nothing is provided, a default locale will be used.
  final dynamic locale;

  /// Contains a `List` of objects (eg. events) assigned to particular `DateTime`s.
  /// Each `DateTime` inside this `Map` should get its own `List` of above mentioned objects.
  final Map<DateTime, List> events;

  /// Called whenever any day gets tapped.
  final OnDaySelected onDaySelected;

  /// Called whenever the range of visible days changes.
  final OnVisibleDaysChanged onVisibleDaysChanged;

  /// Initially selected DateTime. Usually it will be `DateTime.now()`.
  /// This property can be used to programmatically select a new date.
  ///
  /// If `TableCalendar` Widget gets rebuilt with a different `selectedDay` than previously,
  /// `onDaySelected` callback will run.
  ///
  /// To animate programmatic selection, use `animateProgSelectedDay` property.
  final DateTime selectedDay;

  /// `CalendarFormat` which will be displayed first.
  final CalendarFormat initialCalendarFormat;

  /// `CalendarFormat` which overrides any internal logic.
  /// Use if you need total programmatic control over `TableCalendar`'s format.
  ///
  /// Makes `initialCalendarFormat` and `availableCalendarFormats` obsolete.
  final CalendarFormat forcedCalendarFormat;

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

  /// Used to enable animations for programmatically set `selectedDay`.
  /// Most of the time it should be `false`.
  final bool animateProgSelectedDay;

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
    this.locale,
    this.events = const {},
    this.onDaySelected,
    this.onVisibleDaysChanged,
    this.selectedDay,
    this.initialCalendarFormat = CalendarFormat.month,
    this.forcedCalendarFormat,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.headerVisible = true,
    this.animateProgSelectedDay = false,
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
  })  : assert(availableCalendarFormats.keys.contains(initialCalendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        super(key: key);

  @override
  _TableCalendarState createState() {
    return new _TableCalendarState();
  }
}

class _TableCalendarState extends State<TableCalendar> with SingleTickerProviderStateMixin {
  CalendarLogic _calendarLogic;

  @override
  void initState() {
    super.initState();
    _calendarLogic = CalendarLogic(
      widget.availableCalendarFormats,
      widget.startingDayOfWeek,
      initialFormat: widget.initialCalendarFormat,
      initialDay: widget.selectedDay,
      onVisibleDaysChanged: widget.onVisibleDaysChanged,
      includeInvisibleDays: widget.calendarStyle.outsideDaysVisible,
    );
  }

  @override
  void didUpdateWidget(TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != null && widget.selectedDay != null) {
      if (!Utils.isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() {
            final runCallback = _calendarLogic.setSelectedDay(
              widget.selectedDay,
              isAnimated: widget.animateProgSelectedDay,
              isProgrammatic: true,
            );

            if (runCallback && widget.onDaySelected != null) {
              final key = widget.events.keys.firstWhere(
                (it) => Utils.isSameDay(it, widget.selectedDay),
                orElse: () => null,
              );
              widget.onDaySelected(widget.selectedDay, widget.events[key] ?? []);
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _calendarLogic.dispose();
    super.dispose();
  }

  void _selectPrevious() {
    setState(() {
      _calendarLogic.selectPrevious();
    });
  }

  void _selectNext() {
    setState(() {
      _calendarLogic.selectNext();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _calendarLogic.setSelectedDay(date);

      if (widget.onDaySelected != null) {
        final key = widget.events.keys.firstWhere((it) => Utils.isSameDay(it, date), orElse: () => null);
        widget.onDaySelected(date, widget.events[key] ?? []);
      }
    });
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarLogic.toggleCalendarFormat();
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

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (widget.headerVisible) {
      children.addAll([
        const SizedBox(height: 6.0),
        _buildHeader(),
      ]);
    }

    children.addAll([
      const SizedBox(height: 10.0),
      _buildCalendarContent(),
      const SizedBox(height: 4.0),
    ]);

    return ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildHeader() {
    final children = [
      CustomIconButton(
        icon: widget.headerStyle.leftChevronIcon,
        onTap: _selectPrevious,
        margin: widget.headerStyle.leftChevronMargin,
        padding: widget.headerStyle.leftChevronPadding,
      ),
      Expanded(
        child: Text(
          widget.headerStyle.titleTextBuilder != null
              ? widget.headerStyle.titleTextBuilder(_calendarLogic.focusedDay, widget.locale)
              : DateFormat.yMMMM(widget.locale).format(_calendarLogic.focusedDay),
          style: widget.headerStyle.titleTextStyle,
          textAlign: widget.headerStyle.centerHeaderTitle ? TextAlign.center : TextAlign.start,
        ),
      ),
      CustomIconButton(
        icon: widget.headerStyle.rightChevronIcon,
        onTap: _selectNext,
        margin: widget.headerStyle.rightChevronMargin,
        padding: widget.headerStyle.rightChevronPadding,
      ),
    ];

    if (widget.headerStyle.formatButtonVisible &&
        widget.availableCalendarFormats.length > 1 &&
        widget.forcedCalendarFormat == null) {
      children.insert(2, const SizedBox(width: 8.0));
      children.insert(3, _buildFormatButton());
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: children,
    );
  }

  Widget _buildFormatButton() {
    return GestureDetector(
      onTap: _toggleCalendarFormat,
      child: Container(
        decoration: widget.headerStyle.formatButtonDecoration,
        padding: widget.headerStyle.formatButtonPadding,
        child: Text(
          _calendarLogic.formatButtonText,
          style: widget.headerStyle.formatButtonTextStyle,
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    if (widget.formatAnimation == FormatAnimation.slide) {
      return AnimatedSize(
        duration: Duration(milliseconds: _calendarLogic.calendarFormat == CalendarFormat.month ? 330 : 220),
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
          key: ValueKey(_calendarLogic.calendarFormat),
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: wrappedChild,
    );
  }

  Widget _buildVerticalSwipeWrapper({Widget child}) {
    return SimpleGestureDetector(
      child: child,
      onVerticalSwipe: (direction) {
        setState(() {
          _calendarLogic.swipeCalendarFormat(direction == SwipeDirection.up);
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
          position: Tween<Offset>(begin: Offset(_calendarLogic.dx, 0), end: Offset(0, 0)).animate(animation),
          child: child,
        );
      },
      layoutBuilder: (currentChild, _) => currentChild,
      child: Dismissible(
        key: ValueKey(_calendarLogic.pageId),
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
      _buildDaysOfWeek(),
    ];

    int x = 0;
    while (x < _calendarLogic.visibleDays.length) {
      children.add(_buildTableRow(_calendarLogic.visibleDays.skip(x).take(daysInWeek).toList()));
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
      children: _calendarLogic.visibleDays.take(7).map((date) {
        return Center(
          child: Text(
            widget.daysOfWeekStyle.dowTextBuilder != null
                ? widget.daysOfWeekStyle.dowTextBuilder(date, widget.locale)
                : DateFormat.E(widget.locale).format(date),
            style: _calendarLogic.isWeekend(date)
                ? widget.daysOfWeekStyle.weekendStyle
                : widget.daysOfWeekStyle.weekdayStyle,
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<DateTime> days) {
    return TableRow(children: days.map((date) => _buildTableCell(date)).toList());
  }

  // TableCell will have equal width and height
  Widget _buildTableCell(DateTime date) {
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxWidth,
              minHeight: constraints.maxWidth,
            ),
            child: _buildCell(date),
          ),
    );
  }

  Widget _buildCell(DateTime date) {
    if (!widget.calendarStyle.outsideDaysVisible &&
        _calendarLogic.isExtraDay(date) &&
        _calendarLogic.calendarFormat == CalendarFormat.month) {
      return Container();
    }

    Widget content = _buildCellContent(date);

    final key = widget.events.keys.firstWhere((it) => Utils.isSameDay(it, date), orElse: () => null);
    if (key != null && widget.events[key].isNotEmpty) {
      final children = <Widget>[content];

      if (widget.builders.markersBuilder != null) {
        children.add(
          Builder(
            builder: (context) => widget.builders.markersBuilder(context, key, widget.events[key]),
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
              children: widget.events[key]
                  .take(widget.calendarStyle.markersMaxAmount)
                  .map(
                    (event) => _buildMarker(key, event),
                  )
                  .toList(),
            ),
          ),
        );
      }

      content = Stack(
        alignment: widget.calendarStyle.markersAlignment,
        children: children,
      );
    }

    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _selectDate(date),
      child: content,
    );
  }

  Widget _buildCellContent(DateTime date) {
    final key = widget.events.keys.firstWhere((it) => Utils.isSameDay(it, date), orElse: () => null);
    if (widget.builders.selectedDayBuilder != null && _calendarLogic.isSelected(date)) {
      return Builder(
        builder: (context) => widget.builders.selectedDayBuilder(context, date, widget.events[key]),
      );
    } else if (widget.builders.todayDayBuilder != null && _calendarLogic.isToday(date)) {
      return Builder(
        builder: (context) => widget.builders.todayDayBuilder(context, date, widget.events[key]),
      );
    } else if (widget.builders.outsideWeekendDayBuilder != null &&
        _calendarLogic.isExtraDay(date) &&
        _calendarLogic.isWeekend(date)) {
      return Builder(
        builder: (context) => widget.builders.outsideWeekendDayBuilder(context, date, widget.events[key]),
      );
    } else if (widget.builders.outsideDayBuilder != null && _calendarLogic.isExtraDay(date)) {
      return Builder(
        builder: (context) => widget.builders.outsideDayBuilder(context, date, widget.events[key]),
      );
    } else if (widget.builders.weekendDayBuilder != null && _calendarLogic.isWeekend(date)) {
      return Builder(
        builder: (context) => widget.builders.weekendDayBuilder(context, date, widget.events[key]),
      );
    } else if (widget.builders.dayBuilder != null) {
      return Builder(
        builder: (context) => widget.builders.dayBuilder(context, date, widget.events[key]),
      );
    } else {
      return CellWidget(
        text: '${date.day}',
        isSelected: _calendarLogic.isSelected(date),
        isToday: _calendarLogic.isToday(date),
        isWeekend: _calendarLogic.isWeekend(date),
        isOutsideMonth: _calendarLogic.isExtraDay(date),
        calendarStyle: widget.calendarStyle,
      );
    }
  }

  Widget _buildMarker(DateTime date, dynamic event) {
    if (widget.builders.singleMarkerBuilder != null) {
      return Builder(
        builder: (context) => widget.builders.singleMarkerBuilder(context, date, event),
      );
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
