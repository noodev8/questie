import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuestStampAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;
  final double size;
  
  const QuestStampAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 800), // Perfect timing
    this.size = 120,
  });

  @override
  State<QuestStampAnimation> createState() => _QuestStampAnimationState();
}

class _QuestStampAnimationState extends State<QuestStampAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Random icon selection
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

    // Scale animation: starts big, bounces to normal size
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Rotation animation: slight rotation for stamp effect
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Opacity animation: fade in then stay visible
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    // Slide animation: slight downward movement for stamp effect
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Start animation and call onComplete when done
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
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B8E6B).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.2,
                          colors: [
                            const Color(0xFF6B8E6B).withValues(alpha: 0.1),
                            const Color(0xFF6B8E6B).withValues(alpha: 0.05),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          _selectedIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
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

// Overlay widget to show stamp animation on top of other content
class QuestStampOverlay extends StatefulWidget {
  final Widget child;
  final bool showStamp;
  final VoidCallback? onStampComplete;
  
  const QuestStampOverlay({
    super.key,
    required this.child,
    required this.showStamp,
    this.onStampComplete,
  });

  @override
  State<QuestStampOverlay> createState() => _QuestStampOverlayState();
}

class _QuestStampOverlayState extends State<QuestStampOverlay> {
  bool _isAnimating = false;

  @override
  void didUpdateWidget(QuestStampOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showStamp && !oldWidget.showStamp && !_isAnimating) {
      setState(() {
        _isAnimating = true;
      });
    }
  }

  void _onStampComplete() {
    setState(() {
      _isAnimating = false;
    });
    if (widget.onStampComplete != null) {
      widget.onStampComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isAnimating)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: QuestStampAnimation(
                  onComplete: _onStampComplete,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
