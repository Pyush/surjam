import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class EarTrainingScreen extends StatefulWidget {
  const EarTrainingScreen({super.key});

  @override
  State<EarTrainingScreen> createState() => _EarTrainingScreenState();
}

class _EarTrainingScreenState extends State<EarTrainingScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;

  void _playSound() {
    final q = QuizQuestion.questions[_currentQuestionIndex];
    if (q.soundBol != null) {
      AudioEngine().playTablaBol(q.soundBol!);
    } else {
      AudioEngine().playPianoNote(q.soundMidi);
    }
  }

  void _submitAnswer(int optionIndex) {
    if (_answered) return;

    final q = QuizQuestion.questions[_currentQuestionIndex];
    setState(() {
      _selectedAnswerIndex = optionIndex;
      _answered = true;
      if (optionIndex == q.correctOptionIndex) {
        _score += 100;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < QuizQuestion.questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _answered = false;
      });
      _playSound();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Ear Training Complete!'),
        content: Text('Your Final Score: $_score Points', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswerIndex = null;
                _answered = false;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = QuizQuestion.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎼 Ear Training Quiz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Banner
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} / ${QuizQuestion.questions.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Score: $_score',
                    style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Sound Play Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentPurple),
              ),
              child: Column(
                children: [
                  Text(
                    q.questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: const Icon(Icons.volume_up_rounded, size: 28),
                    label: const Text('PLAY SOUND 🔊', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: _playSound,
                  ),
                ],
              ),
            ),

            // Multiple Choice Options
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: q.options.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedAnswerIndex == index;
                  bool isCorrect = index == q.correctOptionIndex;

                  Color optionColor = AppColors.darkCard;
                  if (_answered) {
                    if (isCorrect) {
                      optionColor = AppColors.learnGreen;
                    } else if (isSelected) {
                      optionColor = AppColors.recordRed;
                    }
                  }

                  return Card(
                    color: optionColor,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        q.options[index],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: _answered
                          ? (isCorrect
                              ? const Icon(Icons.check_circle_rounded, color: Colors.white)
                              : (isSelected ? const Icon(Icons.cancel_rounded, color: Colors.white) : null))
                          : null,
                      onTap: () => _submitAnswer(index),
                    ),
                  );
                },
              ),
            ),

            if (_answered)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNeon,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _nextQuestion,
                    child: const Text('NEXT QUESTION ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),

            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
