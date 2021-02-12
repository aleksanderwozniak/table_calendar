// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../shared/utils.dart' show TextFormatter;

/// Class containing styling and configuration of `TableCalendar`'s header.
class HeaderStyle {
  /// Responsible for making title Text centered.
  final bool titleCentered;

  /// Responsible for FormatButton visibility.
  final bool formatButtonVisible;

  /// Controls the text inside FormatButton.
  /// * `true` - the button will show next CalendarFormat
  /// * `false` - the button will show current CalendarFormat
  final bool formatButtonShowsNext;

  /// Use to customize header's title text (e.g. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'yMMMM'` format (i.e. January 2019, February 2019, March 2019, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// titleTextFormatter: (date, locale) => DateFormat.yM(locale).format(date),
  /// ```
  final TextFormatter titleTextFormatter;

  /// Style for title Text (month-year) displayed in header.
  final TextStyle titleTextStyle;

  /// Style for FormatButton `Text`.
  final TextStyle formatButtonTextStyle;

  /// Background `Decoration` for FormatButton.
  final Decoration formatButtonDecoration;

  /// Inside padding of the whole header.
  final EdgeInsets headerPadding;

  /// Outside margin of the whole header.
  final EdgeInsets headerMargin;

  /// Inside padding for FormatButton.
  final EdgeInsets formatButtonPadding;

  /// Inside padding for left chevron.
  final EdgeInsets leftChevronPadding;

  /// Inside padding for right chevron.
  final EdgeInsets rightChevronPadding;

  /// Outside margin for left chevron.
  final EdgeInsets leftChevronMargin;

  /// Outside margin for right chevron.
  final EdgeInsets rightChevronMargin;

  /// Icon used for left chevron.
  /// Defaults to `Icon(Icons.chevron_left)`.
  final Icon leftChevronIcon;

  /// Icon used for right chevron.
  /// Defaults to `Icon(Icons.chevron_right)`.
  final Icon rightChevronIcon;

  /// Determines left chevron's visibility.
  /// Defaults to `true`.
  final bool leftChevronVisible;

  /// Determines right chevron's visibility.
  /// Defaults to `true`.
  final bool rightChevronVisible;

  /// Header decoration, used to draw border or shadow or change color of the header
  final Decoration decoration;

  /// Creates a `HeaderStyle` used by `TableCalendar` widget.
  const HeaderStyle({
    this.titleCentered = false,
    this.formatButtonVisible = true,
    this.formatButtonShowsNext = true,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatButtonTextStyle = const TextStyle(),
    this.formatButtonDecoration = const BoxDecoration(
      border: const Border.fromBorderSide(BorderSide()),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
    this.headerMargin,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.formatButtonPadding =
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.leftChevronIcon = const Icon(Icons.chevron_left),
    this.rightChevronIcon = const Icon(Icons.chevron_right),
    this.leftChevronVisible = true,
    this.rightChevronVisible = true,
    this.decoration = const BoxDecoration(),
  });
}
