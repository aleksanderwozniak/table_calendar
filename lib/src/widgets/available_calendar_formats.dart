import 'package:flutter/material.dart';
import 'package:table_calendar/src/customization/header_style.dart';
import 'package:table_calendar/src/shared/utils.dart';
import 'package:table_calendar/src/widgets/format_button.dart';

class AvailableCalendarFormats extends StatelessWidget {
  final HeaderStyle headerStyle;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final ValueChanged<CalendarFormat> onFormatButtonTap;
  final CalendarFormat calendarFormat;

  const AvailableCalendarFormats({
    Key? key,
    required this.calendarFormat,
    required this.headerStyle,
    required this.availableCalendarFormats,
    required this.onFormatButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (headerStyle.formatButtonVisible && availableCalendarFormats.length > 1)
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: FormatButton(
          onTap: onFormatButtonTap,
          availableCalendarFormats: availableCalendarFormats,
          calendarFormat: calendarFormat,
          decoration: headerStyle.formatButtonDecoration,
          padding: headerStyle.formatButtonPadding,
          textStyle: headerStyle.formatButtonTextStyle,
          showsNextFormat: headerStyle.formatButtonShowsNext,
        ),
      );

    return Container();
  }
}
