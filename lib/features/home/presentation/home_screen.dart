import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../courses/presentation/courses_screen.dart';
import '../../courses/presentation/lesson_detail_screen.dart';
import '../../courses/providers/course_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _energyTimer;

  @override
  void initState() {
    super.initState();
    _energyTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(ref.read(progressProvider.notifier).refreshEnergy());
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = ref.watch(progressProvider);
    final lessonsAsync = ref.watch(lessonsProvider('java'));
    final lessons = lessonsAsync.valueOrNull ?? const <LessonModel>[];
    final completedCount = lessons.where((lesson) => progress.isCompleted(lesson.id)).length;
    final nextLesson = _firstIncompleteLesson(lessons, progress.completedLessonIds);
    final courseProgress = lessons.isEmpty ? 0.0 : completedCount / lessons.length;
    final nextEnergy = progress.nextEnergyAt(const Duration(minutes: 30));

    return ListView(
      children: [
        Text('မင်္ဂလာပါ', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('ယနေ့ Java ကို ဆက်လက်လေ့လာလိုက်ရအောင်။',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        Card(
          color: colors.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: colors.primary, size: 32),
                    const SizedBox(width: 10),
                    Text('သင်ယူမှု တိုးတက်မှု',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _Metric(
                        label: 'စုစုပေါင်း XP',
                        value: '${progress.totalXp}',
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Metric(
                        label: 'အဆင့်',
                        value: '${progress.level}',
                        icon: Icons.emoji_events_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Text('အဆင့် ${progress.level} တိုးတက်မှု')),
                    Text('${progress.xpIntoLevel} / 100 XP'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.levelProgress,
                    minHeight: 10,
                    backgroundColor: colors.surface.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.menu_book_rounded,
                title: 'ပြီးမြောက်သင်ခန်းစာ',
                value: '$completedCount${lessons.isEmpty ? '' : ' / ${lessons.length}'}',
                detail: 'Java course',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.local_fire_department_rounded,
                title: 'နေ့စဉ် streak',
                value: '${progress.streakForDisplay()} ရက်',
                detail: progress.hasCompletedLessonToday()
                    ? 'ယနေ့ lesson ပြီးပါပြီ'
                    : 'ယနေ့ lesson တစ်ခု ပြီးပါစေ',
              ),
            ),
          ],
        ),
        if (lessons.isNotEmpty) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.track_changes_rounded),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Java သင်တန်းတိုးတက်မှု')),
                      Text('${(courseProgress * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: courseProgress),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text('စွမ်းအင်', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text('${progress.energy} / ${UserProgressModel.maxEnergy}',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: List<Widget>.generate(
                    UserProgressModel.maxEnergy,
                    (index) => Icon(
                      index < progress.energy
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: index < progress.energy ? Colors.redAccent : colors.outline,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(nextEnergy == null
                    ? 'စွမ်းအင်အပြည့်ရှိပါသည်။ Quiz တစ်ခုစလျှင် ၁ ခု အသုံးပြုမည်။'
                    : 'မိနစ် ၃၀ တိုင်း ၁ ခု ပြန်ဖြည့်မည်။ နောက်တစ်ခု: ${_countdown(nextEnergy)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            if (nextLesson != null) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonDetailScreen(lesson: nextLesson),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CoursesScreen()),
              );
            }
          },
          icon: Icon(nextLesson == null ? Icons.school_outlined : Icons.play_arrow_rounded),
          label: Text(nextLesson == null
              ? 'သင်တန်းများကို ကြည့်မည်'
              : 'ဆက်လက်လေ့လာရန်: ${nextLesson.titleMyanmar}'),
        ),
        if (lessonsAsync.isLoading) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  String _countdown(DateTime target) {
    final remaining = target.difference(DateTime.now());
    if (remaining.isNegative) return 'ခဏအတွင်း';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return minutes == 0 ? '$seconds စက္ကန့်အတွင်း' : '$minutes မိနစ်အတွင်း';
  }
}

LessonModel? _firstIncompleteLesson(
  List<LessonModel> lessons,
  Set<String> completedLessonIds,
) {
  for (final lesson in lessons) {
    if (!completedLessonIds.contains(lesson.id)) return lesson;
  }
  return null;
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
        ],
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}
