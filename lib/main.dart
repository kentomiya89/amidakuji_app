import 'package:amidakuji_app/amidakuji_utils.dart';
import 'package:amidakuji_app/model/amida_lottery.dart';
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

// あみだのスペース
const double _kColumnSpacing = 60;

// キャンバスのサイズ
const double _kCanvasWidth = 1250;
const double _kCanvasHeight = 500;

class AmidaScreen extends StatefulWidget {
  const AmidaScreen({required this.columns, super.key});
  final int columns;

  @override
  State<AmidaScreen> createState() => _AmidaScreenState();
}

class _AmidaScreenState extends State<AmidaScreen> {
  late List<HorizontalLine> _horizontalLines;
  late List<Participant> nameList;
  late List<AmidaLottery> lotteryList;
  List<List<Offset>> _winningLinePaths = [];

  @override
  void initState() {
    super.initState();
    _horizontalLines = _generateRandomHorizontalLines(widget.columns);

    // デモデータ
    nameList = List.generate(
      widget.columns,
      (_) => const Participant(
        firstName: '太郎',
        lastName: '山田',
      ),
    ).toList();

    lotteryList = [
      // 当たりは2つだけ
      AmidaLottery.win,
      AmidaLottery.win,
      ...List.generate(widget.columns - 2, (_) => AmidaLottery.lose),
    ]..shuffle();
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

  void _calculateWinningLinePaths() {
    final paths = <List<Offset>>[];

    // "当たり"の列を探す
    final winningIndices = [
      for (var i = 0; i < lotteryList.length; i++)
        if (lotteryList[i] == AmidaLottery.win) i,
    ];

    for (final winningIndex in winningIndices) {
      final path = <Offset>[];

      // 開始点（"当たり"の位置から上方向に進む）
      var currentX = winningIndex * _kColumnSpacing;
      var currentY = _kCanvasHeight;
      path.add(Offset(currentX, currentY));

      // 最後に処理した横線のY座標を記録して、同じ高さの横線を再度処理しないようにする
      double? lastProcessedY;

      while (currentY > 0) {
        // 現在の位置から上方向にある最も近い横線を探す
        final availableLines = _horizontalLines.where((line) {
          final lineY = line.yPositionFactor * _kCanvasHeight;
          return lineY < currentY && // 現在位置より上にある
              (lastProcessedY == null ||
                  lineY != lastProcessedY) && // まだ処理していない高さ
              (line.startColomn * _kColumnSpacing == currentX ||
                  line.endColumn * _kColumnSpacing == currentX); // 現在の列に接続している
        }).toList()
          ..sort(
            // Y座標でソートして最も近い（大きい）ものを選択
            (a, b) => (b.yPositionFactor * _kCanvasHeight)
                .compareTo(a.yPositionFactor * _kCanvasHeight),
          );

        if (availableLines.isNotEmpty) {
          final nextLine = availableLines.first;
          currentY = nextLine.yPositionFactor * _kCanvasHeight;
          path.add(Offset(currentX, currentY));

          // 横線を渡る
          currentX = (nextLine.startColomn * _kColumnSpacing == currentX)
              ? nextLine.endColumn * _kColumnSpacing
              : nextLine.startColomn * _kColumnSpacing;
          path.add(Offset(currentX, currentY));

          // 処理した高さを記録
          lastProcessedY = currentY;
        } else {
          // 横線がない場合は上に進む
          currentY = 0;
          path.add(Offset(currentX, currentY));
        }
      }

      paths.add(path);
    }

    setState(() {
      _winningLinePaths = paths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              size: const Size(_kCanvasWidth, _kCanvasHeight),
              painter: AmidaPainter(
                horizontalLines: _horizontalLines,
                nameList: nameList,
                lotteryList: lotteryList,
                winningLinePaths: _winningLinePaths,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _calculateWinningLinePaths,
          child: const Text('当選者を確定させる'),
        ),
      ],
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
    required this.lotteryList,
    required this.winningLinePaths,
  });

  final List<HorizontalLine> horizontalLines;
  final List<Participant> nameList;
  final List<AmidaLottery> lotteryList;
  final List<List<Offset>> winningLinePaths;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < horizontalLines.length + 1; i++) {
      // 縦線を端から端まで引く
      final x = i * _kColumnSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      // 各縦線の上に名前を描画
      final nameTextPainter = TextPainter(
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

      final nameOffset = Offset(
        x - nameTextPainter.width / 2, // 中央揃え
        -nameTextPainter.height - 5, // 縦線の上に少し余白を加える
      );
      nameTextPainter.paint(canvas, nameOffset);

      // 各縦線の下に当たりを描画
      if (lotteryList[i] == AmidaLottery.win) {
        final lotteryTextPainter = TextPainter(
          text: const TextSpan(
            text: '当たり',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final lotteryOffset = Offset(
          x - lotteryTextPainter.width / 2, // 中央揃え
          size.height + 5, // 縦線の下に少し余白を加える
        );

        lotteryTextPainter.paint(canvas, lotteryOffset);
      }
    }

    // 横線を引く
    for (final line in horizontalLines) {
      final startColumn = line.startColomn;
      final endColumn = line.endColumn;
      final yFactor = line.yPositionFactor;

      final startX = startColumn * _kColumnSpacing;
      final endX = endColumn * _kColumnSpacing;
      final y = size.height * yFactor;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }

    // 当たりの線を描画
    // 当選者は2つのみ
    if (winningLinePaths.isNotEmpty && winningLinePaths.length == 2) {
      // 1人目の当選者を赤色で塗っていく
      final redPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final redLinePath = winningLinePaths.first;
      for (var i = 0; i < redLinePath.length - 1; i++) {
        canvas.drawLine(redLinePath[i], redLinePath[i + 1], redPaint);
      }

      // 2人目の当選者
      final orangePaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final orangeLinePath = winningLinePaths.last;

      for (var i = 0; i < orangeLinePath.length - 1; i++) {
        canvas.drawLine(orangeLinePath[i], orangeLinePath[i + 1], orangePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
