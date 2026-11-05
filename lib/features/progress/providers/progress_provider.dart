import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/progress_repository.dart';
import '../application/progress_service.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return const LocalProgressRepository();
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

final progressProvider =
    NotifierProvider<ProgressController, UserProgressModel>(ProgressController.new);

class ProgressController extends Notifier<UserProgressModel> {
  Future<void>? _restoreTask;
  Future<void> _mutationQueue = Future<void>.value();

  @override
  UserProgressModel build() {
    _restoreTask ??= _restore();
    return UserProgressModel.empty();
  }

  Future<void> _restore() async {
    final saved = await ref.read(progressRepositoryProvider).load();
    state = ref.read(progressServiceProvider).refreshEnergy(saved);
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _mutationQueue = _mutationQueue.then((_) async {
      try {
        await _restoreTask;
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> completeLesson(LessonModel lesson) => _serialize(() async {
        final updated = ref.read(progressServiceProvider).completeLesson(
              state,
              lesson.id,
              lesson.xpReward,
            );
        await _commit(updated);
      });

  /// Refreshes elapsed energy recovery, persists it, and charges exactly once
  /// when a new quiz screen has loaded its questions and is ready to start.
  Future<bool> tryStartQuiz({int energyCost = 1}) => _serialize(() async {
        final result = ref.read(progressServiceProvider).consumeQuizEnergy(
              state,
              cost: energyCost,
            );
        await _commit(result.progress);
        return result.started;
      });

  Future<void> refreshEnergy() => _serialize(() async {
        final updated = ref.read(progressServiceProvider).refreshEnergy(state);
        await _commit(updated);
      });

  Future<void> _commit(UserProgressModel updated) async {
    if (updated.encode() == state.encode()) return;
    state = updated;
    await ref.read(progressRepositoryProvider).save(updated);
  }
}
