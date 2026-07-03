import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/training.dart';
import '../models/weekly_plan.dart';
import '../models/weekly_plan_with_schedule.dart';
import '../providers/database_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_screen_body.dart';

class WeeklyPlanFormScreen extends ConsumerStatefulWidget {
  const WeeklyPlanFormScreen({super.key, this.existingPlan});

  final WeeklyPlanWithSchedule? existingPlan;

  @override
  ConsumerState<WeeklyPlanFormScreen> createState() =>
      _WeeklyPlanFormScreenState();
}

class _WeeklyPlanFormScreenState extends ConsumerState<WeeklyPlanFormScreen> {
  final _nameController = TextEditingController();
  List<Training> _trainings = [];
  final Map<int, Training?> _selectedByDay = {for (var d = 1; d <= 7; d++) d: null};
  bool _loading = true;

  bool get _isEditing => widget.existingPlan != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingPlan!.plan.name;
      _selectedByDay.addAll(widget.existingPlan!.trainingByDay);
    }
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    final list =
        await ref.read(trainingServiceProvider).readAllTrainings() ?? [];
    if (mounted) {
      setState(() {
        _trainings = list;
        _loading = false;
      });
    }
  }

  String _dayName(AppLocalizations l10n, int day) {
    switch (day) {
      case 1:
        return l10n.dayMonday;
      case 2:
        return l10n.dayTuesday;
      case 3:
        return l10n.dayWednesday;
      case 4:
        return l10n.dayThursday;
      case 5:
        return l10n.dayFriday;
      case 6:
        return l10n.daySaturday;
      case 7:
        return l10n.daySunday;
      default:
        return '';
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.weeklyPlanNameEmpty)),
      );
      return;
    }

    final service = ref.read(weeklyPlanServiceProvider);
    try {
      if (_isEditing) {
        await service.updateWeeklyPlan(
          widget.existingPlan!.plan.copy(name: name),
        );
        await service.saveSchedule(
          weeklyPlanId: widget.existingPlan!.plan.id!,
          trainingIdByDay: {
            for (final e in _selectedByDay.entries) e.key: e.value?.id,
          },
        );
      } else {
        final created = await service.createWeeklyPlan(WeeklyPlan(name: name));
        await service.saveSchedule(
          weeklyPlanId: created.id!,
          trainingIdByDay: {
            for (final e in _selectedByDay.entries) e.key: e.value?.id,
          },
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.weeklyPlanNameTaken)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.weeklyPlanEditTitle : l10n.weeklyPlansAdd,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppScreenBody(
              scrollable: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                        InputDecoration(labelText: l10n.weeklyPlanNameLabel),
                  ),
                  AppSpacing.gapMd,
                  if (_trainings.isEmpty)
                    Text(l10n.weeklyPlanNoTrainingsAvailable)
                  else
                    ...List.generate(7, (index) {
                      final day = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: DropdownButtonFormField<Training?>(
                          value: _selectedByDay[day],
                          decoration: InputDecoration(
                            labelText: _dayName(l10n, day),
                          ),
                          items: [
                            DropdownMenuItem<Training?>(
                              value: null,
                              child: Text(l10n.weeklyPlanRestDay),
                            ),
                            ..._trainings.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedByDay[day] = value);
                          },
                        ),
                      );
                    }),
                  AppSpacing.gapMd,
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(l10n.weeklyPlanSave),
                  ),
                ],
              ),
            ),
    );
  }
}
