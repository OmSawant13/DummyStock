import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/academy_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/search_bar_widget.dart';
import 'lesson_detail_screen.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academy = context.watch<AcademyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedCount = academy.lessons.where((l) => l.isCompleted).length;
    final totalCount = academy.lessons.length;
    final progressPercent = totalCount == 0 ? 0.0 : (completedCount / totalCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quant Academy & EdTech Hub', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Student Progress Card
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trading Mastery Curriculum',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '$completedCount / $totalCount Completed',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.bullGreen),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.darkTextMuted,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Structured Lessons'),
                  Tab(text: 'Trading Glossary'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLessonsTab(academy, context),
                  _buildGlossaryTab(academy, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsTab(AcademyProvider academy, BuildContext context) {
    return ListView.builder(
      itemCount: academy.lessons.length,
      itemBuilder: (context, index) {
        final lesson = academy.lessons[index];

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lesson.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                    ),
                  ),
                  if (lesson.isCompleted)
                    const Icon(Icons.check_circle_rounded, color: AppColors.bullGreen, size: 20)
                  else
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.darkTextMuted),
                        const SizedBox(width: 4),
                        Text(lesson.readTime, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(lesson.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                lesson.summary,
                style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted, height: 1.35),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlossaryTab(AcademyProvider academy, BuildContext context) {
    final filtered = academy.filteredGlossary;

    return Column(
      children: [
        SearchBarWidget(
          hintText: 'Search financial terms (e.g. Sharpe, Beta, P/E)...',
          controller: _searchController,
          onChanged: (val) => academy.setGlossarySearch(val),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No terms found', style: TextStyle(color: AppColors.darkTextMuted)))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.term, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(item.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.definition, style: const TextStyle(fontSize: 13, height: 1.35)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Example: ${item.example}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.darkTextMuted),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
