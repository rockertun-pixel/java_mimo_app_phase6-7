import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../data/models/lesson_model.dart';
import '../../courses/providers/course_providers.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({
    required this.lesson,
    required this.correctAnswers,
    required this.totalQuestions,
    super.key,
  });

  final LessonModel lesson;
  final int correctAnswers;
  final int totalQuestions;

  bool get passed => correctAnswers / totalQuestions >= 0.7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentage = (correctAnswers / totalQuestions * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz ရလဒ်')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                passed ? Icons.celebration_rounded : Icons.refresh_rounded,
                size: 72,
                color: passed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                passed ? 'အောင်မြင်ပါသည်။' : 'ထပ်မံကြိုးစားပါ။',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                  '$correctAnswers / $totalQuestions မှန်ပါသည် ($percentage%)'),
              const SizedBox(height: 24),
              if (passed)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('ရရှိမည့် XP'),
                        const SizedBox(height: 8),
                        Text('+${lesson.xpReward} XP',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'အောင်မြင်ရန် အနည်းဆုံး ၇၀% ရရှိရမည်။ သင်ခန်းစာကို ပြန်ဖတ်ပြီး Quiz ကို ပြန်ဖြေပါ။',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 28),
              if (passed)
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(progressProvider.notifier)
                        .completeLesson(lesson);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('သင်ခန်းစာပြီးမြောက်ပါပြီ။ XP ရရှိပါပြီ။'),
                      ),
                    );
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('သင်ခန်းစာပြီးမြောက်ကြောင်း သိမ်းမည်'),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizScreen(lesson: lesson),
                    ),
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Quiz ပြန်ဖြေမည်'),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const AppHomePage(),
                    ),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
