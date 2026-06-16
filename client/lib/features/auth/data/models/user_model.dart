class User {
  final int accountId;
  final String? studentId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final String? dateOfBirth;
  final int roleId;
  final int? organizationId;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.accountId,
    this.studentId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.dateOfBirth,
    required this.roleId,
    this.organizationId,
    required this.isActive,
    required this.isVerified,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName {
    if (lastName.isEmpty || lastName.trim().toLowerCase() == firstName.trim().toLowerCase()) {
      return firstName;
    }
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accountId: json['accountId'] ?? 0,
      studentId: json['studentId'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      dateOfBirth: json['dateOfBirth'],
      roleId: json['roleId'] ?? 0,
      organizationId: json['organizationId'],
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      isVerified: json['isVerified'] == 1 || json['isVerified'] == true,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'studentId': studentId,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'dateOfBirth': dateOfBirth,
      'roleId': roleId,
      'organizationId': organizationId,
      'isActive': isActive ? 1 : 0,
      'isVerified': isVerified ? 1 : 0,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
