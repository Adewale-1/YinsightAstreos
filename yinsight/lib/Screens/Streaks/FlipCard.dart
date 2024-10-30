import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class FlipCardScreen extends StatefulWidget {
  const FlipCardScreen({super.key});

  @override
  _FlipCardScreenState createState() => _FlipCardScreenState();
}

class _FlipCardScreenState extends State<FlipCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  double _dragStartX = 0;
  double _dragEndX = 0;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    // Automatically start the animation on screen transition
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isAnimating) return; // Prevent toggle during animation

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      _isFront = !_isFront;
    });
  }

  // void _toggleCard2() {
  //   _isFront = !_isFront;
  // }

  Future<void> _captureAndSharePng() async {
    try {
      // Capture the card
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath =
            await File('${directory.path}/card_image.png').create();
        await imagePath.writeAsBytes(imageBytes);

        // Share the image
        await Share.shareXFiles([XFile(imagePath.path)]);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back),
  //         onPressed: () {
  //           Navigator.pop(context);
  //         },
  //       ),
  //     ),
  //     body: SafeArea(
  //       child: Column(
  //         children: [
  //           Expanded(
  //             child: Center(
  //               child: Screenshot(
  //                 controller: screenshotController,
  //                 child: GestureDetector(
  //                   onHorizontalDragStart: (details) {
  //                     _dragStartX = details.globalPosition.dx;
  //                   },
  //                   onHorizontalDragUpdate: (details) {
  //                     _dragEndX = details.globalPosition.dx;
  //                     double dragDistance = (_dragEndX - _dragStartX) /
  //                         MediaQuery.of(context).size.width;

  //                     setState(() {
  //                       if (_isFront) {
  //                         _controller.value = dragDistance.abs() > 0.5
  //                             ? 0.5
  //                             : dragDistance.abs();
  //                       } else {
  //                         _controller.value = 1 -
  //                             (dragDistance.abs() > 0.5
  //                                 ? 0.5
  //                                 : dragDistance.abs());
  //                       }
  //                     });
  //                   },
  //                   onHorizontalDragEnd: (details) {
  //                     if ((_dragEndX - _dragStartX).abs() >
  //                         MediaQuery.of(context).size.width / 4) {
  //                       _toggleCard();
  //                     } else {
  //                       if (_isFront) {
  //                         _controller.reverse();
  //                       } else {
  //                         _controller.forward();
  //                       }
  //                     }
  //                   },
  //                   child: Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       // // Back of the card (black with image)
  //                       // Transform(
  //                       //   alignment: Alignment.center,
  //                       //   transform: Matrix4.identity()
  //                       //     ..rotateY(pi * _animation.value),
  //                       //   child: Container(
  //                       //     width: 300,
  //                       //     height: 400,
  //                       //     decoration: BoxDecoration(
  //                       //       image: DecorationImage(
  //                       //         image: AssetImage('lib/Assets/Image_Comp/FlipCardImages/newbie.png'), // Your image path
  //                       //         fit: BoxFit.cover,
  //                       //       ),
  //                       //     ),
  //                       //   ),
  //                       // ),
  //                       // Back of the card (black with image)
  //                       Transform(
  //                         alignment: Alignment.center,
  //                         transform: Matrix4.identity()
  //                           ..rotateY(pi * (0.5)),
  //                         child: ClipPath(
  //                           clipper: CardClipper(),
  //                           child: Container(
  //                             width: 320,
  //                             height: 430,
  //                             decoration: BoxDecoration(
  //                               image: DecorationImage(
  //                                 image: AssetImage(
  //                                     'lib/Assets/Image_Comp/FlipCardImages/newbie.png'), // Replace with actual image path
  //                                 fit: BoxFit.cover,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       // Front of the card (custom shape)
  //                       Transform(
  //                         alignment: Alignment.center,
  //                         transform: Matrix4.identity()
  //                           ..rotateY(pi * (1 - _animation.value)),
  //                         child: ClipPath(
  //                           clipper: CardClipper(),
  //                           child: Container(
  //                             width: 320,
  //                             height: 430,
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: const BorderRadius.only(
  //                                 topRight: Radius.circular(20),
  //                                 bottomLeft: Radius.circular(20),
  //                               ),
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Colors.grey.withOpacity(1.0),
  //                                   spreadRadius: 5,
  //                                   blurRadius: 7,
  //                                   offset: const Offset(0, 3),
  //                                 ),
  //                               ],
  //                             ),
  //                             child: _buildCardContent(),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: ElevatedButton(
  //               onPressed: _captureAndSharePng,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.blue,
  //                 foregroundColor: Colors.white,
  //                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  //               ),
  //               child: const Text('Share Card', style: TextStyle(fontSize: 18)),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Screenshot(
                  controller: screenshotController,
                  child: GestureDetector(
                    onHorizontalDragStart: (details) {
                      _dragStartX = details.globalPosition.dx;
                    },
                    onHorizontalDragUpdate: (details) {
                      _dragEndX = details.globalPosition.dx;
                      double dragDistance = (_dragEndX - _dragStartX) /
                          MediaQuery.of(context).size.width;

                      //   setState(() {
                      //     if (_isFront) {
                      //       _controller.value = 1 - dragDistance.abs().clamp(0.0, 1.0);
                      //     } else {
                      //       _controller.value = dragDistance.abs().clamp(0.0, 1.0);
                      //     }
                      //   });
                      // },
                      setState(() {
                        if (_isFront) {
                          _controller.value = dragDistance.abs() > 0.5
                              ? 0.5
                              : dragDistance.abs();
                        } else {
                          _controller.value = 1 -
                              (dragDistance.abs() > 0.5
                                  ? 0.5
                                  : dragDistance.abs());
                        }
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if ((_dragEndX - _dragStartX).abs() >
                          MediaQuery.of(context).size.width / 4) {
                        _toggleCard();
                      } else {
                        if (_isFront) {
                          _controller.reverse();
                        } else {
                          _controller.forward();
                        }
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Back of the card (black with image)
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0005) // This adds perspective
                            ..rotateY(pi * _animation.value),
                          child: ClipPath(
                            clipper: CardClipper(),
                            child: Container(
                              width: 320,
                              height: 430,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'lib/Assets/Image_Comp/FlipCardImages/newbie.png'), // Replace with actual image path
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Front of the card (custom shape)
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(pi * (1 - _animation.value))
                            ..setEntry(3, 2,
                                0.0005), // Apply perspective to ensure a 3D effect
                          child: ClipPath(
                            clipper: CardClipper(),
                            child: Opacity(
                              opacity: _animation.value,
                              child: Container(
                                width: 320,
                                height: 430,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(1.0),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: _buildCardContent(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _captureAndSharePng,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Share Card', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MM/dd/yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATE',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    dateFormat.format(now),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'TIME',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    timeFormat.format(now),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'USERNAME',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  // Text(
                  //   '@THEPRASANJITSAHOO',
                  //   style: TextStyle(fontSize: 16, color: Colors.black),
                  // ),
                ],
              ),
              Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.orange,
              ),
            ],
          ),
          Spacer(),
          Divider(
            color: Colors.orange,
            thickness: 2,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(
                    'lib/Assets/Image_Comp/HomeImages/User.png'), // Replace with actual image path
                radius: 20,
              ),
              SizedBox(width: 8),
              Text(
                '@THEPRASANJITSAHOO',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Spacer(),
              // Text(
              // '1',
              // style: TextStyle(fontSize: 16, color: Colors.black),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    double radius = 20.0;
    double nickRadius = 20.0;

    // Start at top left (no curve)
    path.moveTo(0, 0);

    // Top side
    path.lineTo(size.width / 2 - nickRadius, 0);

    // Top nick
    path.arcToPoint(Offset(size.width / 2 + nickRadius, 0),
        radius: Radius.circular(nickRadius), clockwise: false);

    // Top side to top right corner
    path.lineTo(size.width - radius, 0);

    // Top right corner (curved)
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right side
    path.lineTo(size.width, size.height - radius);

    // Bottom right corner (no curve)
    path.lineTo(size.width, size.height);

    // Bottom side
    path.lineTo(size.width / 2 + nickRadius, size.height);

    // Bottom nick
    path.arcToPoint(Offset(size.width / 2 - nickRadius, size.height),
        radius: Radius.circular(nickRadius), clockwise: false);

    // Bottom side to bottom left corner
    path.lineTo(radius, size.height);

    // Bottom left corner (curved)
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Left side
    path.lineTo(0, radius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
