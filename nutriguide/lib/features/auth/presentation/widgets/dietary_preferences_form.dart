import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';

class DietaryPreferencesForm extends StatefulWidget {
  final Function(List<String> goals, List<String> restrictions) onChanged;

  const DietaryPreferencesForm({super.key, required this.onChanged});

  @override
  State<DietaryPreferencesForm> createState() => _DietaryPreferencesFormState();
}

class _DietaryPreferencesFormState extends State<DietaryPreferencesForm> {
  // Goal Selection (Single Select usually, but API supports list)
  final List<String> _selectedGoals = [];
  final List<String> _goalsOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance',
    'General Wellness'
  ];

  // Restrictions (Multi Select)
  final List<String> _selectedRestrictions = [];
  final List<String> _restrictionOptions = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Low-Carb',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free'
  ];

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.clear(); // Single select behavior for goals
        _selectedGoals.add(goal);
      }
      widget.onChanged(_selectedGoals, _selectedRestrictions);
    });
  }

  void _toggleRestriction(String restriction) {
    setState(() {
      if (_selectedRestrictions.contains(restriction)) {
        _selectedRestrictions.remove(restriction);
      } else {
        _selectedRestrictions.add(restriction);
      }
      widget.onChanged(_selectedGoals, _selectedRestrictions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary Goal', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goalsOptions.map((goal) {
            final isSelected = _selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              onSelected: (_) => _toggleGoal(goal),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Text('Dietary Restrictions',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _restrictionOptions.map((item) {
            final isSelected = _selectedRestrictions.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: AppColors.secondary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.secondary,
              onSelected: (_) => _toggleRestriction(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
