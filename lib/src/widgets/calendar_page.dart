// Copyright 2019 Aleksander Woźniak & Sneh Mehta
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, DateTimeRange range)?
      overlayBuilder;
  final Widget Function(BuildContext context)? overlayDefaultBuilder;
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
  final int rowSpanLimit;
  final String? toolTip;
  final TextStyle? toolTipStyle;
  final DateTime? toolTipDate;
  final Color? toolTipBackgroundColor;

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
    this.overlayDefaultBuilder,
    this.overlayRanges,
    this.rowSpanLimit = -1,
    this.toolTip,
    this.toolTipStyle,
    this.toolTipDate,
    this.toolTipBackgroundColor,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        assert(!weekNumberVisible || weekNumberBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    double? widgetWidth;
    bool? isInFirstLine;

    if (toolTip != null && toolTipDate != null) {
      final painter = TextPainter(
        text: TextSpan(
            text: toolTip,
            style: toolTipStyle ?? TextStyle(color: Colors.white)),
        textDirection: TextDirection.ltr,
      );
      painter.layout();

      final double textWidth = painter.width;
      widgetWidth = textWidth + 2 * 10;
      final index = visibleDays.indexOf(toolTipDate!);
      isInFirstLine = false;
      if (index != -1 && index < 7) {
        isInFirstLine = true;
      }
    }

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
                    ),
                  if (toolTip != null && toolTipDate != null)
                    Positioned(
                      left: getLeftOffset(
                              toolTipDate!, constraints.maxWidth / 7) +
                          0.5 * constraints.maxWidth / 7 -
                          0.5 * widgetWidth!,
                      top: getTopOffset(
                              toolTipDate!, constraints.maxHeight / 5) -
                          50 +
                          (isInFirstLine! ? constraints.maxHeight / 5 : 0),
                      child: CustomPaint(
                        painter: CustomStyleArrow(
                            color: toolTipBackgroundColor ?? Colors.black,
                            preferBelow: !isInFirstLine),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Text(toolTip!,
                              style: toolTipStyle ??
                                  TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  List<CustomRange> splitOverlays(List<DateTimeRange> overlays) {
    final List<CustomRange> ranges = [];
    overlays.map((overlay) {
      final range = splitRangeIntoWeeks(overlay);
      ranges.addAll(range);
    }).toList();

    return ranges;
  }

  List<CustomRange> splitRangeIntoWeeks(DateTimeRange dateRange) {
    DateTime startDate = dateRange.start;
    DateTime endDate = dateRange.end;

    List<CustomRange> range = [];

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
        final newRange = DateTimeRange(
          start: DateTime(
              eventStartDate.year, eventStartDate.month, eventStartDate.day),
          end:
              DateTime(eventEndDate.year, eventEndDate.month, eventEndDate.day),
        );
        range.add(CustomRange(originalRange: dateRange, newRange: newRange));
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

    dividedDateRanges
        .sort((a, b) => a.newRange.start.compareTo(b.newRange.start));

    List<List<CustomRange>> overlapGroups = [];
    for (int i = 0; i < dividedDateRanges.length; i++) {
      final range = dividedDateRanges[i];
      if (i == 0) {
        overlapGroups.add([range]);
      } else {
        if (dividedDateRanges[i]
            .newRange
            .start
            .isBefore(dividedDateRanges[i - 1].newRange.end)) {
          if (rowSpanLimit == -1) {
            overlapGroups.last.add(range);
          } else {
            if (overlapGroups.last.length < rowSpanLimit) {
              overlapGroups.last.add(range);
            } else if (overlapGroups.last.length == rowSpanLimit &&
                overlayDefaultBuilder != null) {
              overlapGroups.last.add(
                CustomRange(
                  originalRange: range.originalRange,
                  newRange: DateTimeRange(
                    start: range.newRange.start,
                    end: range.newRange.start.add(
                      Duration(days: 3),
                    ),
                  ),
                  isDefault: true,
                ),
              );
            }
          }
        } else {
          overlapGroups.add([range]);
        }
      }
    }

    final children = <Widget>[];

    for (int i = 0; i < overlapGroups.length; i++) {
      final group = overlapGroups[i];
      for (int j = 0; j < group.length; j++) {
        final range = group[j];
        if (range.isDefault) {
          children.add(LayoutId(
            id: (i + j).toString() + range.newRange.toString(),
            child: overlayDefaultBuilder?.call(context) ??
                Container(child: Text('Override default overlay')),
          ));
        } else {
          children.add(LayoutId(
            id: (i + j).toString() + range.newRange.toString(),
            child: overlayBuilder!.call(context, range.originalRange),
          ));
        }
      }
    }

    return CustomMultiChildLayout(
      delegate: CalendarLayoutDelegate(
        constraints: constraints,
        rowHeight: rowHeight ?? 52,
        visibleDays: visibleDays,
        overlapGroups: overlapGroups,
      ),
      children: children,
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
  final BoxConstraints constraints;
  final double rowHeight;
  final List<DateTime> visibleDays;
  final List<List<CustomRange>> overlapGroups;

  CalendarLayoutDelegate({
    required this.constraints,
    required this.rowHeight,
    required this.visibleDays,
    required this.overlapGroups,
  });

  @override
  void performLayout(Size size) {
    for (int i = 0; i < overlapGroups.length; i++) {
      final group = overlapGroups[i];
      double sharedHeight = rowHeight / group.length;

      double sharedYOffset = 0;
      for (var j = 0; j < group.length; j++) {
        final range = group[j];
        DateTime startDate = range.newRange.start;
        DateTime endDate = range.newRange.end;

        double xOffset = getLeftOffset(startDate, constraints.maxWidth / 7);
        double yOffset =
            getTopOffset(startDate, size.height / 5) + sharedYOffset;

        double widgetWidth =
            getWidgetWidth(startDate, endDate, constraints.maxWidth / 7);

        layoutChild((i + j).toString() + range.newRange.toString(),
            BoxConstraints.tightFor(width: widgetWidth, height: sharedHeight));

        positionChild((i + j).toString() + range.newRange.toString(),
            Offset(xOffset, yOffset));
        sharedYOffset += sharedHeight;
      }
    }
  }

  @override
  bool shouldRelayout(CalendarLayoutDelegate oldDelegate) {
    return overlapGroups != oldDelegate.overlapGroups;
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

class CustomRange {
  final DateTimeRange originalRange;
  final DateTimeRange newRange;
  final bool isDefault;
  final int? collapsedChildrenLength;

  CustomRange({
    required this.originalRange,
    required this.newRange,
    this.isDefault = false,
    this.collapsedChildrenLength,
  });
}

class CustomStyleArrow extends CustomPainter {
  final Color? color;
  final BorderRadius? borderRadius;
  final bool preferBelow;

  CustomStyleArrow({this.color, this.borderRadius, this.preferBelow = true});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    final double triangleH = 10;
    final double triangleW = 20.0;
    final double width = size.width;
    final double height = size.height;

    final Path trianglePath = Path();
    if (preferBelow) {
      trianglePath
        ..moveTo(width / 2 - triangleW / 2, height)
        ..lineTo(width / 2, height + triangleH)
        ..lineTo(width / 2 + triangleW / 2, height);
    } else {
      trianglePath
        ..moveTo(width / 2 - triangleW / 2, 0)
        ..lineTo(width / 2, 0 - triangleH)
        ..lineTo(width / 2 + triangleW / 2, 0);
    }
    trianglePath.close();

    canvas.drawPath(trianglePath, paint);
    final BorderRadius br = borderRadius ?? BorderRadius.circular(8);
    final Rect rect = (preferBelow)
        ? Rect.fromLTRB(0, 0, width, height)
        : Rect.fromLTRB(0, 0, width, height);
    final RRect outer = br.toRRect(rect);
    canvas.drawRRect(outer, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
