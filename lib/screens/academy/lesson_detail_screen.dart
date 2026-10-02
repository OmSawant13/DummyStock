import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/academy_model.dart';
import '../../providers/academy_provider.dart';
import '../../widgets/common/custom_card.dart';

class LessonDetailScreen extends StatefulWidget {
  final AcademyLesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final Map<int, int> _userAnswers = {};
  bool _quizSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final academy = context.watch<AcademyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Text(
              widget.lesson.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.darkTextMuted),
                const SizedBox(width: 4),
                Text(widget.lesson.readTime, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                const SizedBox(width: 12),
                if (widget.lesson.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.bullGreenBg, borderRadius: BorderRadius.circular(4)),
                    child: const Text('COMPLETED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bullGreen)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Lesson Body Card
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.lesson.content.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Knowledge Check / Quiz Section
            const Text(
              'Interactive Knowledge Check',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...List.generate(widget.lesson.quiz.length, (qIdx) {
              final q = widget.lesson.quiz[qIdx];
              final selectedOpt = _userAnswers[qIdx];

              return CustomCard(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${qIdx + 1}: ${q.question}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(q.options.length, (optIdx) {
                      final isSelected = selectedOpt == optIdx;
                      final isCorrect = q.correctOptionIndex == optIdx;

                      Color? optBorderColor;
                      Color? optBgColor;

                      if (_quizSubmitted) {
                        if (isCorrect) {
                          optBorderColor = AppColors.bullGreen;
                          optBgColor = AppColors.bullGreenBg;
                        } else if (isSelected && !isCorrect) {
                          optBorderColor = AppColors.bearRed;
                          optBgColor = AppColors.bearRedBg;
                        }
                      } else if (isSelected) {
                        optBorderColor = AppColors.primaryLight;
                        optBgColor = AppColors.primary.withOpacity(0.12);
                      }

                      return GestureDetector(
                        onTap: _quizSubmitted
                            ? null
                            : () {
                                setState(() {
                                  _userAnswers[qIdx] = optIdx;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: optBgColor ?? (isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: optBorderColor ?? (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                              width: isSelected || (_quizSubmitted && isCorrect) ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                size: 16,
                                color: isSelected ? AppColors.primaryLight : AppColors.darkTextMuted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(q.options[optIdx], style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (_quizSubmitted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Explanation: ${q.explanation}',
                          style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, height: 1.3),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Submit Quiz & Complete Lesson Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bullGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() => _quizSubmitted = true);
                academy.markLessonCompleted(widget.lesson.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lesson completed! Quiz evaluated successfully.'),
                    backgroundColor: AppColors.bullGreenDark,
                  ),
                );
              },
              child: const Text('Submit Quiz & Complete Lesson', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
