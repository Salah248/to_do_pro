import 'package:get/get.dart';
import 'package:to_do_pro/db/db_helper.dart';
import 'package:to_do_pro/models/task.dart';

class TaskController extends GetxController {
  final taskList = <Task>[].obs;

  Future<int> addTaskToDB({Task? task}) {
    return DBHelper.insert(task!);
  }

  Future<void> getTasksFromDB() async {
    final tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  Future<void> deleteTasksFromDB({Task? task}) async {
    await DBHelper.delete(task!);
    getTasksFromDB();
  }

  Future<void> deleteAllTasksFromDB() async {
    await DBHelper.deleteAll();
    getTasksFromDB();
  }

  Future<void> markTaskCompletedInDB({int? id}) async {
    await DBHelper.rawUpdate(id!);
    getTasksFromDB();
  }
}
