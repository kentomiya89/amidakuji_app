import 'dart:async';
import 'dart:ui' as ui;
import 'package:amidakuji_app/amidakuji_utils.dart';
import 'package:amidakuji_app/model/amida_lottery.dart';
import 'package:amidakuji_app/model/participant.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

// あみだのスペース
const double _kColumnSpacing = 60;

// キャンバスのサイズ
const double _kCanvasWidth = 1250;
const double _kCanvasHeight = 500;

class AmidaBody extends StatefulWidget {
  const AmidaBody({
    required this.participantList,
    required this.wininngImagePath,
    super.key,
  });

  final String wininngImagePath;
  final List<Participant> participantList;

  @override
  State<AmidaBody> createState() => _AmidaBodyState();
}

class _AmidaBodyState extends State<AmidaBody>
    with SingleTickerProviderStateMixin {
  List<HorizontalLine> _horizontalLines = [];
  late List<AmidaLottery> lotteryList = [
    // 当たりは2つだけ
    AmidaLottery.win,
    AmidaLottery.win,
    ...List.generate(
      widget.participantList.length - 2,
      (_) => AmidaLottery.lose,
    ),
  ]..shuffle();
  List<List<Offset>> _winningLinePaths = [];
  ui.Image? image;

  bool isShowButton = true;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _horizontalLines =
        _generateRandomHorizontalLines(widget.participantList.length);

    // アニメーションの設定
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // アニメーションの持続時間
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final imageData = await _loadAssetImage(widget.wininngImagePath);
      setState(() {
        image = imageData;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<ui.Image> _loadAssetImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(data.buffer.asUint8List(), completer.complete);
    return completer.future;
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

  void _startAnimation() {
    _calculateWinningLinePaths();
    _animationController.forward();
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight + 150, // 調整値
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(_kCanvasWidth, _kCanvasHeight),
                            painter: AmidaPainter(
                              horizontalLines: _horizontalLines,
                              nameList: widget.participantList,
                              lotteryList: lotteryList,
                              winningLinePaths: _winningLinePaths,
                              image: image,
                              animationProgress: _animation.value,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 60),
                    if (isShowButton)
                      ElevatedButton(
                        onPressed: () {
                          _startAnimation();
                          setState(() {
                            // ボタンを非表示にする
                            isShowButton = false;
                          });
                        },
                        child: const Text('結果を発表！'),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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
    required this.lotteryList,
    required this.winningLinePaths,
    required this.image,
    required this.animationProgress,
  });

  final List<HorizontalLine> horizontalLines;
  final List<Participant> nameList;
  final List<AmidaLottery> lotteryList;
  final List<List<Offset>> winningLinePaths;
  final ui.Image? image;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) {
      return;
    }

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
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final nameOffset = Offset(
        x - nameTextPainter.width / 2, // 中央揃え
        -nameTextPainter.height - 5, // 縦線の上に少し余白を加える
      );
      nameTextPainter.paint(canvas, nameOffset);

      // 各縦線の下に当たり画像を描画
      if (lotteryList[i] == AmidaLottery.win) {
        // 元画像の幅と高さ
        final originalWidth = image!.width.toDouble();
        final originalHeight = image!.height.toDouble();
        final aspectRatio = originalWidth / originalHeight;

        // 描画する画像の最大幅と高さ
        const maxWidth = 50.0; // 最大幅（任意で変更）
        const maxHeight = 50.0; // 最大高さ（任意で変更）

        // アスペクト比を保った描画サイズを計算
        late double drawWidth;
        late double drawHeight;

        if (aspectRatio > 1) {
          // 横長の場合、幅を最大幅に合わせる
          drawWidth = maxWidth;
          drawHeight = maxWidth / aspectRatio;
        } else {
          // 縦長の場合、高さを最大高さに合わせる
          drawHeight = maxHeight;
          drawWidth = maxHeight * aspectRatio;
        }

        // 中央揃えになるよう位置を調整
        final imageX = x - drawWidth / 2; // 中央揃え
        final imageY = size.height + 5; // 縦線の下に少し余白を加える

        // 描画先の範囲を設定
        final dstRect = Rect.fromLTWH(imageX, imageY, drawWidth, drawHeight);
        final srcRect = Rect.fromLTWH(0, 0, originalWidth, originalHeight);

        // Canvas に画像を描画
        canvas.drawImageRect(image!, srcRect, dstRect, Paint());
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
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke;

      final redLinePath = winningLinePaths.first;
      for (var i = 0; i < redLinePath.length - 1; i++) {
        final start = redLinePath[i];
        final end = redLinePath[i + 1];

        // アニメーションの進行度に基づき描画
        final progress = (i + 1) / redLinePath.length;
        if (animationProgress >= progress) {
          canvas.drawLine(start, end, redPaint);
        } else if (animationProgress >= i / redLinePath.length) {
          final t =
              (animationProgress - i / redLinePath.length) * redLinePath.length;
          final partialEnd = Offset(
            start.dx + (end.dx - start.dx) * t,
            start.dy + (end.dy - start.dy) * t, // 縦方向の補間を進行方向として維持
          );
          canvas.drawLine(start, partialEnd, redPaint);
          break;
        }
      }

      // 2人目の当選者をオレンジ色で塗っていく
      final orangePaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke;

      final orangeLinePath = winningLinePaths.last;

      for (var i = 0; i < orangeLinePath.length - 1; i++) {
        final start = orangeLinePath[i];
        final end = orangeLinePath[i + 1];

        // アニメーションの進行度に基づき描画
        final progress = (i + 1) / orangeLinePath.length;
        if (animationProgress >= progress) {
          canvas.drawLine(start, end, orangePaint);
        } else if (animationProgress >= i / orangeLinePath.length) {
          final t = (animationProgress - i / orangeLinePath.length) *
              orangeLinePath.length;
          final partialEnd = Offset(
            start.dx + (end.dx - start.dx) * t,
            start.dy + (end.dy - start.dy) * t, // 縦方向の補間を進行方向として維持
          );
          canvas.drawLine(start, partialEnd, orangePaint);
          break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
