import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A subtle quest completion indicator that shows inline without blocking the UI
class QuestCompletionIndicator extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback? onAnimationComplete;
  final Duration animationDuration;

  const QuestCompletionIndicator({
    super.key,
    required this.isCompleted,
    this.onAnimationComplete,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<QuestCompletionIndicator> createState() => _QuestCompletionIndicatorState();
}

class _QuestCompletionIndicatorState extends State<QuestCompletionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (widget.isCompleted) {
      _animateCompletion();
    }
  }

  @override
  void didUpdateWidget(QuestCompletionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted && !_hasAnimated) {
      _animateCompletion();
    }
  }

  void _animateCompletion() {
    if (_hasAnimated) return;
    _hasAnimated = true;
    
    _controller.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCompleted) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E6B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B8E6B).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A floating quest completion animation that appears briefly and fades away
class FloatingQuestCompletionAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const FloatingQuestCompletionAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<FloatingQuestCompletionAnimation> createState() => _FloatingQuestCompletionAnimationState();
}

class _FloatingQuestCompletionAnimationState extends State<FloatingQuestCompletionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late String _selectedIcon;

  final List<String> _questieIcons = [
    'assets/icons/questie1.png',
    'assets/icons/questie2.png',
    'assets/icons/questie3.png',
    'assets/icons/questie4.png',
  ];

  @override
  void initState() {
    super.initState();
    
    // Select random icon
    _selectedIcon = _questieIcons[math.Random().nextInt(_questieIcons.length)];
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
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
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF6B8E6B).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B8E6B).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    _selectedIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
