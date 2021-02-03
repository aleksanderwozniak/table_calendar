// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

part of table_calendar;

class CalendarStyle {
  /// Maximum amount of event markers to be displayed.
  final int markersMaxAmount;
  final AlignmentGeometry markersAlignment;
  final bool markersAutoAligned;
  final bool canMarkersOverflow;
  final double markerSize;
  final double markerSizeScale;
  final double markerPosition;
  final PositionedOffset markersOffset;
  final Decoration markerDecoration;

  final EdgeInsets markerMargin;
  final EdgeInsets cellMargin;

  final double rangeFillScale;
  final Color rangeFillColor;

  final bool outsideDaysVisible;
  final bool isTodayHighlighted;

  final TextStyle todayTextStyle;
  final Decoration todayDecoration;

  final TextStyle selectedTextStyle;
  final Decoration selectedDecoration;

  final TextStyle rangeStartTextStyle;
  final Decoration rangeStartDecoration;

  final TextStyle rangeEndTextStyle;
  final Decoration rangeEndDecoration;

  final TextStyle withinRangeTextStyle;
  final Decoration withinRangeDecoration;

  final TextStyle outsideTextStyle;
  final Decoration outsideDecoration;

  final TextStyle disabledTextStyle;
  final Decoration disabledDecoration;

  final TextStyle holidayTextStyle;
  final Decoration holidayDecoration;

  final TextStyle weekendTextStyle;
  final Decoration weekendDecoration;

  final TextStyle defaultTextStyle;
  final Decoration defaultDecoration;

  final Decoration rowDecoration;

  const CalendarStyle({
    this.isTodayHighlighted = true,
    this.canMarkersOverflow = true,
    this.outsideDaysVisible = true,
    this.markersAutoAligned = true,
    this.markerSize,
    this.markerSizeScale = 0.2,
    this.markerPosition = 0.7,
    this.rangeFillScale = 1.0,
    this.markerMargin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.markersAlignment = Alignment.bottomCenter,
    this.markersMaxAmount = 4,
    this.cellMargin = const EdgeInsets.all(6.0),
    this.markersOffset = const PositionedOffset(),
    this.rangeFillColor = const Color(0xFFBBDDFF),
    this.markerDecoration = const BoxDecoration(
        color: const Color(0xFF263238), shape: BoxShape.circle),
    this.todayTextStyle =
        const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0), //
    this.todayDecoration = const BoxDecoration(
        color: const Color(0xFF9FA8DA), shape: BoxShape.circle),
    this.selectedTextStyle =
        const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0),
    this.selectedDecoration = const BoxDecoration(
        color: const Color(0xFF5C6BC0), shape: BoxShape.circle),
    this.rangeStartTextStyle =
        const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0),
    this.rangeStartDecoration = const BoxDecoration(
        color: const Color(0xFF6699FF), shape: BoxShape.circle),
    this.rangeEndTextStyle =
        const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0),
    this.rangeEndDecoration = const BoxDecoration(
        color: const Color(0xFF6699FF), shape: BoxShape.circle),
    this.withinRangeTextStyle = const TextStyle(),
    this.withinRangeDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.outsideTextStyle = const TextStyle(color: const Color(0xFFAEAEAE)),
    this.outsideDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.disabledTextStyle = const TextStyle(color: const Color(0xFFBFBFBF)),
    this.disabledDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.holidayTextStyle = const TextStyle(color: const Color(0xFF5C6BC0)),
    this.holidayDecoration = const BoxDecoration(
      border: const Border.fromBorderSide(
        const BorderSide(color: const Color(0xFF9FA8DA), width: 1.4),
      ),
      shape: BoxShape.circle,
    ),
    this.weekendTextStyle = const TextStyle(color: const Color(0xFF5A5A5A)),
    this.weekendDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.defaultTextStyle = const TextStyle(),
    this.defaultDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.rowDecoration = const BoxDecoration(),
  });
}

class PositionedOffset {
  final double top;
  final double bottom;
  final double start;
  final double end;

  const PositionedOffset({this.top, this.bottom, this.start, this.end});
}
