//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

/// Class containing styling for `TableCalendar`'s days of week panel.
class DaysOfWeekStyle {
  /// Use to customize days of week panel text (eg. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'E'` format (eg. Mon, Tue, Wed, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// dowTextBuilder: (date, locale) => DateFormat.E(locale).format(date)[0],
  /// ```
  final TextBuilder dowTextBuilder;

  /// Style for weekdays on the top of Calendar.
  final TextStyle weekdayStyle;

  /// Style for weekend days on the top of Calendar.
  final TextStyle weekendStyle;

  const DaysOfWeekStyle({
    this.dowTextBuilder,
    this.weekdayStyle = const TextStyle(color: const Color(0xFF616161)), // Material grey[700]
    this.weekendStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
  });
}
