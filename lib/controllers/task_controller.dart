import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';
import 'package:to_do_pro/models/task.dart';

class TaskController extends GetxController {
  final taskList = <Task>[
    Task(
      id: 1,
      title: 'Task 1',
      note: 'Description for Task 1',
      startTime: DateFormat(
        'hh:mm a',
      ).format(DateTime.now().add(const Duration(minutes: 1))).toString(),
      color: 0,
      isCompleted: 0,
    ),
  ];
  getTasks() {}
}
