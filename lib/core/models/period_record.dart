import 'package:flutter/foundation.dart';

/// Immutable model representing an actual recorded period.
@immutable
class PeriodRecord {
  const PeriodRecord({
    required this.startDate,
    required this.endDate,
    this.flowIntensity,
    this.isConfirmed = true,
  });

  /// The first day of the period.
  final DateTime startDate;

  /// The last day of the period.
  final DateTime endDate;

  /// Flow intensity (e.g., 'Light', 'Medium', 'Heavy').
  final String? flowIntensity;

  /// Whether this is a confirmed actual user record vs an estimated prediction.
  final bool isConfirmed;

  /// Duration in days (inclusive of start and end date).
  int get durationInDays {
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return e.difference(s).inDays + 1;
  }

  PeriodRecord copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? flowIntensity,
    bool? isConfirmed,
  }) {
    return PeriodRecord(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'flowIntensity': flowIntensity,
      'isConfirmed': isConfirmed,
    };
  }

  factory PeriodRecord.fromMap(Map<String, dynamic> map) {
    return PeriodRecord(
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      flowIntensity: map['flowIntensity'] as String?,
      isConfirmed: (map['isConfirmed'] as bool?) ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodRecord &&
          runtimeType == other.runtimeType &&
          startDate.year == other.startDate.year &&
          startDate.month == other.startDate.month &&
          startDate.day == other.startDate.day &&
          endDate.year == other.endDate.year &&
          endDate.month == other.endDate.month &&
          endDate.day == other.endDate.day &&
          flowIntensity == other.flowIntensity &&
          isConfirmed == other.isConfirmed;

  @override
  int get hashCode => Object.hash(
        startDate.year,
        startDate.month,
        startDate.day,
        endDate.year,
        endDate.month,
        endDate.day,
        flowIntensity,
        isConfirmed,
      );
}
