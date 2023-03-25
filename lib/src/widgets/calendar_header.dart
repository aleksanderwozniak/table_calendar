// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../customization/header_style.dart';
import '../shared/utils.dart' show CalendarFormat, DayBuilder;
import 'custom_icon_button.dart';

class CalendarHeader extends StatelessWidget {
  final dynamic locale;
  final DateTime focusedMonth;
  final CalendarFormat calendarFormat;
  final HeaderStyle headerStyle;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final VoidCallback onHeaderTap;
  final VoidCallback onHeaderLongPress;
  final ValueChanged<CalendarFormat> onFormatButtonTap;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final DayBuilder? headerTitleBuilder;

  const CalendarHeader({
    Key? key,
    this.locale,
    required this.focusedMonth,
    required this.calendarFormat,
    required this.headerStyle,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.onHeaderTap,
    required this.onHeaderLongPress,
    required this.onFormatButtonTap,
    required this.availableCalendarFormats,
    this.headerTitleBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yearText =
        headerStyle.titleTextFormatter?.call(focusedMonth, locale) ??
            DateFormat.y(locale).format(focusedMonth);
    final monthText =
        headerStyle.titleTextFormatter?.call(focusedMonth, locale) ??
            DateFormat.MMMM(locale).format(focusedMonth);

    return Container(
      decoration: headerStyle.decoration,
      margin: headerStyle.headerMargin,
      padding: headerStyle.headerPadding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (headerStyle.leftChevronVisible)
            CustomIconButton(
              icon: Image(
                  width: 32,
                  image: AssetImage('assets/images/icons8-go-back-64.png',
                      package: 'table_calendar')),
              onTap: onLeftChevronTap,
              margin: headerStyle.leftChevronMargin,
              padding: headerStyle.leftChevronPadding,
            ),
          Expanded(
            child: headerTitleBuilder?.call(context, focusedMonth) ??
                GestureDetector(
                  onTap: onHeaderTap,
                  onLongPress: onHeaderLongPress,
                  child: Column(
                    children: [
                      Text(
                        yearText,
                        style: headerStyle.titleYearTextStyle,
                        textAlign: headerStyle.titleCentered
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                      Text(
                        monthText,
                        style: headerStyle.titleMonthTextStyle,
                        textAlign: headerStyle.titleCentered
                            ? TextAlign.center
                            : TextAlign.start,
                      )
                    ],
                  ),
                ),
          ),
          if (headerStyle.rightChevronVisible)
            CustomIconButton(
              icon: Image(
                  width: 32,
                  image: AssetImage('assets/images/icons8-circled-right-64.png',
                      package: 'table_calendar')),
              onTap: onRightChevronTap,
              margin: headerStyle.rightChevronMargin,
              padding: headerStyle.rightChevronPadding,
            ),
        ],
      ),
    );
  }
}
