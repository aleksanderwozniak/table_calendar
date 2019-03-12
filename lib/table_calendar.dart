//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

library table_calendar;

import 'package:flutter/material.dart';

import 'src/calendar_logic.dart';
import 'src/cell_widget.dart';
import 'src/custom_icon_button.dart';

typedef void OnDaySelected(DateTime day);
typedef void OnFormatChanged(CalendarFormat format);

enum CalendarFormat { month, twoWeeks, week }

class TableCalendar extends StatefulWidget {
  final Map<DateTime, List> events;
  final OnDaySelected onDaySelected;
  final OnFormatChanged onFormatChanged;
  final Color selectedColor;
  final Color todayColor;
  final Color eventMarkerColor;
  final Color iconColor;
  final DateTime initialDate;
  final CalendarFormat initialCalendarFormat;
  final CalendarFormat forcedCalendarFormat;
  final List<CalendarFormat> availableCalendarFormats;
  final TextStyle formatToggleTextStyle;
  final Decoration formatToggleDecoration;
  final EdgeInsets formatTogglePadding;
  final bool formatToggleVisible;
  final bool centerHeaderTitle;
  final bool headerVisible;
  final EdgeInsets leftChevronPadding;
  final EdgeInsets rightChevronPadding;
  final EdgeInsets leftChevronMargin;
  final EdgeInsets rightChevronMargin;

  TableCalendar({
    Key key,
    this.events = const {},
    this.onDaySelected,
    this.onFormatChanged,
    this.selectedColor,
    this.todayColor,
    this.eventMarkerColor,
    this.iconColor = Colors.black,
    this.initialDate,
    this.initialCalendarFormat = CalendarFormat.month,
    this.forcedCalendarFormat,
    this.availableCalendarFormats = const [CalendarFormat.month, CalendarFormat.twoWeeks, CalendarFormat.week],
    this.formatToggleTextStyle = const TextStyle(),
    this.formatToggleDecoration,
    this.formatTogglePadding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.formatToggleVisible = false,
    this.centerHeaderTitle = true,
    this.headerVisible = true,
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
  })  : assert(availableCalendarFormats.contains(initialCalendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        super(key: key);

  @override
  _TableCalendarState createState() {
    return new _TableCalendarState();
  }
}

class _TableCalendarState extends State<TableCalendar> {
  CalendarLogic _calendarLogic;
  double _dx;

  @override
  void initState() {
    super.initState();
    _calendarLogic = CalendarLogic(
      widget.initialCalendarFormat,
      widget.availableCalendarFormats,
      initialDate: widget.initialDate,
    );
    _dx = 0;
  }

  void _selectPrevious() {
    setState(() {
      _calendarLogic.selectPrevious();
    });

    _dx = -1.2;
  }

  void _selectNext() {
    setState(() {
      _calendarLogic.selectNext();
    });

    _dx = 1.2;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _calendarLogic.selectedDate = date;
    });

    if (widget.onDaySelected != null) {
      widget.onDaySelected(date);
    }
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarLogic.toggleCalendarFormat();
    });

    if (widget.onFormatChanged != null) {
      widget.onFormatChanged(_calendarLogic.calendarFormat);
    }
  }

  void _onSwipe(DismissDirection direction) {
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
      _buildTable(),
      const SizedBox(height: 4.0),
    ]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildHeader() {
    final headerStyle = TextStyle().copyWith(fontSize: 17.0);
    final children = [
      CustomIconButton(
        icon: Icon(Icons.chevron_left, color: widget.iconColor),
        onTap: _selectPrevious,
        margin: widget.leftChevronMargin,
        padding: widget.leftChevronPadding,
      ),
      Expanded(
        child: Text(
          _calendarLogic.headerText,
          style: headerStyle,
          textAlign: widget.centerHeaderTitle ? TextAlign.center : TextAlign.start,
        ),
      ),
      CustomIconButton(
        icon: Icon(Icons.chevron_right, color: widget.iconColor),
        onTap: _selectNext,
        margin: widget.rightChevronMargin,
        padding: widget.rightChevronPadding,
      ),
    ];

    if (widget.formatToggleVisible && widget.availableCalendarFormats.length > 1 && widget.forcedCalendarFormat == null) {
      children.insert(2, const SizedBox(width: 8.0));
      children.insert(3, _buildHeaderToggle());
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: children,
    );
  }

  Widget _buildHeaderToggle() {
    return GestureDetector(
      onTap: _toggleCalendarFormat,
      child: Container(
        decoration: widget.formatToggleDecoration ??
            BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12.0),
            ),
        padding: widget.formatTogglePadding,
        child: Text(
          _calendarLogic.headerToggleText,
          style: widget.formatToggleTextStyle,
        ),
      ),
    );
  }

  Widget _buildTable() {
    final children = <TableRow>[];
    final daysInWeek = 7;
    final calendarFormat = widget.forcedCalendarFormat != null ? widget.forcedCalendarFormat : _calendarLogic.calendarFormat;

    children.add(_buildDaysOfWeek());

    if (calendarFormat == CalendarFormat.week) {
      children.add(_buildTableRow(_calendarLogic.visibleWeek.toList()));
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      children.add(_buildTableRow(_calendarLogic.visibleTwoWeeks.take(daysInWeek).toList()));
      children.add(_buildTableRow(_calendarLogic.visibleTwoWeeks.skip(daysInWeek).toList()));
    } else {
      int x = 0;
      while (x < _calendarLogic.visibleMonth.length) {
        children.add(_buildTableRow(_calendarLogic.visibleMonth.skip(x).take(daysInWeek).toList()));
        x += daysInWeek;
      }
    }

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
      child: Container(
        key: ValueKey(_calendarLogic.calendarFormat),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.decelerate,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(begin: Offset(_dx, 0), end: Offset(0, 0)).animate(animation),
              child: child,
            );
          },
          layoutBuilder: (currentChild, _) => currentChild,
          child: Dismissible(
            key: ValueKey(_calendarLogic.pageId),
            resizeDuration: null,
            onDismissed: _onSwipe,
            direction: DismissDirection.horizontal,
            child: Table(
              // Makes this Table fill its parent horizontally
              defaultColumnWidth: FractionColumnWidth(1.0 / daysInWeek),
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildDaysOfWeek() {
    final daysOfWeek = _calendarLogic.daysOfWeek;
    final children = <Widget>[];

    final weekdayStyle = TextStyle().copyWith(color: Colors.grey[700], fontSize: 15.0);
    final weekendStyle = TextStyle().copyWith(color: Colors.red[500], fontSize: 15.0);

    children.add(Center(child: Text(daysOfWeek.first, style: weekendStyle)));
    children.addAll(
      daysOfWeek.sublist(1, daysOfWeek.length - 1).map(
            (text) => Center(
                  child: Text(text, style: weekdayStyle),
                ),
          ),
    );
    children.add(Center(child: Text(daysOfWeek.last, style: weekendStyle)));

    return TableRow(children: children);
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
            child: _buildCellContent(date),
          ),
    );
  }

  Widget _buildCellContent(DateTime date) {
    Widget content = CellWidget(
      text: '${date.day}',
      isSelected: _calendarLogic.isSelected(date),
      isToday: _calendarLogic.isToday(date),
      isWeekend: _calendarLogic.isWeekend(date),
      isOutsideMonth: _calendarLogic.isExtraDay(date),
      selectedColor: widget.selectedColor,
      todayColor: widget.todayColor,
    );

    if (widget.events.containsKey(date) && widget.events[date].isNotEmpty) {
      final children = <Widget>[content];
      final maxMarkers = 4;

      children.add(
        Positioned(
          bottom: 5.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.events[date].take(maxMarkers).map((_) => _buildMarker()).toList(),
          ),
        ),
      );

      content = Stack(
        alignment: Alignment.bottomCenter,
        children: children,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectDate(date),
      child: content,
    );
  }

  Widget _buildMarker() {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 0.3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.eventMarkerColor ?? Colors.blueGrey[900],
      ),
    );
  }
}
