class UserModel {
  final String id;
  final String name;
  final String email;
  final int alertTime;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.alertTime,
  });

  factory UserModel.fromFirestore(doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      alertTime: data['alertTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'alertTime': alertTime,
    };
  }
}
