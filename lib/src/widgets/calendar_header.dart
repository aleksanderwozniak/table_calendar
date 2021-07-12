// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../customization/header_style.dart';
import '../shared/utils.dart' show CalendarFormat, DayBuilder;
import 'available_calendar_formats.dart';
import 'calendar_title.dart';
import 'custom_icon_button.dart';
import 'format_button.dart';
import 'left_chevron.dart';
import 'right_chevron.dart';

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
    return Container(
      decoration: headerStyle.decoration,
      margin: headerStyle.headerMargin,
      padding: headerStyle.headerPadding,
      child: headerStyle.navigationRight ? navigationRightView() : defaultView(),
    );
  }

  Widget defaultView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        LeftChevron(
          headerStyle: headerStyle,
          onLeftChevronTap: onLeftChevronTap,
        ),
        CalendarTitle(
          headerStyle: headerStyle,
          onHeaderLongPress: onHeaderLongPress,
          onHeaderTap: onHeaderTap,
          focusedMonth: focusedMonth,
        ),
        AvailableCalendarFormats(
          calendarFormat: calendarFormat,
          headerStyle: headerStyle,
          onFormatButtonTap: onFormatButtonTap,
          availableCalendarFormats: availableCalendarFormats,
        ),
        RightChevron(
          headerStyle: headerStyle,
          onRightChevronTap: onRightChevronTap,
        )
      ],
    );
  }

  Widget navigationRightView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        CalendarTitle(
          headerStyle: headerStyle,
          onHeaderLongPress: onHeaderLongPress,
          onHeaderTap: onHeaderTap,
          focusedMonth: focusedMonth,
        ),
        AvailableCalendarFormats(
          calendarFormat: calendarFormat,
          headerStyle: headerStyle,
          onFormatButtonTap: onFormatButtonTap,
          availableCalendarFormats: availableCalendarFormats,
        ),
        LeftChevron(
          headerStyle: headerStyle,
          onLeftChevronTap: onLeftChevronTap,
        ),
        RightChevron(
          headerStyle: headerStyle,
          onRightChevronTap: onRightChevronTap,
        )
      ],
    );
  }
}
