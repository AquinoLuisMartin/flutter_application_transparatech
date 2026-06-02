import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DatabaseService {
  static const String _databaseName = 'transparatech.db';
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    // Check if database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Copy database from assets
      await _copyDatabaseFromAssets(path);
    }

    return await openDatabase(path, version: 1);
  }

  static Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      final data = await rootBundle.load('assets/db/schema.sql');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      // Create file and write schema
      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      // If direct copy fails, use SQL execution
      final db = await openDatabase(path);
      final schemaString = await rootBundle.loadString('assets/db/schema.sql');
      final statements = schemaString.split(';').where((s) => s.trim().isNotEmpty).toList();
      
      for (final statement in statements) {
        await db.execute(statement);
      }
      
      await db.close();
    }
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }

  // Helper methods
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  static Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
