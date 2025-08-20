import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuestieSticker extends StatelessWidget {
  final bool isEarned;
  final String? category;
  final VoidCallback? onTap;
  final double size;
  final bool showLock;

  const QuestieSticker({
    super.key,
    required this.isEarned,
    this.category,
    this.onTap,
    this.size = 80,
    this.showLock = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questieIcon = _getQuestieIconByCategory(category);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main sticker with shadow and border
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isEarned 
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isEarned
                          ? RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.5,
                              colors: [
                                Colors.white,
                                theme.colorScheme.primary.withValues(alpha: 0.05),
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                              ],
                            )
                          : RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.5,
                              colors: [
                                Colors.white,
                                theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                                theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                              ],
                            ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.15), // Responsive padding
                      child: Image.asset(
                        questieIcon,
                        fit: BoxFit.contain,
                        color: isEarned 
                            ? null // Keep original colors when earned
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4), // Desaturated when locked
                        colorBlendMode: isEarned ? null : BlendMode.saturation,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Lock overlay for unearned stickers
            if (!isEarned && showLock)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.85),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  size: size * 0.3, // Responsive lock size
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getQuestieIconByCategory(String? category) {
    // Map categories to specific Questie icons for variety
    final iconMap = {
      'exploration': 'assets/icons/questie1.png',
      'adventure': 'assets/icons/questie1.png',
      'fitness': 'assets/icons/questie2.png',
      'health': 'assets/icons/questie2.png',
      'exercise': 'assets/icons/questie2.png',
      'social': 'assets/icons/questie3.png',
      'community': 'assets/icons/questie3.png',
      'friends': 'assets/icons/questie3.png',
      'learning': 'assets/icons/questie4.png',
      'education': 'assets/icons/questie4.png',
      'knowledge': 'assets/icons/questie4.png',
      'creativity': 'assets/icons/questie1.png',
      'art': 'assets/icons/questie1.png',
      'creative': 'assets/icons/questie1.png',
      'achievement': 'assets/icons/questie2.png',
      'milestone': 'assets/icons/questie2.png',
      'goal': 'assets/icons/questie2.png',
      'daily': 'assets/icons/questie3.png',
      'routine': 'assets/icons/questie3.png',
      'habit': 'assets/icons/questie3.png',
      'challenge': 'assets/icons/questie4.png',
      'quest': 'assets/icons/questie4.png',
    };

    // Return mapped icon or random one if category not found
    final mappedIcon = iconMap[category?.toLowerCase()];
    if (mappedIcon != null) {
      return mappedIcon;
    }

    // Fallback to random icon
    final icons = [
      'assets/icons/questie1.png',
      'assets/icons/questie2.png',
      'assets/icons/questie3.png',
      'assets/icons/questie4.png',
    ];
    return icons[math.Random().nextInt(icons.length)];
  }
}

// Animated sticker for quest completion
class AnimatedQuestieSticker extends StatefulWidget {
  final bool isEarned;
  final String? category;
  final VoidCallback? onTap;
  final double size;
  final Duration animationDuration;

  const AnimatedQuestieSticker({
    super.key,
    required this.isEarned,
    this.category,
    this.onTap,
    this.size = 80,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedQuestieSticker> createState() => _AnimatedQuestieStickerState();
}

class _AnimatedQuestieStickerState extends State<AnimatedQuestieSticker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.isEarned) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedQuestieSticker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEarned && !oldWidget.isEarned) {
      _controller.forward();
    } else if (!widget.isEarned && oldWidget.isEarned) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: QuestieSticker(
              isEarned: widget.isEarned,
              category: widget.category,
              onTap: widget.onTap,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
