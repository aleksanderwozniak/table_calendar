// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/src/shared/utils.dart';
import 'package:table_calendar/src/widgets/calendar_page.dart';

Widget setupTestWidget(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

List<DateTime> visibleDays = getDaysInRange(
  DateTime.utc(2021, 6, 27),
  DateTime.utc(2021, 7, 31),
);

List<DateTime> getDaysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

void main() {
  testWidgets(
    'CalendarPage lays out all the visible days',
    (tester) async {
      await tester.pumpWidget(
        setupTestWidget(
          CalendarPage(
            calendarFormat: CalendarFormat.month,
            visibleDays: visibleDays,
            dayBuilder: (context, day) {
              return Text('${day.day}');
            },
            dowVisible: false,
          ),
        ),
      );

      final expectedCellCount = visibleDays.length;
      expect(find.byType(Text), findsNWidgets(expectedCellCount));
    },
  );

  testWidgets(
    'CalendarPage lays out 7 DOW labels',
    (tester) async {
      await tester.pumpWidget(
        setupTestWidget(
          CalendarPage(
            calendarFormat: CalendarFormat.month,
            visibleDays: visibleDays,
            dayBuilder: (context, day) {
              return Text('${day.day}');
            },
            dowVisible: true,
            dowBuilder: (context, day) {
              return Text('${day.weekday}');
            },
          ),
        ),
      );

      final expectedCellCount = visibleDays.length;
      final expectedDowLabels = 7;

      expect(
        find.byType(Text),
        findsNWidgets(expectedCellCount + expectedDowLabels),
      );
    },
  );

  testWidgets(
    'Throw AssertionError when CalendarPage is built with dowVisible set to true, but dowBuilder is absent',
    (tester) async {
      expect(() async {
        await tester.pumpWidget(
          setupTestWidget(
            CalendarPage(
              calendarFormat: CalendarFormat.month,
              visibleDays: visibleDays,
              dayBuilder: (context, day) {
                return Text('${day.day}');
              },
              dowVisible: true,
            ),
          ),
        );
      }, throwsAssertionError);
    },
  );
}
