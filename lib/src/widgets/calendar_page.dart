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
                  if (overlayBuilder != null && (overlayRanges?.isNotEmpty ?? false))
                    ...getEventWidgets(
                      context: context,
                      constraints: constraints,
                      dateRanges: overlayRanges!,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> getEventWidgets({
    required BuildContext context,
    required BoxConstraints constraints,
    required List<DateTimeRange> dateRanges,
  }) {
    List<Widget> widgets = [];

    for (DateTimeRange dateRange in dateRanges) {
      DateTime startDate = dateRange.start;
      DateTime endDate = dateRange.end;

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
          final overlay = Positioned(
            child:
                overlayBuilder?.call(context, dateRange) ?? SizedBox.shrink(),
            top: getTopOffset(eventStartDate, rowHeight!),
            left: getLeftOffset(eventStartDate, constraints.maxWidth / 7),
            width: getWidgetWidth(
                eventStartDate, eventEndDate, constraints.maxWidth / 7),
            height: rowHeight,
          );
          widgets.add(overlay);
        }
      }
    }

    return widgets;
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
