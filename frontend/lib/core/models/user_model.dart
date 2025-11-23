class UserModel {
  final int? id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImage;
  final String role;

  UserModel({
    this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImage,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['userId'], // Support both 'id' and 'userId'
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      role: json['role'] ?? 'CLIENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'role': role,
    };
  }
}

