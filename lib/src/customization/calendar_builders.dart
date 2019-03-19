import 'package:flutter/material.dart';

typedef FullBuilder = Widget Function(BuildContext context, DateTime date, List events);
typedef SingleMarkerBuilder = Widget Function(BuildContext context, DateTime date, dynamic event);

class CalendarBuilders {
  final FullBuilder dayBuilder;
  final FullBuilder selectedDayBuilder;
  final FullBuilder todayDayBuilder;
  final FullBuilder weekendDayBuilder;
  final FullBuilder outsideDayBuilder;
  final FullBuilder outsideWeekendDayBuilder;
  final FullBuilder markersBuilder;
  final SingleMarkerBuilder singleMarkerBuilder;

  const CalendarBuilders({
    this.dayBuilder,
    this.selectedDayBuilder,
    this.todayDayBuilder,
    this.weekendDayBuilder,
    this.outsideDayBuilder,
    this.outsideWeekendDayBuilder,
    this.markersBuilder,
    this.singleMarkerBuilder,
  }) : assert(!(singleMarkerBuilder != null && markersBuilder != null));
}
