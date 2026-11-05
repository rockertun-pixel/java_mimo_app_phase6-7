import 'dart:convert';

class UserProgressModel {
  const UserProgressModel({
    required this.completedLessonIds,
    required this.totalXp,
    this.energy = maxEnergy,
    this.energyUpdatedAt,
    this.currentStreak = 0,
    this.lastCompletedDayKey,
  });

  static const int maxEnergy = 5;
  static const int xpPerLevel = 100;

  final Set<String> completedLessonIds;
  final int totalXp;
  final int energy;
  final DateTime? energyUpdatedAt;
  final int currentStreak;
  final String? lastCompletedDayKey;

  factory UserProgressModel.empty({DateTime? now}) => UserProgressModel(
        completedLessonIds: const <String>{},
        totalXp: 0,
        energy: maxEnergy,
        energyUpdatedAt: now,
      );

  int get level => (totalXp ~/ xpPerLevel) + 1;
  int get xpIntoLevel => totalXp % xpPerLevel;
  double get levelProgress => xpIntoLevel / xpPerLevel;

  int streakForDisplay([DateTime? now]) {
    if (lastCompletedDayKey == null) return 0;
    final today = dayKey(now ?? DateTime.now());
    if (lastCompletedDayKey == today || _isPreviousDay(lastCompletedDayKey!, today)) {
      return currentStreak;
    }
    return 0;
  }

  bool isCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  bool isUnlocked({required String lessonId, required List<String> orderedLessonIds}) {
    final index = orderedLessonIds.indexOf(lessonId);
    if (index <= 0) return index == 0;
    return completedLessonIds.contains(orderedLessonIds[index - 1]);
  }

  bool hasCompletedLessonToday([DateTime? now]) =>
      lastCompletedDayKey == dayKey(now ?? DateTime.now());

  static String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  UserProgressModel completeLesson(
    String lessonId,
    int xpReward, {
    DateTime? completedAt,
  }) {
    if (completedLessonIds.contains(lessonId)) return this;

    final now = completedAt ?? DateTime.now();
    final today = dayKey(now);
    var streak = currentStreak;
    if (lastCompletedDayKey != today) {
      streak = lastCompletedDayKey != null && _isPreviousDay(lastCompletedDayKey!, today)
          ? currentStreak + 1
          : 1;
    }

    return copyWith(
      completedLessonIds: {...completedLessonIds, lessonId},
      totalXp: totalXp + xpReward,
      currentStreak: streak,
      lastCompletedDayKey: today,
    );
  }

  UserProgressModel refreshEnergy({
    required DateTime now,
    required Duration recoveryInterval,
  }) {
    final boundedEnergy = energy.clamp(0, maxEnergy).toInt();
    if (boundedEnergy >= maxEnergy) {
      return energy == maxEnergy ? this : copyWith(energy: maxEnergy);
    }

    final baseline = energyUpdatedAt ?? now;
    final elapsed = now.difference(baseline);
    if (elapsed.isNegative || elapsed < recoveryInterval) {
      if (energy == boundedEnergy && energyUpdatedAt != null) return this;
      return copyWith(energy: boundedEnergy, energyUpdatedAt: baseline);
    }

    final recovered = elapsed.inMicroseconds ~/ recoveryInterval.inMicroseconds;
    final nextEnergy = (boundedEnergy + recovered).clamp(0, maxEnergy).toInt();
    final updatedAt = nextEnergy == maxEnergy
        ? now
        : baseline.add(recoveryInterval * recovered);
    return copyWith(energy: nextEnergy, energyUpdatedAt: updatedAt);
  }

  UserProgressModel consumeEnergy({required int amount, required DateTime now}) {
    if (amount <= 0 || energy < amount) return this;
    return copyWith(energy: energy - amount, energyUpdatedAt: now);
  }

  DateTime? nextEnergyAt(Duration recoveryInterval) {
    if (energy >= maxEnergy) return null;
    return (energyUpdatedAt ?? DateTime.now()).add(recoveryInterval);
  }

  UserProgressModel copyWith({
    Set<String>? completedLessonIds,
    int? totalXp,
    int? energy,
    DateTime? energyUpdatedAt,
    int? currentStreak,
    String? lastCompletedDayKey,
  }) =>
      UserProgressModel(
        completedLessonIds: completedLessonIds ?? this.completedLessonIds,
        totalXp: totalXp ?? this.totalXp,
        energy: energy ?? this.energy,
        energyUpdatedAt: energyUpdatedAt ?? this.energyUpdatedAt,
        currentStreak: currentStreak ?? this.currentStreak,
        lastCompletedDayKey: lastCompletedDayKey ?? this.lastCompletedDayKey,
      );

  Map<String, dynamic> toJson() => {
        'schemaVersion': 2,
        'completedLessonIds': completedLessonIds.toList()..sort(),
        'totalXp': totalXp,
        'energy': energy,
        'energyUpdatedAt': energyUpdatedAt?.toIso8601String(),
        'currentStreak': currentStreak,
        'lastCompletedDayKey': lastCompletedDayKey,
      };

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    final rawEnergyTime = json['energyUpdatedAt'];
    final parsedEnergyTime = rawEnergyTime is String
        ? DateTime.tryParse(rawEnergyTime)
        : rawEnergyTime is int
            ? DateTime.fromMillisecondsSinceEpoch(rawEnergyTime)
            : null;

    return UserProgressModel(
      completedLessonIds: Set<String>.from(
        (json['completedLessonIds'] as List<dynamic>? ?? <dynamic>[])
            .whereType<String>(),
      ),
      totalXp: (json['totalXp'] as num?)?.toInt().clamp(0, 1 << 30).toInt() ?? 0,
      // Older saved records have no energy field; grant a full initial energy bar.
      energy: ((json['energy'] as num?)?.toInt() ?? maxEnergy)
          .clamp(0, maxEnergy)
          .toInt(),
      energyUpdatedAt: parsedEnergyTime,
      currentStreak: ((json['currentStreak'] as num?)?.toInt() ?? 0)
          .clamp(0, 1 << 30)
          .toInt(),
      lastCompletedDayKey: json['lastCompletedDayKey'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());

  factory UserProgressModel.decode(String value) =>
      UserProgressModel.fromJson(jsonDecode(value) as Map<String, dynamic>);

  static bool _isPreviousDay(String previous, String today) {
    final previousDate = DateTime.tryParse(previous);
    final todayDate = DateTime.tryParse(today);
    if (previousDate == null || todayDate == null) return false;
    final previousUtc = DateTime.utc(previousDate.year, previousDate.month, previousDate.day);
    final todayUtc = DateTime.utc(todayDate.year, todayDate.month, todayDate.day);
    return todayUtc.difference(previousUtc).inDays == 1;
  }
}
