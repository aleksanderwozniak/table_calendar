//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';

/// Class containing styling and configuration of `TableCalendar`'s header.
class HeaderStyle {
  /// Responsible for making title Text centered.
  final bool centerHeaderTitle;

  /// Responsible for FormatButton visibility.
  final bool formatButtonVisible;

  /// Style for title Text (month-year) displayed in header.
  final TextStyle titleTextStyle;

  /// Style for FormatButton Text.
  final TextStyle formatButtonTextStyle;

  /// Background Decoration for FormatButton.
  final Decoration formatButtonDecoration;

  /// Inside Padding for FormatButton.
  final EdgeInsets formatButtonPadding;

  /// Inside Padding for left chevron.
  final EdgeInsets leftChevronPadding;

  /// Inside Padding for right chevron.
  final EdgeInsets rightChevronPadding;

  /// Outside Margin for left chevron.
  final EdgeInsets leftChevronMargin;

  /// Outside Margin for right chevron.
  final EdgeInsets rightChevronMargin;

  /// Icon used for left chevron.
  /// Defaults to black `Icons.chevron_left`.
  final Icon leftChevronIcon;

  /// Icon used for right chevron.
  /// Defaults to black `Icons.chevron_right`.
  final Icon rightChevronIcon;

  const HeaderStyle({
    this.centerHeaderTitle = false,
    this.formatButtonVisible = true,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatButtonTextStyle = const TextStyle(),
    this.formatButtonDecoration = const BoxDecoration(
      border: const Border(top: BorderSide(), bottom: BorderSide(), left: BorderSide(), right: BorderSide()),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
    this.formatButtonPadding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.leftChevronIcon = const Icon(Icons.chevron_left, color: Colors.black),
    this.rightChevronIcon = const Icon(Icons.chevron_right, color: Colors.black),
  });
}
