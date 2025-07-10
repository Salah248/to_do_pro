import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:to_do_pro/models/task.dart';

class TaskController extends GetxController {
  final taskList = <Task>[
    Task(
      title: 'Task 1',
      note: 'Description for Task 1',
      startTime: '08:00 AM',
      endTime: '09:00 AM',
      color: 0,
      isCompleted: 0,
    ),
    Task(
      title: 'Task 2',
      note: 'Description for Task 2',
      startTime: '09:00 AM',
      endTime: '10:00 AM',
      color: 1,
      isCompleted: 1,
    ),
    Task(
      title: 'Task 3',
      note: 'Description for Task 3',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      color: 2,
      isCompleted: 0,
    ),
  ];
  getTasks() {}
}
