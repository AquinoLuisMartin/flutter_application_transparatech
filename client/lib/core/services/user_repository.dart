import 'database_service.dart';

class User {
  final int? id;
  final String email;
  final String password;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.email,
    required this.password,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }
}

class UserRepository {
  static const String _tableName = 'users';

  static Future<int> createUser(User user) async {
    return await DatabaseService.insert(_tableName, user.toMap());
  }

  static Future<User?> getUserById(int id) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  static Future<User?> getUserByEmail(String email) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  static Future<List<User>> getAllUsers() async {
    final results = await DatabaseService.query(_tableName);
    return results.map((map) => User.fromMap(map)).toList();
  }

  static Future<int> updateUser(User user) async {
    return await DatabaseService.update(
      _tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<int> deleteUser(int id) async {
    return await DatabaseService.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
