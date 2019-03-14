import 'package:flutter/material.dart';

class HeaderStyle {
  final Color iconColor;
  final bool centerHeaderTitle;
  final bool formatToggleVisible;
  final TextStyle titleTextStyle;
  final TextStyle formatToggleTextStyle;
  final Decoration formatToggleDecoration;
  final EdgeInsets formatTogglePadding;
  final EdgeInsets leftChevronPadding;
  final EdgeInsets rightChevronPadding;
  final EdgeInsets leftChevronMargin;
  final EdgeInsets rightChevronMargin;

  const HeaderStyle({
    this.iconColor = Colors.black,
    this.centerHeaderTitle = false,
    this.formatToggleVisible = true,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatToggleTextStyle = const TextStyle(),
    this.formatToggleDecoration = const BoxDecoration(
      border: const Border(top: BorderSide(), bottom: BorderSide(), left: BorderSide(), right: BorderSide()),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
    this.formatTogglePadding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
  });
}
