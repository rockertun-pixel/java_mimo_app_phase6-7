import '../../../data/models/user_progress_model.dart';

class ProgressService {
  const ProgressService({this.energyRecoveryInterval = const Duration(minutes: 30)});

  final Duration energyRecoveryInterval;

  UserProgressModel completeLesson(
    UserProgressModel progress,
    String lessonId,
    int xpReward, {
    DateTime? now,
  }) =>
      progress.completeLesson(lessonId, xpReward, completedAt: now);

  UserProgressModel refreshEnergy(UserProgressModel progress, {DateTime? now}) =>
      progress.refreshEnergy(
        now: now ?? DateTime.now(),
        recoveryInterval: energyRecoveryInterval,
      );

  EnergyConsumption consumeQuizEnergy(
    UserProgressModel progress, {
    required int cost,
    DateTime? now,
  }) {
    final refreshed = refreshEnergy(progress, now: now);
    if (cost <= 0 || refreshed.energy < cost) {
      return EnergyConsumption(progress: refreshed, started: false);
    }
    return EnergyConsumption(
      progress: refreshed.consumeEnergy(amount: cost, now: now ?? DateTime.now()),
      started: true,
    );
  }
}

class EnergyConsumption {
  const EnergyConsumption({required this.progress, required this.started});

  final UserProgressModel progress;
  final bool started;
}
