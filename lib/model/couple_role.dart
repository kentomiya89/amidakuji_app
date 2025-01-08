import 'package:amidakuji_app/gen/assets.gen.dart';

enum CoupleRole {
  groom(roleName: '新郎'),
  bride(roleName: '新婦'),
  ;

  const CoupleRole({required this.roleName});

  final String roleName;

  String get winningImagePath {
    return switch (this) {
      CoupleRole.groom => Assets.beer.path,
      CoupleRole.bride => Assets.chocolate.path,
    };
  }
}
