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

  Future<int> deleteTasksFromDB({Task? task}) async {
    return DBHelper.delete(task!);
  }

  Future<int> markTaskCompletedInDB({int? id}) async {
    return DBHelper.rawUpdate(id!);
  }
}
