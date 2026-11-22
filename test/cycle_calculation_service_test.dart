import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/models/period_record.dart';
import 'package:period_tracker/core/services/cycle_calculation_service.dart';

void main() {
  final service = CycleCalculationService.instance;

  group('CycleCalculationService Tests', () {
    test('Fallback to onboarding data when no observed cycles exist', () {
      final onboardingStart = DateTime(2026, 11, 1);
      final stats = service.calculateStats(
        records: [],
        onboardingLastPeriodStart: onboardingStart,
        onboardingCycleLength: 28,
        onboardingPeriodLength: 5,
        referenceDate: DateTime(2026, 11, 10),
      );

      expect(stats.averageCycleLength, equals(28));
      expect(stats.averagePeriodDuration, equals(5));
      expect(stats.observedCycleCount, equals(0));
      expect(stats.shortestCycleLength, isNull);
      expect(stats.longestCycleLength, isNull);
      expect(stats.nextExpectedPeriodStart, equals(DateTime(2026, 11, 29)));
      expect(stats.nextExpectedPeriodEnd, equals(DateTime(2026, 12, 3)));
      expect(stats.estimatedOvulationDate, equals(DateTime(2026, 11, 15)));
    });

    test('Calculates stats correctly with 2 consecutive period records', () {
      final r1 = PeriodRecord(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 5),
      );
      final r2 = PeriodRecord(
        startDate: DateTime(2026, 10, 29),
        endDate: DateTime(2026, 11, 2),
      );

      final stats = service.calculateStats(
        records: [r1, r2],
        onboardingCycleLength: 28,
        onboardingPeriodLength: 5,
        referenceDate: DateTime(2026, 11, 5),
      );

      expect(stats.observedCycleCount, equals(1));
      expect(stats.averageCycleLength, equals(28));
      expect(stats.shortestCycleLength, equals(28));
      expect(stats.longestCycleLength, equals(28));
      expect(stats.latestPeriodStart, equals(DateTime(2026, 10, 29)));
      expect(stats.nextExpectedPeriodStart, equals(DateTime(2026, 11, 26)));
    });

    test('Rolling 6-cycle average with 7 observed cycles', () {
      // 8 records -> 7 observed cycles: 26, 30, 28, 26, 32, 28, 30
      final dates = [
        DateTime(2026, 1, 1),   // Cycle 1: 26 days -> Jan 27
        DateTime(2026, 1, 27),  // Cycle 2: 30 days -> Feb 26
        DateTime(2026, 2, 26),  // Cycle 3: 28 days -> Mar 26
        DateTime(2026, 3, 26),  // Cycle 4: 26 days -> Apr 21
        DateTime(2026, 4, 21),  // Cycle 5: 32 days -> May 23
        DateTime(2026, 5, 23),  // Cycle 6: 28 days -> Jun 20
        DateTime(2026, 6, 20),  // Cycle 7: 30 days -> Jul 20
        DateTime(2026, 7, 20),
      ];

      final records = dates
          .map((d) => PeriodRecord(startDate: d, endDate: d.add(const Duration(days: 4))))
          .toList();

      final stats = service.calculateStats(
        records: records,
        referenceDate: DateTime(2026, 7, 25),
      );

      expect(stats.observedCycleCount, equals(7));
      // Latest 6 cycles are: 30, 28, 26, 32, 28, 30 -> sum = 174 -> 174 / 6 = 29
      expect(stats.averageCycleLength, equals(29));
      expect(stats.shortestCycleLength, equals(26));
      expect(stats.longestCycleLength, equals(32));
    });

    test('Handles duplicate / near-duplicate start dates gracefully', () {
      final r1 = PeriodRecord(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 5),
      );
      // Duplicate entry accidentally logged next day
      final r1Duplicate = PeriodRecord(
        startDate: DateTime(2026, 10, 2),
        endDate: DateTime(2026, 10, 6),
      );
      final r2 = PeriodRecord(
        startDate: DateTime(2026, 10, 29),
        endDate: DateTime(2026, 11, 2),
      );

      final stats = service.calculateStats(
        records: [r1, r1Duplicate, r2],
        referenceDate: DateTime(2026, 11, 5),
      );

      expect(stats.observedCycleCount, equals(1));
      expect(stats.averageCycleLength, equals(28));
    });

    test('Handles irregular cycles correctly', () {
      final dates = [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 25), // 24 days
        DateTime(2026, 2, 26), // 32 days
        DateTime(2026, 3, 26), // 28 days
      ];

      final records = dates
          .map((d) => PeriodRecord(startDate: d, endDate: d.add(const Duration(days: 4))))
          .toList();

      final stats = service.calculateStats(
        records: records,
        referenceDate: DateTime(2026, 4, 1),
      );

      expect(stats.observedCycleCount, equals(3));
      // 24 + 32 + 28 = 84 -> 84 / 3 = 28
      expect(stats.averageCycleLength, equals(28));
      expect(stats.shortestCycleLength, equals(24));
      expect(stats.longestCycleLength, equals(32));
    });

    test('Detects delayed period without inventing fake records', () {
      final r1 = PeriodRecord(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 5),
      );

      // Current reference date is Nov 5, but expected start was Oct 29 (28-day cycle)
      final stats = service.calculateStats(
        records: [r1],
        onboardingCycleLength: 28,
        referenceDate: DateTime(2026, 11, 5),
      );

      expect(stats.isDelayed, isTrue);
      expect(stats.daysDelayed, equals(7)); // Oct 29 to Nov 5 is 7 days
      // Should not create unconfirmed period records
      expect(stats.observedCycleCount, equals(0));
    });

    test('Safely handles missing onboarding values', () {
      final stats = service.calculateStats(
        records: [],
        onboardingLastPeriodStart: null,
        onboardingCycleLength: null,
        onboardingPeriodLength: null,
      );

      expect(stats.averageCycleLength, isNull);
      expect(stats.averagePeriodDuration, isNull);
      expect(stats.observedCycleCount, equals(0));
      expect(stats.latestPeriodStart, isNull);
      expect(stats.nextExpectedPeriodStart, isNull);
    });
  });
}
