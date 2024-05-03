import 'package:flutter/material.dart';

class SwipeLeftIndicator extends StatefulWidget {
  const SwipeLeftIndicator({super.key});

  @override
  _SwipeLeftIndicatorState createState() => _SwipeLeftIndicatorState();
}

class _SwipeLeftIndicatorState extends State<SwipeLeftIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _translateAnimation = Tween(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildArrow() {
    return const Icon(Icons.chevron_left, color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _translateAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_translateAnimation.value, 0),
          child: _buildArrow(),
        );
      },
    );
  }
}
