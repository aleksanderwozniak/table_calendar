//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

/// Main Builder signature for `TableCalendar`. Contains `date` and list of all `events` associated with that `date`.
/// Note that most of the time, `events` param will be ommited, however it is there if needed.
/// `events` param can be null.
typedef FullBuilder = Widget Function(BuildContext context, DateTime date, List events);

/// Builder signature for a list of event markers. Contains `date` and list of all `events` associated with that `date`.
/// Both `events` and `holidays` params can be null.
typedef FullListBuilder = List<Widget> Function(BuildContext context, DateTime date, List events, List holidays);

/// Builder signature for weekday names row. Contains `weekday` string, which is formatted by `dowTextBuilder`
/// or by default function (DateFormat.E(widget.locale).format(date)), if `dowTextBuilder` is null.
typedef DowBuilder = Widget Function(BuildContext context, String weekday);

/// Builder signature for a single event marker. Contains `date` and a single `event` associated with that `date`.
typedef SingleMarkerBuilder = Widget Function(BuildContext context, DateTime date, dynamic event);

/// Class containing all custom Builders for `TableCalendar`.
class CalendarBuilders {
  /// The most general custom Builder. Use to provide your own UI for every day cell.
  /// If `dayBuilder` is not specified, a default day cell will be displayed.
  /// Default day cells are customizable with `CalendarStyle`.
  final FullBuilder dayBuilder;

  /// Custom Builder for currently selected day. Will overwrite `dayBuilder` on selected day.
  final FullBuilder selectedDayBuilder;

  /// Custom Builder for today. Will overwrite `dayBuilder` on today.
  final FullBuilder todayDayBuilder;

  /// Custom Builder for holidays. Will overwrite `dayBuilder` on holidays.
  final FullBuilder holidayDayBuilder;

  /// Custom Builder for weekends. Will overwrite `dayBuilder` on weekends.
  final FullBuilder weekendDayBuilder;

  /// Custom Builder for days outside of current month. Will overwrite `dayBuilder` on days outside of current month.
  final FullBuilder outsideDayBuilder;

  /// Custom Builder for weekends outside of current month. Will overwrite `dayBuilder`on weekends outside of current month.
  final FullBuilder outsideWeekendDayBuilder;

  /// Custom Builder for holidays outside of current month. Will overwrite `dayBuilder` on holidays outside of current month.
  final FullBuilder outsideHolidayDayBuilder;

  /// Custom Builder for days outside of `startDay` - `endDay` Date range. Will overwrite `dayBuilder` for aforementioned days.
  final FullBuilder unavailableDayBuilder;

  /// Custom Builder for a whole group of event markers. Use to provide your own marker UI for each day cell.
  /// Every `Widget` passed here will be placed in a `Stack`, above the cell content.
  /// Wrap them with `Positioned` to gain more control over their placement.
  ///
  /// If `markersBuilder` is not specified, `TableCalendar` will try to use `singleMarkerBuilder` or default markers (customizable with `CalendarStyle`).
  /// Mutually exclusive with `singleMarkerBuilder`.
  final FullListBuilder markersBuilder;

  /// Custom Builder for a single event marker. Each of those will be displayed in a `Row` above of the day cell.
  /// You can adjust markers' position with `CalendarStyle` properties.
  ///
  /// If `singleMarkerBuilder` is not specified, a default event marker will be displayed (customizable with `CalendarStyle`).
  /// Mutually exclusive with `markersBuilder`.
  final SingleMarkerBuilder singleMarkerBuilder;

  /// Custom builder for dow weekday names (displayed between `HeaderRow` and calendar days).
  /// Will overwrite `weekdayStyle` and `weekendStyle` from `DaysOfWeekStyle`.
  final DowBuilder dowWeekdayBuilder;

  /// Custom builder for dow weekend names (displayed between `HeaderRow` and calendar days).
  /// Will overwrite `weekendStyle` from `DaysOfWeekStyle` and `dowWeekdayBuilder` for weekends, if it also exists.
  final DowBuilder dowWeekendBuilder;

  const CalendarBuilders({
    this.dayBuilder,
    this.selectedDayBuilder,
    this.todayDayBuilder,
    this.holidayDayBuilder,
    this.weekendDayBuilder,
    this.outsideDayBuilder,
    this.outsideWeekendDayBuilder,
    this.outsideHolidayDayBuilder,
    this.unavailableDayBuilder,
    this.markersBuilder,
    this.singleMarkerBuilder,
    this.dowWeekdayBuilder,
    this.dowWeekendBuilder,
  }) : assert(!(singleMarkerBuilder != null && markersBuilder != null));
}
