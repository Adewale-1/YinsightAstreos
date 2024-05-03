// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class CustomSunburstPainter extends CustomPainter {
//   final Animation<double> animation;

//   CustomSunburstPainter(this.animation) : super(repaint: animation);

//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.orange // Choose the color of the sunburst here
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3; // Choose the width of the sunburst lines here

//     var center = Offset(size.width / 2, size.height / 2);
//     var radius = size.width / 2;

//     // Draw lines around the circle
//     for (int i = 0; i < 360; i += 5) { // Adjust the step for more or fewer lines
//       var x1 = center.dx + radius * math.cos(i * math.pi / 180);
//       var y1 = center.dy + radius * math.sin(i * math.pi / 180);
//       var x2 = center.dx + (radius + animation.value) * math.cos(i * math.pi / 180);
//       var y2 = center.dy + (radius + animation.value) * math.sin(i * math.pi / 180);
//       canvas.drawLine(center, Offset(x2, y2), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(CustomSunburstPainter oldDelegate) => false;
// }

// class SunburstAnimationWidget extends StatefulWidget {
//   final Widget child;

//   const SunburstAnimationWidget({super.key, required this.child});

//   @override
//   _SunburstAnimationWidgetState createState() => _SunburstAnimationWidgetState();
// }

// class _SunburstAnimationWidgetState extends State<SunburstAnimationWidget> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _animation = Tween<double>(begin: 0, end: 15).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: CustomSunburstPainter(_animation),
//       child: widget.child,
//     );
//   }
// }
