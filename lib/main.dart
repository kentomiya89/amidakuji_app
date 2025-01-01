import 'package:amidakuji_app/amidakuji_utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AmidaApp());
}

class AmidaApp extends StatelessWidget {
  const AmidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('あみだくじ'),
        ),
        body: const AmidaScreen(columns: 10),
      ),
    );
  }
}

class AmidaScreen extends StatefulWidget {
  const AmidaScreen({required this.columns, super.key});
  final int columns;

  @override
  State<AmidaScreen> createState() => _AmidaScreenState();
}

class _AmidaScreenState extends State<AmidaScreen> {
  late List<HorizontalLine> _horizontalLines;

  @override
  void initState() {
    super.initState();
    _horizontalLines = _generateRandomHorizontalLines(widget.columns);
  }

  List<HorizontalLine> _generateRandomHorizontalLines(int columns) {
    const min = 1;
    const max = 20;

    final horizontalLinesList = <HorizontalLine>[];

    double? prevYPositionFactor;

    for (var i = 0; i < columns - 1; i++) {
      late double newYPositionFactor;
      do {
        newYPositionFactor = randomDecimalInRangeWithStep05(min, max);
      } while (prevYPositionFactor == newYPositionFactor);

      prevYPositionFactor = newYPositionFactor;

      horizontalLinesList.add(
        HorizontalLine(
          startColomn: i,
          endColumn: i + 1,
          yPositionFactor: newYPositionFactor,
        ),
      );
    }

    return horizontalLinesList;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          size: const Size(1000, 500),
          painter: AmidaPainter(horizontalLines: _horizontalLines),
        ),
      ),
    );
  }
}

class HorizontalLine {
  const HorizontalLine({
    required this.startColomn,
    required this.endColumn,
    required this.yPositionFactor,
  });

  final int startColomn;
  final int endColumn;
  final double yPositionFactor;
}

class AmidaPainter extends CustomPainter {
  AmidaPainter({required this.horizontalLines});

  final List<HorizontalLine> horizontalLines;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double columnSpacing = 60;

    // 縦線を端から端まで引く
    // 縦線は横線の+1の数分必要
    for (var i = 0; i < horizontalLines.length + 1; i++) {
      final x = i * columnSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 横線を引く
    for (final line in horizontalLines) {
      final startColumn = line.startColomn;
      final endColumn = line.endColumn;
      final yFactor = line.yPositionFactor;

      final startX = startColumn * columnSpacing;
      final endX = endColumn * columnSpacing;
      final y = size.height * yFactor;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
