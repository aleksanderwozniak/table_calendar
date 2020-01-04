//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

/// Class containing styling for `TableCalendar`'s content.
class CalendarStyle {
  /// Style of foreground Text for regular weekdays.
  final TextStyle weekdayStyle;

  /// Style of foreground Text for regular weekends.
  final TextStyle weekendStyle;

  /// Style of foreground Text for holidays.
  final TextStyle holidayStyle;

  /// Style of foreground Text for selected day.
  final TextStyle selectedStyle;

  /// Style of foreground Text for today.
  final TextStyle todayStyle;

  /// Style of foreground Text for weekdays outside of current month.
  final TextStyle outsideStyle;

  /// Style of foreground Text for weekends outside of current month.
  final TextStyle outsideWeekendStyle;

  /// Style of foreground Text for holidays outside of current month.
  final TextStyle outsideHolidayStyle;

  /// Style of foreground Text for days outside of `startDay` - `endDay` Date range.
  final TextStyle unavailableStyle;

  /// Background Color of selected day.
  final Color selectedColor;

  /// Background Color of today.
  final Color todayColor;

  /// Color of event markers placed on the bottom of every day containing events.
  final Color markersColor;

  /// General `Alignment` for event markers.
  /// NOTE: `markersPositionBottom` defaults to `5.0`, so you might want to set it to `null` when using `markersAlignment`.
  final Alignment markersAlignment;

  /// `top` property of `Positioned` widget used for event markers.
  final double markersPositionTop;

  /// `bottom` property of `Positioned` widget used for event markers.
  /// NOTE: This defaults to `5.0`, so you might occasionally want to set it to `null`.
  final double markersPositionBottom;

  /// `left` property of `Positioned` widget used for event markers.
  final double markersPositionLeft;

  /// `right` property of `Positioned` widget used for event markers.
  final double markersPositionRight;

  /// Maximum amount of event markers to be displayed.
  final int markersMaxAmount;

  /// Specifies whether or not days outside of current month should be displayed.
  ///
  /// Sometimes a fragment of previous month's last week (or next month's first week) appears in current month's view.
  /// This property defines if those should be visible (eg. with custom style) or hidden.
  final bool outsideDaysVisible;

  /// Determines rendering priority for SelectedDay and Today.
  /// * `true` - SelectedDay will have higher priority than Today
  /// * `false` - Today will have higher priority than SelectedDay
  final bool renderSelectedFirst;

  /// Determines whether the row of days of the week should be rendered or not.
  final bool renderDaysOfWeek;

  /// Padding of `TableCalendar`'s content.
  final EdgeInsets contentPadding;

  /// Specifies if event markers rendered for a day cell can overflow cell's boundaries.
  /// * `true` - Event markers will be drawn over the cell boundaries
  /// * `false` - Event markers will not be drawn over the cell boundaries and will be clipped if they are too big
  final bool canEventMarkersOverflow;

  /// Specifies whether or not SelectedDay should be highlighted.
  final bool highlightSelected;

  /// Specifies whether or not Today should be highlighted.
  final bool highlightToday;

  const CalendarStyle({
    this.weekdayStyle = const TextStyle(),
    this.weekendStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
    this.holidayStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
    this.selectedStyle = const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0), // Material grey[50]
    this.todayStyle = const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0), // Material grey[50]
    this.outsideStyle = const TextStyle(color: const Color(0xFF9E9E9E)), // Material grey[500]
    this.outsideWeekendStyle = const TextStyle(color: const Color(0xFFEF9A9A)), // Material red[200]
    this.outsideHolidayStyle = const TextStyle(color: const Color(0xFFEF9A9A)), // Material red[200]
    this.unavailableStyle = const TextStyle(color: const Color(0xFFBFBFBF)),
    this.selectedColor = const Color(0xFF5C6BC0), // Material indigo[400]
    this.todayColor = const Color(0xFF9FA8DA), // Material indigo[200]
    this.markersColor = const Color(0xFF263238), // Material blueGrey[900]
    this.markersAlignment = Alignment.bottomCenter,
    this.markersPositionTop,
    this.markersPositionBottom = 5.0,
    this.markersPositionLeft,
    this.markersPositionRight,
    this.markersMaxAmount = 4,
    this.outsideDaysVisible = true,
    this.renderSelectedFirst = true,
    this.renderDaysOfWeek = true,
    this.contentPadding = const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
    this.canEventMarkersOverflow = false,
    this.highlightSelected = true,
    this.highlightToday = true,
  });
}
