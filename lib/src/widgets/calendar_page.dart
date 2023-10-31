// Copyright 2019 Aleksander Woźniak & Sneh Mehta
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, DateTimeRange range)?
      overlayBuilder;
  final Widget Function(BuildContext context, DateTime day)? dowBuilder;
  final Widget Function(BuildContext context, DateTime day) dayBuilder;
  final Widget Function(BuildContext context, DateTime day)? weekNumberBuilder;
  final List<DateTime> visibleDays;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final EdgeInsets? tablePadding;
  final bool dowVisible;
  final bool weekNumberVisible;
  final double? dowHeight;
  final double? rowHeight;
  final List<DateTimeRange>? overlayRanges;

  const CalendarPage({
    Key? key,
    required this.visibleDays,
    this.dowBuilder,
    required this.dayBuilder,
    this.weekNumberBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.tablePadding,
    this.dowVisible = true,
    this.weekNumberVisible = false,
    this.dowHeight,
    this.rowHeight = 52,
    this.overlayBuilder,
    this.overlayRanges,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(!weekNumberVisible || weekNumberBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: tablePadding ?? EdgeInsets.zero,
      child: Column(
        children: [
          if (dowVisible) _buildDaysOfWeek(context),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    gridDelegate: _DayPickerGridDelegate(rowHeight!),
                    itemCount: visibleDays.length,
                    itemBuilder: (context, index) {
                      final _day = visibleDays[index];
                      return dayBuilder(context, _day);
                    },
                  ),
                  if (overlayBuilder != null &&
                      (overlayRanges?.isNotEmpty ?? false))
                    getEventWidgets(
                      constraints: constraints,
                      context: context,
                      dateRanges: overlayRanges!,
                    )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  List<DateTimeRange> splitOverlays(List<DateTimeRange> overlays) {
    final List<DateTimeRange> ranges = [];
    overlays.map((overlay) {
      final range = splitRangeIntoWeeks(overlay);
      ranges.addAll(range);
    }).toList();

    return ranges;
  }

  List<DateTimeRange> splitRangeIntoWeeks(DateTimeRange dateRange) {
    DateTime startDate = dateRange.start;
    DateTime endDate = dateRange.end;

    List<DateTimeRange> range = [];

    for (int i = 0; i < visibleDays.length; i += 7) {
      DateTime rowStartDate = visibleDays[i];
      DateTime rowEndDate =
          visibleDays[math.min(i + 6, visibleDays.length - 1)];

      DateTime eventStartDate =
          (startDate.isAfter(rowStartDate)) ? startDate : rowStartDate;
      DateTime eventEndDate =
          (endDate.isBefore(rowEndDate)) ? endDate : rowEndDate;
      if (eventStartDate.isBefore(eventEndDate) ||
          eventStartDate.isAtSameMomentAs(eventEndDate)) {
        range.add(DateTimeRange(
          start: DateTime(
              eventStartDate.year, eventStartDate.month, eventStartDate.day),
          end:
              DateTime(eventEndDate.year, eventEndDate.month, eventEndDate.day),
        ));
      }
    }
    return range;
  }

  Widget getEventWidgets({
    required BuildContext context,
    required BoxConstraints constraints,
    required List<DateTimeRange> dateRanges,
  }) {
    final dividedDateRanges = splitOverlays(dateRanges);

    return CustomMultiChildLayout(
      delegate: CalendarLayoutDelegate(
        overlayRanges: dividedDateRanges,
        constraints: constraints,
        rowHeight: rowHeight ?? 52,
        visibleDays: visibleDays,
      ),
      children: dividedDateRanges.asMap().entries.map((entry) {
        return LayoutId(
          id: entry.key,
          child: overlayBuilder!.call(context, entry.value),
        );
      }).toList(),
    );
  }

  int getCellIndex(DateTime date) {
    return visibleDays.indexWhere((element) =>
        element.year == date.year &&
        element.month == date.month &&
        element.day == date.day);
  }

  double getTopOffset(DateTime date, double cellHeight) {
    int index = getCellIndex(date);
    return (index ~/ 7) * cellHeight;
  }

  double getLeftOffset(DateTime date, double cellWidth) {
    int index = getCellIndex(date);
    return (index % 7) * cellWidth;
  }

  double getWidgetWidth(
      DateTime startDate, DateTime endDate, double cellWidth) {
    int startIndex = getCellIndex(startDate);
    int endIndex = getCellIndex(endDate);
    return ((endIndex % 7) - (startIndex % 7) + 1) * cellWidth;
  }

  Widget _buildDaysOfWeek(BuildContext context) {
    return Row(
      children: List.generate(
        7,
        (index) => Expanded(child: dowBuilder!(context, visibleDays[index])),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate(this.rowHeight);

  final double rowHeight;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = rowHeight;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

class CalendarLayoutDelegate extends MultiChildLayoutDelegate {
  final List<DateTimeRange> overlayRanges;
  final BoxConstraints constraints;
  final double rowHeight;
  final List<DateTime> visibleDays;

  CalendarLayoutDelegate({
    required this.overlayRanges,
    required this.constraints,
    required this.rowHeight,
    required this.visibleDays,
  });

  @override
  void performLayout(Size size) {
    // Sort the range by start date so overlapping ranges are grouped together
    overlayRanges.sort((a, b) => a.start.compareTo(b.start));

    // Check for overlap and store indexes
    List<List<int>> overlapGroups = [];
    for (int i = 0; i < overlayRanges.length; i++) {
      if (i == 0) {
        overlapGroups.add([i]);
      } else {
        if (overlayRanges[i].start.isBefore(overlayRanges[i - 1].end)) {
          overlapGroups.last.add(i);
        } else {
          overlapGroups.add([i]);
        }
      }
    }

    overlapGroups.forEach((group) {
      double sharedHeight = rowHeight / group.length;

      double yOffset = 0;
      for (var i in group) {
        DateTime startDate = overlayRanges[i].start;
        DateTime endDate = overlayRanges[i].end;

        double xOffset = getLeftOffset(startDate, constraints.maxWidth / 7);
        yOffset = getTopOffset(startDate, size.height / 5) + yOffset;

        double widgetWidth =
            getWidgetWidth(startDate, endDate, constraints.maxWidth / 7);

        layoutChild(i,
            BoxConstraints.tightFor(width: widgetWidth, height: sharedHeight));

        positionChild(i, Offset(xOffset, yOffset));
        yOffset += sharedHeight;
      }
    });
  }

  @override
  bool shouldRelayout(CalendarLayoutDelegate oldDelegate) {
    return overlayRanges != oldDelegate.overlayRanges;
  }

  int getCellIndex(DateTime date) {
    return visibleDays.indexWhere((element) =>
        element.year == date.year &&
        element.month == date.month &&
        element.day == date.day);
  }

  double getTopOffset(DateTime date, double cellHeight) {
    int index = getCellIndex(date);
    return (index ~/ 7) * cellHeight;
  }

  double getLeftOffset(DateTime date, double cellWidth) {
    int index = getCellIndex(date);
    return (index % 7) * cellWidth;
  }

  double getWidgetWidth(
      DateTime startDate, DateTime endDate, double cellWidth) {
    int startIndex = getCellIndex(startDate);
    int endIndex = getCellIndex(endDate);
    return ((endIndex % 7) - (startIndex % 7) + 1) * cellWidth;
  }
}
