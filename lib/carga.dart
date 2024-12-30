import 'package:flutter/material.dart';
import 'perfiles.dart';

class Carga extends StatefulWidget {
  @override
  _CargaState createState() => _CargaState();
}

class _CargaState extends State<Carga> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
    _startLoading();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startLoading() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Perfiles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Snake Rewind',
              style: TextStyle(
                fontSize: 32,
                color: Color.fromARGB(255, 202, 120, 65),
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontFamily: 'PressStart2P',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: SnakePainter(animationValue: _animation.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final double animationValue;

  SnakePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final xPos = size.width * animationValue + (i * 20);
      final yPos = size.height / 2;
      canvas.drawRect(
        Rect.fromLTWH(xPos, yPos, 15, 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
