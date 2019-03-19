import 'package:flutter/material.dart';

/// Class containing styling for `TableCalendar`'s days of week panel.
class DaysOfWeekStyle {
  /// Style for weekdays on the top of Calendar.
  final TextStyle weekdayStyle;

  /// Style for weekend days on the top of Calendar.
  final TextStyle weekendStyle;

  const DaysOfWeekStyle({
    this.weekdayStyle = const TextStyle(color: const Color(0xFF616161)), // Material grey[700]
    this.weekendStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
  });
}
