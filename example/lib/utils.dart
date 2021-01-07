// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

/// Example Event class
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events
final kEvents = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(2020, 10, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    DateTime.now().toUtc(): [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

/// Example holidays
final kHolidays = {
  DateTime.utc(2021, 1, 1): [Event('New Year\'s Day')],
  DateTime.utc(2021, 2, 14): [Event('Valentine\'s Day')],
  DateTime.utc(2021, 3, 8): [Event('International Women\'s Day')],
  DateTime.utc(2021, 4, 1): [Event('April Fools\' Day')],
  DateTime.utc(2021, 5, 4): [Event('Star Wars Day')],
  DateTime.utc(2021, 10, 31): [Event('Halloween')],
  DateTime.utc(2021, 12, 31): [Event('New Year\s Eve')],
};

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
