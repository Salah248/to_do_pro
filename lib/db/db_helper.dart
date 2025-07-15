import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_pro/models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  // First thing for build database is to create the database
  // in this function we will initialize the database
  // this function will be called only once so we will initialize it in main when app start
  // we make it Future<void> because it will return nothing and it will be async
  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('not null');
      return;
    } else {
      try {
        // we use getDatabasesPath function to get the path of the database and add to path _task.db
        final String path = '${await getDatabasesPath()}_task.db';
        debugPrint('path: $path');
        // open the database
        // and then pass path and version to openDatabase function
        // if the database not exist it will create it by calling function onCreate
        // after that in function onCreate we will  use db.execute function to create the table
        // and pass the query to create the table
        // in query we will pass the variables that will be used in the query
        // some advices for the query:
        // Query variable He writes like this:
        // name + DataType + Comma
        // The types of DataType that used in the query are:
        // INTEGER for integer numbers
        // TEXT for text
        // STRING for text
        // What is the difference between TEXT and STRING??
        // TEXT is for text that can be longer than 255 characters
        // STRING is for text that can be shorter than 255 characters
        // bool is not supported in sqflite so we will use INTEGER
        // use PRIMARY KEY to make the id unique and AUTOINCREMENT
        _db = await openDatabase(
          path,
          version: _version,
          onCreate: (db, version) async {
            debugPrint('created');
            await db.execute(
              'CREATE TABLE $_tableName ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'title TEXT, note TEXT, date STRING, '
              'startTime STRING, endTime STRING, '
              'remind INTEGER, repeat STRING, '
              'color INTEGER, '
              'isCompleted INTEGER)',
            );
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }

  // insert function will insert the task to the database and return the id of the task
  // the id will be used to update the task and delete the task from the database
  // in insert function we pass the _tableName and task.toJson()
  static Future<int> insert(Task task) async {
    debugPrint('inserted');
    return await _db!.insert(_tableName, task.toJson());
  }

  // delete function will delete the task from the database
  // how to use delete function:
  // first we pass the _tableName
  // then we pass the where and whereArgs
  // then we use the id of the task to delete the task from the database
  // what where and whereArgs do?
  // where is the condition that we want to delete the task
  // whereArgs is the arguments that we want to use in the condition
  // in this case we want to delete the task by id
  // what is this condition  id = ? mean ?
  // in this case we want to delete the task by id
  static Future<int> delete(Task task) async {
    debugPrint('deleted');
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);
  }

  // query function will query the database and return the tasks from the database
  // this function will be used to get the tasks from the database
  // we nead to pass the _tableName
  static Future<List<Map<String, dynamic>>> query() async {
    debugPrint('queried');
    return await _db!.query(_tableName);
  }

  // rawUpdate Function will update the task in the database
  // how to use rawUpdate function:
  // we write the query in the rawUpdate function
  // first we pass the _tableName
  // then we pass the query and the arguments
  // in this case we want to update the task by id
  // then we pass the arguments that we want to use in the query
  // after write the query
  // we pass [1, id]  what this [1, id] mean ?
  // in this case we want to update the task by id and set isCompleted equal to 1
  static Future<int> rawUpdate(int id) async {
    debugPrint('rawUpdated ');
    return await _db!.rawUpdate(
      ''' 
    UPDATE $_tableName
    SET isCompleted = ?
    WHERE id = ?
    ''',
      [1, id],
    );
  }
}
