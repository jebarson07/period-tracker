import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/period_record.dart';

/// Container for computed cycle statistics and predictions.
@immutable
class CycleStats {
  const CycleStats({
    required this.averageCycleLength,
    required this.shortestCycleLength,
    required this.longestCycleLength,
    required this.observedCycleCount,
    required this.averagePeriodDuration,
    required this.latestPeriodStart,
    required this.nextExpectedPeriodStart,
    required this.nextExpectedPeriodEnd,
    required this.estimatedOvulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.isDelayed,
    required this.daysDelayed,
  });

  /// Rolling average cycle length in days (or onboarding fallback if <1 observed cycle).
  final int? averageCycleLength;

  /// Shortest observed cycle in days (null if no completed observed cycles).
  final int? shortestCycleLength;

  /// Longest observed cycle in days (null if no completed observed cycles).
  final int? longestCycleLength;

  /// Total number of completed observed cycles between actual period start dates.
  final int observedCycleCount;

  /// Average period duration in days (or onboarding fallback).
  final int? averagePeriodDuration;

  /// Latest confirmed period start date.
  final DateTime? latestPeriodStart;

  /// Next predicted period start date.
  final DateTime? nextExpectedPeriodStart;

  /// Next predicted period end date.
  final DateTime? nextExpectedPeriodEnd;

  /// Estimated ovulation date (14 days before next expected period).
  final DateTime? estimatedOvulationDate;

  /// Start of estimated fertile window (5 days before ovulation).
  final DateTime? fertileWindowStart;

  /// End of estimated fertile window (ovulation day).
  final DateTime? fertileWindowEnd;

  /// Whether current date is past expected period start without a recorded period.
  final bool isDelayed;

  /// Number of days delayed past expected period start date (0 if not delayed).
  final int daysDelayed;
}

/// Core service for menstrual cycle calculations, rolling averages,
/// and predictions based strictly on actual observed period records.
class CycleCalculationService {
  CycleCalculationService._();
  static final CycleCalculationService instance = CycleCalculationService._();

  /// Calculates cycle statistics and future predictions from actual period records
  /// and onboarding fallbacks.
  ///
  /// - Uses a rolling average of up to 6 latest observed cycles.
  /// - Deduplicates start dates within 2 days of each other.
  /// - Never uses predictions in historical calculations.
  /// - Safely handles missing/incomplete onboarding data.
  CycleStats calculateStats({
    required List<PeriodRecord> records,
    DateTime? onboardingLastPeriodStart,
    int? onboardingCycleLength,
    int? onboardingPeriodLength,
    DateTime? referenceDate,
  }) {
    final today = _dateOnly(referenceDate ?? DateTime.now());

    // Filter only confirmed records
    final confirmedRecords =
        records.where((r) => r.isConfirmed).toList();

    // Collect all valid start dates including onboarding start date if not present
    final List<DateTime> startDates = [];

    if (onboardingLastPeriodStart != null) {
      startDates.add(_dateOnly(onboardingLastPeriodStart));
    }

    for (final r in confirmedRecords) {
      startDates.add(_dateOnly(r.startDate));
    }

    // Deduplicate dates (sort and ignore dates within 2 days of previous)
    final sortedUniqueStarts = _deduplicateStartDates(startDates);

    // Latest period start
    final latestStart = sortedUniqueStarts.isNotEmpty
        ? sortedUniqueStarts.last
        : (onboardingLastPeriodStart != null
            ? _dateOnly(onboardingLastPeriodStart)
            : null);

    // Calculate observed cycle lengths between consecutive actual start dates
    final List<int> observedCycleLengths = [];
    for (int i = 0; i < sortedUniqueStarts.length - 1; i++) {
      final diff = _daysBetween(sortedUniqueStarts[i], sortedUniqueStarts[i + 1]);
      // Valid cycle length range (15 to 90 days)
      if (diff >= 15 && diff <= 90) {
        observedCycleLengths.add(diff);
      }
    }

    final observedCount = observedCycleLengths.length;

    int? avgCycleLength;
    int? minCycleLength;
    int? maxCycleLength;

    if (observedCount > 0) {
      // Rolling average of up to latest 6 observed cycles
      final latest6 = observedCycleLengths.length > 6
          ? observedCycleLengths.sublist(observedCycleLengths.length - 6)
          : observedCycleLengths;

      final sum = latest6.reduce((a, b) => a + b);
      avgCycleLength = (sum / latest6.length).round();
      minCycleLength = observedCycleLengths.reduce(math.min);
      maxCycleLength = observedCycleLengths.reduce(math.max);
    } else {
      avgCycleLength = onboardingCycleLength;
    }

    // Calculate period duration average
    int? avgPeriodDuration;
    if (confirmedRecords.isNotEmpty) {
      final validDurations = confirmedRecords
          .map((r) => r.durationInDays)
          .where((d) => d > 0 && d <= 20)
          .toList();

      if (validDurations.isNotEmpty) {
        final sum = validDurations.reduce((a, b) => a + b);
        avgPeriodDuration = (sum / validDurations.length).round();
      } else {
        avgPeriodDuration = onboardingPeriodLength;
      }
    } else {
      avgPeriodDuration = onboardingPeriodLength;
    }

    // Predictions (only if we have a latest start and average cycle length)
    DateTime? nextStart;
    DateTime? nextEnd;
    DateTime? ovulationDate;
    DateTime? fertileStart;
    DateTime? fertileEnd;
    bool isDelayed = false;
    int daysDelayed = 0;

    if (latestStart != null && avgCycleLength != null) {
      // Next period start date
      final diffFromLatest = _daysBetween(latestStart, today);

      if (diffFromLatest < avgCycleLength) {
        nextStart = _addDays(latestStart, avgCycleLength);
      } else {
        // Current cycle is ongoing or past expected start date
        final cyclesPassed = diffFromLatest ~/ avgCycleLength;
        final expectedForCurrent = _addDays(latestStart, cyclesPassed * avgCycleLength);

        if (today.isAfter(expectedForCurrent)) {
          isDelayed = true;
          daysDelayed = _daysBetween(expectedForCurrent, today);
          nextStart = expectedForCurrent;
        } else {
          nextStart = _addDays(latestStart, (cyclesPassed + 1) * avgCycleLength);
        }
      }

      if (avgPeriodDuration != null) {
        nextEnd = _addDays(nextStart, avgPeriodDuration - 1);
      }

      ovulationDate = _addDays(nextStart, -14);
      fertileStart = _addDays(ovulationDate, -5);
      fertileEnd = ovulationDate;
    }

    return CycleStats(
      averageCycleLength: avgCycleLength,
      shortestCycleLength: minCycleLength,
      longestCycleLength: maxCycleLength,
      observedCycleCount: observedCount,
      averagePeriodDuration: avgPeriodDuration,
      latestPeriodStart: latestStart,
      nextExpectedPeriodStart: nextStart,
      nextExpectedPeriodEnd: nextEnd,
      estimatedOvulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      isDelayed: isDelayed,
      daysDelayed: daysDelayed,
    );
  }

  /// Deduplicates list of start dates, keeping only unique dates at least 3 days apart.
  List<DateTime> _deduplicateStartDates(List<DateTime> dates) {
    if (dates.isEmpty) return [];

    final sorted = dates.map(_dateOnly).toList()..sort();
    final List<DateTime> result = [sorted.first];

    for (int i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final lastAdded = result.last;
      if (_daysBetween(lastAdded, current) >= 3) {
        result.add(current);
      }
    }
    return result;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _addDays(DateTime d, int n) =>
      DateTime(d.year, d.month, d.day + n);

  static int _daysBetween(DateTime a, DateTime b) {
    final ua = DateTime.utc(a.year, a.month, a.day);
    final ub = DateTime.utc(b.year, b.month, b.day);
    return ub.difference(ua).inDays;
  }
}
