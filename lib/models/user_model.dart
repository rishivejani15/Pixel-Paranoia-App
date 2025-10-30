class UserModel {
  String qrId;
  String name;
  String email;
  bool registered;
  bool hadFood;

  UserModel({
    required this.qrId,
    required this.name,
    required this.email,
    this.registered = false,
    this.hadFood = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    qrId: m['qrId'] as String,
    name: m['name'] as String? ?? '',
    email: m['email'] as String? ?? '',
    registered: m['registered'] as bool? ?? false,
    hadFood: m['hadFood'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'qrId': qrId,
    'name': name,
    'email': email,
    'registered': registered,
    'hadFood': hadFood,
  };
}
