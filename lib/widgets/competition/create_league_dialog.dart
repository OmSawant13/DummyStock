import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/competition_provider.dart';

class CreateLeagueDialog extends StatefulWidget {
  const CreateLeagueDialog({super.key});

  @override
  State<CreateLeagueDialog> createState() => _CreateLeagueDialogState();
}

class _CreateLeagueDialogState extends State<CreateLeagueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  final _descController = TextEditingController();
  final _capitalController = TextEditingController(text: '100000');
  final _durationController = TextEditingController(text: '14');
  final _prizeController = TextEditingController(text: '\$5,000 + Quant Certificates');

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _descController.dispose();
    _capitalController.dispose();
    _durationController.dispose();
    _prizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.emoji_events_outlined, color: AppColors.purple, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Host College Trading League',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Create a customized trading tournament',
                            style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: _titleController,
                  validator: (v) => v == null || v.isEmpty ? 'Please enter league name' : null,
                  decoration: const InputDecoration(
                    labelText: 'Competition Title',
                    hintText: 'e.g. Berkeley FinTech Trading Derby',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _organizerController,
                  validator: (v) => v == null || v.isEmpty ? 'Please enter organizer/college' : null,
                  decoration: const InputDecoration(
                    labelText: 'Host College / Organization',
                    hintText: 'e.g. Finance & Investment Club',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Please enter description' : null,
                  decoration: const InputDecoration(
                    labelText: 'Description & Focus',
                    hintText: 'e.g. 2-week paper trading competition with risk-adjusted ranking.',
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capitalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Initial Cash (\$)',
                          prefixText: '\$',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Days)',
                          suffixText: 'Days',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _prizeController,
                  decoration: const InputDecoration(
                    labelText: 'Prize Pool / Rewards',
                    hintText: 'e.g. \$2,000 + Trophy',
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final capital = double.tryParse(_capitalController.text) ?? 100000;
                            final days = int.tryParse(_durationController.text) ?? 14;

                            context.read<CompetitionProvider>().createCustomLeague(
                              title: _titleController.text,
                              organizer: _organizerController.text,
                              description: _descController.text,
                              initialCapital: capital,
                              durationDays: days,
                              prizePool: _prizeController.text,
                            );

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('College Trading League created and live!'),
                                backgroundColor: AppColors.bullGreenDark,
                              ),
                            );
                          }
                        },
                        child: const Text('Launch League'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
