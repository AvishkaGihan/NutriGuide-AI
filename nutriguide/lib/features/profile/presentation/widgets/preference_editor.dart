import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/profile/domain/entities/user_profile.dart';

class PreferenceEditor extends StatefulWidget {
  final UserProfile currentProfile;
  final Function(UserProfile) onSave;
  final VoidCallback onCancel;

  const PreferenceEditor({
    super.key,
    required this.currentProfile,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<PreferenceEditor> createState() => _PreferenceEditorState();
}

class _PreferenceEditorState extends State<PreferenceEditor> {
  // Goal Selection
  late List<String> _selectedGoals;
  final List<String> _goalsOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance',
    'General Wellness'
  ];

  // Restrictions
  late List<String> _selectedRestrictions;
  final List<String> _restrictionOptions = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Low-Carb',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free'
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoals = List.from(widget.currentProfile.dietaryGoals ?? []);
    _selectedRestrictions = List.from(widget.currentProfile.restrictions ?? []);
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.clear(); // Single select
        _selectedGoals.add(goal);
      }
    });
  }

  void _toggleRestriction(String restriction) {
    setState(() {
      if (_selectedRestrictions.contains(restriction)) {
        _selectedRestrictions.remove(restriction);
      } else {
        _selectedRestrictions.add(restriction);
      }
    });
  }

  void _handleSave() {
    // Create new profile object with updates
    // Note: This relies on manual copying since UserProfile is immutable
    final updated = UserProfile(
      id: widget.currentProfile.id,
      email: widget.currentProfile.email,
      dietaryGoals: _selectedGoals,
      restrictions: _selectedRestrictions,
      allergies: widget.currentProfile.allergies, // Preserve other fields
      activityLevel: widget.currentProfile.activityLevel,
      ageRange: widget.currentProfile.ageRange,
      gender: widget.currentProfile.gender,
    );

    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(77)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Preferences',
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Goals
          Text('Goal',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _goalsOptions.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (_) => _toggleGoal(goal),
                selectedColor: AppColors.primary.withAlpha(51),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Restrictions
          Text('Restrictions',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _restrictionOptions.map((item) {
              final isSelected = _selectedRestrictions.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (_) => _toggleRestriction(item),
                selectedColor: AppColors.secondary.withAlpha(51),
                checkmarkColor: AppColors.secondary,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSave,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
