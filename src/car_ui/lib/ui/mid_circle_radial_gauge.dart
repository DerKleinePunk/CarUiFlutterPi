//https://gist.github.com/rm3l/50d608c3595207dc134545ead0101bcc?ref=armel.soro.io

import 'dart:math';

import 'package:flutter/material.dart';

class MyCustomRadialGauge extends StatefulWidget {
  const MyCustomRadialGauge({super.key});

  @override
  State<MyCustomRadialGauge> createState() => _MyCustomRadialGaugeState();
}

class _MyCustomRadialGaugeState extends State<MyCustomRadialGauge>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  double _fraction = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final maxValue = 1700;
    final current = 1234.5;

    return CustomPaint(
      foregroundPainter:
          _MyCustomRadialGaugePainter(_fraction, maxValue, current),
      child: Container(
        padding: EdgeInsets.only(top: screenHeight * 0.0875),
        width: screenWidth * 0.34,
        child: Center(
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.01,
                color: Colors.transparent,
              ),
              Text(
                '${(100 * current / maxValue).toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.grey, fontSize: 50.0),
              ),
              Container(
                height: screenHeight * 0.027,
                color: Colors.transparent,
              ),
              Container(
                  height: screenHeight * 0.04,
                  child: Text('Title', style: TextStyle(fontSize: 22.0)))
            ],
          ),
        ),
      ),
    );
  }
}

class _MyCustomRadialGaugePainter extends CustomPainter {
  final num maxValue;
  final num current;

  double _fraction;

  _MyCustomRadialGaugePainter(this._fraction, this.maxValue, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final complete = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13.0;

    final line = Paint()
      ..color = const Color(0xFFE9E9E9)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height);

    final startAngle = -7 * pi / 6;
    final sweepAngle = 4 * pi / 3;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, line);

    final arcAngle = (sweepAngle) * (current / maxValue);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        arcAngle * _fraction, false, complete);

    final lowerBoundText = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(text: '0', style: TextStyle(color: Colors.grey))
      ..layout(minWidth: 0, maxWidth: double.maxFinite);
    lowerBoundText.paint(
        canvas, Offset(-size.width * 0.42, size.height / 1.22));

    final upperBoundText = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(text: '$maxValue', style: TextStyle(color: Colors.grey))
      ..layout(minWidth: 0, maxWidth: double.maxFinite);
    upperBoundText.paint(canvas, Offset(size.width / 0.77, size.height / 1.22));
  }

  @override
  bool shouldRepaint(_MyCustomRadialGaugePainter oldDelegate) =>
      oldDelegate._fraction != _fraction;
}
