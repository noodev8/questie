import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for calm mode state
final calmModeProvider = StateProvider<bool>((ref) => false);

class CalmModeToggle extends ConsumerWidget {
  const CalmModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCalmMode = ref.watch(calmModeProvider);
    
    return Card(
      color: isCalmMode 
          ? const Color(0xFFF0F8F0) // Very light green for calm mode
          : Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCalmMode
                    ? const Color(0xFF6B8E6B).withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCalmMode ? Icons.spa_outlined : Icons.energy_savings_leaf_outlined,
                color: isCalmMode 
                    ? const Color(0xFF6B8E6B)
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCalmMode ? 'Calm Mode' : 'Regular Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCalmMode ? const Color(0xFF6B8E6B) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCalmMode 
                        ? 'Slower pace, mindful quests'
                        : 'Daily adventures await',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Switch.adaptive(
              value: isCalmMode,
              onChanged: (value) {
                ref.read(calmModeProvider.notifier).state = value;

                // Show a gentle feedback - use post frame callback to ensure context is valid
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? '🌿 Calm Mode activated. Take your time.'
                              : '✨ Regular Mode activated. Let\'s explore!',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                });
              },
              activeColor: const Color(0xFF6B8E6B),
            ),
          ],
        ),
      ),
    );
  }
}
