import 'dart:math';

/// 渡された範囲の中で、ランダムな0.05区切りの値を返す
///
/// 返す値の例
/// e.g.  0.05, 0.25, 0.75
double randomDecimalInRangeWithStep05(int min, int max) {
  final randomValue = Random().nextInt(max - min);

  return (min + randomValue) * 5 / 100;
}
