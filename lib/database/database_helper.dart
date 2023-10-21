import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDB() async {
    if (_db != null) {
      //if db isn't null this means it has been already initialized, so return;
      return;
    }
    try {
      //database name not necessary to be as same as table name
      String path = '${await getDatabasesPath()}tasks.db';
      _db = await openDatabase(path, version: _version,
          onCreate: (db, version) async {
        print('Creating a new one');
        return await db.execute(
          'CREATE TABLE $_tableName('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title STRING, note TEXT, date STRING, '
          'startTime STRING, endTime STRING, '
          'remind INTEGER, repeat STRING, '
          'color INTEGER, '
          'isCompleted INTEGER)',
        );
      });
    } catch (error) {
      print(error);
    }
  }

  static Future<int> insert(Task? task) async {
    print('insert function called');
    //returns the id of the last inserted row
    try {
      if (_db == null) {
        await initDB();
      }
      return await _db!.insert(_tableName, task!.convertDataToJson());
    } catch (e) {
      print('Error from insert() in database helper is $e');
    }
    return 0;
    //await _db?.insert(_tableName, task!.convertDataToJson())??1;
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print('Query function called');
    return await _db!.query(_tableName);
  }

  static delete(int taskId) async {
    await _db!.delete(_tableName, where: 'id=?', whereArgs: [taskId]);
  }

//You can modify this method and use it to edit the whole task !!!
  static update(int taskId) async {
    await _db!.rawUpdate('''
     UPDATE $_tableName
     SET isCompleted = ?
     WHERE id = ?
     ''', [1, taskId]);
  }
}
