//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';

/// Class containing styling for `TableCalendar`'s days of week panel.
class DaysOfWeekStyle {
  /// Skeleton used for formatting the day of week text.
  /// Defaults to `'E'` (eg. Mon, Tue, Wed).
  ///
  /// For more info refer to
  /// https://docs.flutter.io/flutter/intl/DateFormat-class.html
  final String textFormatSkeleton;

  /// Style for weekdays on the top of Calendar.
  final TextStyle weekdayStyle;

  /// Style for weekend days on the top of Calendar.
  final TextStyle weekendStyle;

  const DaysOfWeekStyle({
    this.textFormatSkeleton = 'E',
    this.weekdayStyle = const TextStyle(color: const Color(0xFF616161)), // Material grey[700]
    this.weekendStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
  });
}
