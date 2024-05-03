class Period {
  final DateTime startDate;
  final DateTime endDate;

  Period(this.startDate, this.endDate)
      : assert(
          startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate),
          'startDate must be before endDate',
        );
}

extension ListPeriodX on List<Period>? {
  List<Period>? mergeOverlappingPeriods() {
    if (this == null || this!.isEmpty) return null;

    // Sort the periods based on their start dates
    final periods = this!..sort((a, b) => a.startDate.compareTo(b.startDate));

    List<Period> mergedPeriods = [];

    // Merge overlapping periods
    Period currentPeriod = periods.first;
    for (int i = 1; i < periods.length; i++) {
      Period nextPeriod = periods[i];
      if (currentPeriod.endDate.isAfter(nextPeriod.startDate) ||
          currentPeriod.endDate == nextPeriod.startDate ||
          currentPeriod.endDate.isAtSameMomentAs(nextPeriod.startDate)) {
        // Overlapping periods, merge them
        currentPeriod = Period(
          currentPeriod.startDate,
          nextPeriod.endDate.isAfter(currentPeriod.endDate)
              ? nextPeriod.endDate
              : currentPeriod.endDate,
        );
      } else {
        // Non-overlapping periods, add currentPeriod to mergedPeriods
        mergedPeriods.add(currentPeriod);
        currentPeriod = nextPeriod;
      }
    }

    // Add the last period
    mergedPeriods.add(currentPeriod);

    return mergedPeriods;
  }
}
