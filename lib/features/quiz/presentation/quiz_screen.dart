import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/lesson_model.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../courses/providers/course_providers.dart';
import '../providers/quiz_providers.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({required this.lesson, super.key});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(quizQuestionsProvider(lesson.id));

    return Scaffold(
      appBar: AppBar(title: Text('${lesson.titleMyanmar} Quiz')),
      body: questions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Quiz data ဖတ်မရပါ။\n$error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('ဤသင်ခန်းစာအတွက် Quiz မရှိသေးပါ။'));
          }
          return _QuizSessionGate(lesson: lesson, questions: items);
        },
      ),
    );
  }
}

class _QuizSessionGate extends ConsumerStatefulWidget {
  const _QuizSessionGate({required this.lesson, required this.questions});

  final LessonModel lesson;
  final List<QuizQuestionModel> questions;

  @override
  ConsumerState<_QuizSessionGate> createState() => _QuizSessionGateState();
}

class _QuizSessionGateState extends ConsumerState<_QuizSessionGate> {
  bool _starting = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_startQuiz()));
  }

  Future<void> _startQuiz() async {
    final started = await ref.read(progressProvider.notifier).tryStartQuiz(energyCost: 1);
    if (!mounted) return;
    setState(() {
      _started = started;
      _starting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_starting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_started) return const _InsufficientEnergyView();
    return _QuizRunner(lesson: widget.lesson, questions: widget.questions);
  }
}

class _InsufficientEnergyView extends ConsumerWidget {
  const _InsufficientEnergyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final nextEnergy = progress.nextEnergyAt(const Duration(minutes: 30));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.battery_alert_rounded, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('စွမ်းအင် မလုံလောက်ပါ။',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Quiz စတင်ရန် စွမ်းအင် ၁ ခု လိုအပ်ပါသည်။ လက်ရှိ ${progress.energy} ခုသာ ကျန်ပါသည်။',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(nextEnergy == null
                ? 'စွမ်းအင်အပြည့်ရှိပါသည်။'
                : 'မိနစ် ၃၀ တိုင်း ၁ ခု အလိုအလျောက်ပြန်ဖြည့်ပါမည်။'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('သင်ခန်းစာသို့ ပြန်မည်'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizRunner extends StatefulWidget {
  const _QuizRunner({required this.lesson, required this.questions});

  final LessonModel lesson;
  final List<QuizQuestionModel> questions;

  @override
  State<_QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<_QuizRunner> {
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedIndex;
  bool _submitted = false;

  QuizQuestionModel get _question => widget.questions[_questionIndex];

  void _submitOrContinue() {
    final selected = _selectedIndex;
    if (selected == null) return;

    if (!_submitted) {
      setState(() => _submitted = true);
      return;
    }

    final nextScore = _correctAnswers + (_question.isCorrect(selected) ? 1 : 0);
    if (_questionIndex == widget.questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => QuizResultScreen(
            lesson: widget.lesson,
            correctAnswers: nextScore,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      _correctAnswers = nextScore;
      _questionIndex++;
      _selectedIndex = null;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex;
    final isCorrect = selected != null && _question.isCorrect(selected);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'မေးခွန်း ${_questionIndex + 1} / ${widget.questions.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (_questionIndex + 1) / widget.questions.length,
        ),
        const SizedBox(height: 28),
        Text(_question.questionMyanmar,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (var index = 0; index < _question.options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AnswerOption(
              index: index,
              text: _question.options[index],
              selected: selected == index,
              correct: index == _question.correctOptionIndex,
              incorrectSelection: _submitted && selected == index && !isCorrect,
              submitted: _submitted,
              enabled: !_submitted,
              onTap: () => setState(() => _selectedIndex = index),
            ),
          ),
        if (_submitted)
          Card(
            color: isCorrect
                ? Colors.green.withAlpha(36)
                : Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${isCorrect ? 'အဖြေမှန်ပါသည်။' : 'အဖြေမမှန်သေးပါ။'}\n${_question.explanationMyanmar}',
              ),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: selected == null ? null : _submitOrContinue,
          child: Text(
            !_submitted
                ? 'အဖြေစစ်မည်'
                : _questionIndex == widget.questions.length - 1
                    ? 'ရလဒ်ကြည့်မည်'
                    : 'နောက်မေးခွန်း',
          ),
        ),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.correct,
    required this.incorrectSelection,
    required this.submitted,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool correct;
  final bool incorrectSelection;
  final bool submitted;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color borderColor;
    final Color? backgroundColor;
    if (submitted && correct) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withAlpha(36);
    } else if (incorrectSelection) {
      borderColor = colors.error;
      backgroundColor = colors.errorContainer;
    } else if (selected) {
      borderColor = colors.primary;
      backgroundColor = colors.primary.withAlpha(20);
    } else {
      borderColor = colors.outlineVariant;
      backgroundColor = null;
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: selected || (submitted && correct) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              child: Text(String.fromCharCode(65 + index)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
            if (submitted && correct)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (incorrectSelection)
              Icon(Icons.cancel, color: colors.error),
          ],
        ),
      ),
    );
  }
}
