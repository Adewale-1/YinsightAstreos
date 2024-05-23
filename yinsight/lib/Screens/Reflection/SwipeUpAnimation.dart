import 'package:flutter/material.dart';

/// A widget that displays a swipe up indicator animation.
class SwipeUpIndicator extends StatefulWidget {
  const SwipeUpIndicator({super.key});

  @override
  _SwipeUpIndicatorState createState() => _SwipeUpIndicatorState();
}

class _SwipeUpIndicatorState extends State<SwipeUpIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Builds an arrow icon with the specified color.
  Widget _buildArrow(Color color) {
    return Icon(
      Icons.expand_less,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
                opacity: (_opacityAnimation.value * 0.5).clamp(0.0, 1.0),
                child: _buildArrow(Colors.black38)),
            const SizedBox(height: 2.0),
            Opacity(
                opacity: (_opacityAnimation.value * 0.8).clamp(0.0, 1.0),
                child: _buildArrow(Colors.black54)),
            const SizedBox(height: 2.0),
            Opacity(
                opacity: _opacityAnimation.value,
                child: _buildArrow(Colors.black)),
          ],
        );
      },
    );
  }
}
