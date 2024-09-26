import 'package:flutter/material.dart';

class BarChartPainter extends CustomPainter {
  final List<int> filteredValues;
  final double animationValue;
  final List<String> workoutTypes;

  final int yAxisMaxValue = 100;
  final int yAxisMinValue = 0;

  BarChartPainter(this.filteredValues, this.animationValue, this.workoutTypes);

  @override
  void paint(Canvas canvas, Size size) {
    double barWidth = size.width / (filteredValues.length * 1.7);
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int index = 0; index < filteredValues.length; index++) {
      double barHeight = (filteredValues[index] / yAxisMaxValue) *
          size.height *
          animationValue;
      canvas.drawRect(
        Rect.fromLTWH(index * 1.4 * barWidth + 20, size.height - barHeight,
            barWidth, barHeight),
        paint,
      );

      TextSpan valueSpan = TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 10),
          text: filteredValues[index].toString());
      TextPainter valuePainter = TextPainter(
        text: valueSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
          canvas,
          Offset(index * 1.5 * barWidth + 13 + (barWidth / 4),
              size.height - barHeight - 20));
    }

    double xSpacing = size.width / (workoutTypes.length + 1);
    for (int index = 0; index < workoutTypes.length; index++) {
      TextSpan typeSpan = TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 6),
          text: workoutTypes[index]);
      TextPainter typePainter = TextPainter(
        text: typeSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      typePainter.layout();
      typePainter.paint(
          canvas,
          Offset(
              index * xSpacing + 25 - typePainter.width / 2, size.height + 5));
    }

    for (int i = yAxisMinValue; i <= yAxisMaxValue; i += 10) {
      TextSpan tickSpan = TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 10),
          text: i.toString());
      TextPainter tickPainter = TextPainter(
        text: tickSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tickPainter.layout();
      tickPainter.paint(
          canvas,
          Offset(
              -10,
              size.height -
                  (i / yAxisMaxValue) * size.height -
                  tickPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
