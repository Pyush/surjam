import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/progress/practice_tracker.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../learn/models/exercise_model.dart';
import '../../learn/models/practice_lesson.dart';

/// Streaks, today's goal, the last seven days and lessons completed per instrument.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = PracticeTracker.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('📈 Your Practice')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: tracker,
          builder: (context, _) {
            final today = tracker.today;
            final goal = tracker.dailyGoalMinutes;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Current streak', value: _days(tracker.currentStreak), icon: '🔥')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Best streak', value: _days(tracker.bestStreak), icon: '🏆')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Lessons completed', value: '${tracker.totalLessons}', icon: '🎓')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Minutes played', value: '${tracker.totalMinutes}', icon: '⏱')),
                  ],
                ),
                const SizedBox(height: 16),
                _TodayCard(minutes: today.minutes, goal: goal),
                const SizedBox(height: 16),
                _Card(
                  title: 'Last 7 days',
                  subtitle: 'Minutes played each day',
                  child: _WeekChart(days: tracker.recentDays(), goal: goal),
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Lessons',
                  subtitle: 'Completed at least once',
                  child: Column(
                    children: [
                      _LessonProgressRow(
                        instrument: 'Piano',
                        done: ExerciseModel.preloadedExercises.where(_completed).length,
                        total: ExerciseModel.preloadedExercises.length,
                      ),
                      for (final instrument in [PracticeLesson.guitar, PracticeLesson.tabla])
                        _LessonProgressRow(
                          instrument: instrument,
                          done: PracticeLesson.forInstrument(instrument).where((l) => _completedId(l.id)).length,
                          total: PracticeLesson.forInstrument(instrument).length,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static bool _completed(ExerciseModel e) => _completedId(e.id);
  static bool _completedId(String id) => StorageService().getExerciseScore(id) > 0;
  static String _days(int n) => n == 1 ? '1 day' : '$n days';
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon  $label', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final int minutes;
  final int goal;

  const _TodayCard({required this.minutes, required this.goal});

  @override
  Widget build(BuildContext context) {
    final reached = minutes >= goal;
    return _Card(
      title: 'Today',
      subtitle: reached ? 'Daily goal reached. Nice work!' : '${goal - minutes} more minutes to reach your daily goal',
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (minutes / goal).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.white12,
                color: AppColors.learnGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$minutes / $goal min', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Card({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LessonProgressRow extends StatelessWidget {
  final String instrument;
  final int done;
  final int total;

  const _LessonProgressRow({required this.instrument, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(instrument, style: const TextStyle(color: AppColors.textPrimary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 8,
                backgroundColor: Colors.white12,
                color: AppColors.learnGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$done / $total', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Minutes per day as columns, with the daily goal as a hairline. Today's value is labelled;
/// tap any day to see its value.
class _WeekChart extends StatefulWidget {
  final List<PracticeDay> days;
  final int goal;

  const _WeekChart({required this.days, required this.goal});

  @override
  State<_WeekChart> createState() => _WeekChartState();
}

class _WeekChartState extends State<_WeekChart> {
  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final days = widget.days;
    final summary = [
      for (final d in days) '${_weekdays[d.date.weekday - 1]} ${d.minutes} minutes',
    ].join(', ');

    return Semantics(
      label: 'Minutes played in the last 7 days: $summary. Daily goal ${widget.goal} minutes.',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / days.length;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final index = (details.localPosition.dx / slot).floor().clamp(0, days.length - 1);
                setState(() => _selected = _selected == index ? null : index);
              },
              child: SizedBox(
                // A CustomPaint without a child takes its size from here; without an explicit
                // width it would collapse to zero inside the card's left-aligned column.
                width: constraints.maxWidth,
                height: 170,
                child: CustomPaint(
                  painter: _WeekChartPainter(
                    days: days,
                    goal: widget.goal,
                    labelIndex: _selected ?? days.length - 1,
                    weekdays: _weekdays,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeekChartPainter extends CustomPainter {
  final List<PracticeDay> days;
  final int goal;
  final int labelIndex;
  final List<String> weekdays;

  _WeekChartPainter({required this.days, required this.goal, required this.labelIndex, required this.weekdays});

  static const double _axisLabelHeight = 22;
  static const double _valueLabelHeight = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final plotTop = _valueLabelHeight;
    final baseline = size.height - _axisLabelHeight;
    final plotHeight = baseline - plotTop;
    final maxMinutes = max(goal * 1.25, days.fold<int>(0, (m, d) => max(m, d.minutes)).toDouble());
    double yFor(num minutes) => baseline - plotHeight * (minutes / maxMinutes);
    final slot = size.width / days.length;
    final barWidth = min(24.0, slot * 0.5);

    // Baseline and goal: recessive hairlines.
    final hairline = Paint()
      ..color = AppColors.darkCardBorder
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseline), Offset(size.width, baseline), hairline);
    final goalY = yFor(goal);
    canvas.drawLine(Offset(0, goalY), Offset(size.width, goalY), Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.6)
      ..strokeWidth = 1);
    _text(canvas, 'Goal ${goal}m', Offset(size.width, goalY - 2), AppColors.textSecondary, 10, alignRight: true, above: true);

    final barPaint = Paint()..color = AppColors.learnGreen;
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final centerX = slot * i + slot / 2;
      if (day.minutes > 0) {
        final top = yFor(day.minutes);
        // Rounded data-end, square at the baseline.
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(centerX - barWidth / 2, top, centerX + barWidth / 2, baseline),
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
          barPaint,
        );
      }
      if (i == labelIndex) {
        _text(canvas, '${day.minutes}m', Offset(centerX, yFor(day.minutes) - 4), AppColors.textPrimary, 11, above: true, bold: true);
      }
      final isToday = i == days.length - 1;
      _text(
        canvas,
        isToday ? 'Today' : weekdays[day.date.weekday - 1],
        Offset(centerX, baseline + 6),
        isToday ? AppColors.textPrimary : AppColors.textSecondary,
        11,
        bold: isToday,
      );
    }
  }

  void _text(Canvas canvas, String text, Offset anchor, Color color, double fontSize,
      {bool alignRight = false, bool above = false, bool bold = false}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.w600 : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? anchor.dx - painter.width : anchor.dx - painter.width / 2;
    final dy = above ? anchor.dy - painter.height : anchor.dy;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _WeekChartPainter old) =>
      old.days != days || old.goal != goal || old.labelIndex != labelIndex;
}
