class UserModel {
  String? id;
  String qrId;
  String name;
  String email;
  String status;
  bool hadFood;
  bool registered;

  UserModel({
    this.id,
    required this.qrId,
    required this.name,
    required this.email,
    this.status = 'pending',
    this.hadFood = false,
    this.registered = false,
  });

  // Factory constructor for creating UserModel from Supabase data
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id']?.toString(),
      qrId: data['qr_id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      hadFood: data['hadFood'] == true || data['hadfood'] == true,
    );
  }

  // Legacy factory for old API compatibility
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
    'status': status,
    'hadFood': hadFood,
    'registered': registered,
  };

  Map<String, dynamic> toSupabase() => {
    'qr_id': qrId,
    'name': name,
    'email': email,
    'status': status,
    'hadFood': hadFood,
  };
}
