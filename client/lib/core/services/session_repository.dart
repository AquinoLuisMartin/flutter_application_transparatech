import 'database_service.dart';

class Session {
  final int? id;
  final int userId;
  final String token;
  final DateTime expiresAt;
  final DateTime? createdAt;

  Session({
    this.id,
    required this.userId,
    required this.token,
    required this.expiresAt,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'token': token,
      'expires_at': expiresAt.millisecondsSinceEpoch,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      token: map['token'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expires_at'] as int),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }
}

class SessionRepository {
  static const String _tableName = 'sessions';

  static Future<int> createSession(Session session) async {
    return await DatabaseService.insert(_tableName, session.toMap());
  }

  static Future<Session?> getSessionById(int id) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Session.fromMap(results.first);
  }

  static Future<Session?> getSessionByToken(String token) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'token = ?',
      whereArgs: [token],
    );

    if (results.isEmpty) return null;
    return Session.fromMap(results.first);
  }

  static Future<List<Session>> getSessionsByUserId(int userId) async {
    final results = await DatabaseService.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return results.map((map) => Session.fromMap(map)).toList();
  }

  static Future<int> updateSession(Session session) async {
    return await DatabaseService.update(
      _tableName,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  static Future<int> deleteSession(int id) async {
    return await DatabaseService.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteExpiredSessions() async {
    return await DatabaseService.delete(
      _tableName,
      where: 'expires_at < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }

  static Future<int> deleteSessionsByUserId(int userId) async {
    return await DatabaseService.delete(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
