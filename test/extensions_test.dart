// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('Extension on Period class', () {
    test('Period - StartDate must be before EndDate', () {
      final dateA = DateTime(2020, 5, 10);
      final dateB = DateTime(2020, 5, 11);

      try {
        final _ = Period(dateB, dateA);
        expect(true, false); // Fail test if no error is thrown
      } catch (e) {
        expect(e, isInstanceOf<AssertionError>());
      }
    });

    test('Period - StartDate and EndDate can have the same day', () {
      final dateA = DateTime(2020, 5, 10);
      final dateB = DateTime(2020, 5, 10);
      final period = Period(dateA, dateB);

      expect(period.startDate.day, 10);
      expect(period.endDate.day, 10);
    });

    test('Merge Periods - Nothing to do', () {
      List<Period> periods = [
        Period(DateTime(2024, 2, 15), DateTime(2024, 2, 20)),
        Period(DateTime(2024, 1, 1), DateTime(2024, 1, 15)),
        Period(DateTime(2024, 1, 16), DateTime(2024, 2, 10)),
      ];

      final mergedPeriods = periods.mergeOverlappingPeriods();

      expect(mergedPeriods?.length, 3);
    });

    test('Merge Periods - Two overlapping', () {
      List<Period> periods = [
        Period(DateTime(2024, 1, 15), DateTime(2024, 1, 20)),
        Period(DateTime(2024, 1, 16), DateTime(2024, 2, 10)),
      ];

      final mergedPeriods = periods.mergeOverlappingPeriods();

      expect(mergedPeriods?.length, 1);
    });

    test('Merge Periods - One overlapping two', () {
      List<Period> periods = [
        Period(DateTime(2024, 1, 15), DateTime(2024, 1, 20)),
        Period(DateTime(2024, 1, 21), DateTime(2024, 2, 11)),
        Period(DateTime(2020, 1, 16), DateTime(2030, 2, 11)),
      ];

      final mergedPeriods = periods.mergeOverlappingPeriods();

      expect(mergedPeriods?.length, 1);
      expect(mergedPeriods?.first.startDate.day, 16);
      expect(mergedPeriods?.first.endDate.day, 11);
    });
  });
}
