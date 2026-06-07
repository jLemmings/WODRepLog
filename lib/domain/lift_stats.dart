import 'dart:math' as math;

class LiftEntry {
  const LiftEntry({
    required this.id,
    required this.liftName,
    required this.weight,
    required this.reps,
    required this.performedAt,
  });

  final String id;
  final String liftName;
  final double weight;
  final int reps;
  final DateTime performedAt;

  double get estimatedOneRepMax => weight * (1 + reps / 30);

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'liftName': liftName,
      'weight': weight,
      'reps': reps,
      'performedAt': performedAt.toIso8601String(),
    };
  }

  factory LiftEntry.fromJson(Map<String, Object?> json) {
    return LiftEntry(
      id: (json['id'] as String?) ?? '',
      liftName: (json['liftName'] as String?) ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      reps: (json['reps'] as num?)?.toInt() ?? 1,
      performedAt:
          DateTime.tryParse((json['performedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class LiftStats {
  const LiftStats({required this.entries});

  final List<LiftEntry> entries;

  List<String> get liftNames {
    final names = entries
        .map((entry) => entry.liftName.trim())
        .where((name) => name.isNotEmpty);
    return names.toSet().toList()..sort();
  }

  List<LiftEntry> entriesFor(String liftName) {
    final normalized = liftName.trim().toLowerCase();
    return entries
        .where((entry) => entry.liftName.trim().toLowerCase() == normalized)
        .toList()
      ..sort((a, b) => a.performedAt.compareTo(b.performedAt));
  }

  LiftEntry? bestEntryFor(String liftName) {
    final liftEntries = entriesFor(liftName);
    if (liftEntries.isEmpty) return null;
    return liftEntries.reduce(
      (best, entry) =>
          entry.estimatedOneRepMax > best.estimatedOneRepMax ? entry : best,
    );
  }

  bool isNewPr(LiftEntry entry) {
    final previousBest = entries
        .where(
          (candidate) =>
              candidate.liftName.trim().toLowerCase() ==
                  entry.liftName.trim().toLowerCase() &&
              candidate.performedAt.isBefore(entry.performedAt),
        )
        .fold<double>(0, (best, candidate) {
          return math.max(best, candidate.estimatedOneRepMax);
        });
    return entry.estimatedOneRepMax > previousBest;
  }
}
