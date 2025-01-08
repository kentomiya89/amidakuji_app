enum CoupleRole {
  groom(roleName: '新郎'),
  bride(roleName: '新婦'),
  ;

  const CoupleRole({required this.roleName});

  final String roleName;
}
