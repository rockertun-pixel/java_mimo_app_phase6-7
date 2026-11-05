import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_code_learning/data/models/user_progress_model.dart';
import 'package:myanmar_code_learning/features/progress/application/progress_service.dart';

void main() {
  const service = ProgressService();

  group('lesson completion and daily streak', () {
    test('awards XP once and increments streak at most once per local day', () {
      final dayOne = DateTime(2026, 11, 5, 9);
      final first = service.completeLesson(
        UserProgressModel.empty(now: dayOne),
        'java-001',
        10,
        now: dayOne,
      );
      final second = service.completeLesson(first, 'java-002', 15,
          now: DateTime(2026, 11, 5, 18));

      expect(first.totalXp, 10);
      expect(first.currentStreak, 1);
      expect(second.totalXp, 25);
      expect(second.currentStreak, 1);
      expect(second.hasCompletedLessonToday(DateTime(2026, 11, 5, 23)), isTrue);

      final duplicate = service.completeLesson(second, 'java-001', 10,
          now: DateTime(2026, 11, 5, 20));
      expect(identical(duplicate, second), isTrue);
      expect(duplicate.totalXp, 25);
    });

    test('increments after yesterday and restarts after a missed day', () {
      final yesterday = DateTime(2026, 11, 4, 11);
      final first = UserProgressModel.empty(now: yesterday)
          .completeLesson('java-001', 10, completedAt: yesterday);
      final consecutive = service.completeLesson(
        first,
        'java-002',
        10,
        now: DateTime(2026, 11, 5, 8),
      );
      final afterGap = service.completeLesson(
        consecutive,
        'java-003',
        10,
        now: DateTime(2026, 11, 7, 8),
      );

      expect(consecutive.currentStreak, 2);
      expect(consecutive.streakForDisplay(DateTime(2026, 11, 7, 7)), 0);
      expect(afterGap.currentStreak, 1);
    });
  });

  group('energy', () {
    test('recovers one per 30 minutes and never exceeds five', () {
      final start = DateTime(2026, 11, 5, 8);
      final low = UserProgressModel(
        completedLessonIds: const {},
        totalXp: 0,
        energy: 2,
        energyUpdatedAt: start,
      );

      expect(service.refreshEnergy(low, now: start.add(const Duration(minutes: 29))).energy, 2);
      final oneRecovered = service.refreshEnergy(
        low,
        now: start.add(const Duration(minutes: 30)),
      );
      expect(oneRecovered.energy, 3);
      expect(service.refreshEnergy(
        oneRecovered,
        now: start.add(const Duration(hours: 3)),
      ).energy, UserProgressModel.maxEnergy);
    });

    test('quiz start consumes exactly one energy and blocks at zero', () {
      final now = DateTime(2026, 11, 5, 8);
      final ready = UserProgressModel.empty(now: now);
      final first = service.consumeQuizEnergy(ready, cost: 1, now: now);
      expect(first.started, isTrue);
      expect(first.progress.energy, 4);

      final empty = UserProgressModel(
        completedLessonIds: const {},
        totalXp: 0,
        energy: 0,
        energyUpdatedAt: now,
      );
      final blocked = service.consumeQuizEnergy(empty, cost: 1, now: now);
      expect(blocked.started, isFalse);
      expect(blocked.progress.energy, 0);
    });
  });

  test('round trips current data and reads the original progress schema', () {
    final now = DateTime(2026, 11, 5, 10);
    final current = UserProgressModel.empty(now: now)
        .completeLesson('java-001', 10, completedAt: now);
    final decoded = UserProgressModel.decode(current.encode());
    expect(decoded.completedLessonIds, {'java-001'});
    expect(decoded.totalXp, 10);
    expect(decoded.energy, UserProgressModel.maxEnergy);
    expect(decoded.currentStreak, 1);

    final old = UserProgressModel.decode(
      '{"completedLessonIds":["java-001"],"totalXp":10}',
    );
    expect(old.completedLessonIds, {'java-001'});
    expect(old.totalXp, 10);
    expect(old.energy, UserProgressModel.maxEnergy);
    expect(old.currentStreak, 0);
  });
}
