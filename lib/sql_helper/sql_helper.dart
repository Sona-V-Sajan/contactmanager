import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';

class SQLHelper {
  //create database
  static Future<sql.Database> openDb() async {
    return sql.openDatabase('mycontacts', version: 1,
        onCreate: (sql.Database db, int version) async {
      await createTable(db);
    });
  }

  //create Table
  static Future<void> createTable(sql.Database db) async {
    await db.execute(
        'CREATE TABLE contact (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, cname TEXT, cnumber TEXT, cemail TEXT)');
  }

// insert
  static Future<int> addnewContact(
      String name, String number, String email) async {
    final db = await SQLHelper.openDb();
    final data = {"cname": name, "cnumber": number, "cemail": email};
    final id = await db.insert("contact", data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await SQLHelper.openDb();
    return db.query('contact', orderBy: 'id');
  }

  static Future<int> editContact(
      int id, String name, String number, String email) async {
    final db = await SQLHelper.openDb();
    final data = {"cname": name, "cnumber": number, "cemail": email};
    final updatedid =
        db.update("contact", data, where: 'id=?', whereArgs: [id]);
    return updatedid;
  }

  static Future<void> deleteContact(int id) async {
    final db = await SQLHelper.openDb();
    try {
      await db.delete('contact', where: 'id=?', whereArgs: [id]);
    } catch (e) {
      print("Something went wrong $e");
    }
  }
}
