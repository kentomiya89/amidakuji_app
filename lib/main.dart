import 'package:amidakuji_app/amidakuji_utils.dart';
import 'package:amidakuji_app/model/participant.dart';
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
        body: const AmidaScreen(columns: 20),
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
  late List<Participant> nameList;

  @override
  void initState() {
    super.initState();
    _horizontalLines = _generateRandomHorizontalLines(widget.columns);
    nameList = List.generate(
      widget.columns,
      (_) => const Participant(
        firstName: '太郎',
        lastName: '山田',
      ),
    ).toList();
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
          size: const Size(1250, 500),
          painter: AmidaPainter(
            horizontalLines: _horizontalLines,
            nameList: nameList,
          ),
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
  AmidaPainter({
    required this.horizontalLines,
    required this.nameList,
  });

  final List<HorizontalLine> horizontalLines;
  final List<Participant> nameList;

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

      // 各縦線の上に名前を描画
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: '${nameList[i].lastName}\n'),
            TextSpan(text: nameList[i].firstName),
          ],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        x - textPainter.width / 2, // 中央揃え
        -textPainter.height - 5, // 縦線の上に少し余白を加える
      );
      textPainter.paint(canvas, textOffset);
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
