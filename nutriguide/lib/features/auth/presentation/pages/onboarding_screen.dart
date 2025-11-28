import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/auth/presentation/providers/auth_provider.dart';
import 'package:nutriguide/features/auth/presentation/widgets/dietary_preferences_form.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const OnboardingScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  List<String> _goals = [];
  List<String> _restrictions = [];

  void _onFinish() {
    if (_goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal')),
      );
      return;
    }

    // Call API
    ref.read(authProvider.notifier).register(
          email: widget.email,
          password: widget.password,
          goals: _goals,
          restrictions: _restrictions,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for registration success
    ref.listen(authProvider, (prev, next) {
      next.whenOrNull(
        error: (err, stack) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(err.toString()), backgroundColor: AppColors.error),
        ),
        data: (user) {
          if (user != null) {
            // Navigate to Home and remove all previous routes
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
      );
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Personalize')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us about your needs',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We will tailor recipe suggestions to your goals and restrictions.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    DietaryPreferencesForm(
                      onChanged: (goals, restrictions) {
                        setState(() {
                          _goals = goals;
                          _restrictions = restrictions;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onFinish,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Finish & Create Account'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
