import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_pro/controllers/task_controller.dart';
import 'package:to_do_pro/models/task.dart';
import 'package:to_do_pro/services/notification_services.dart';
import 'package:to_do_pro/services/theme_services.dart';
import 'package:to_do_pro/ui/pages/add_task_page.dart';
import 'package:to_do_pro/ui/size_config.dart';
import 'package:to_do_pro/ui/theme.dart';
import 'package:to_do_pro/ui/widgets/button.dart';
import 'package:to_do_pro/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());
  late NotifyHelper notifyHelper;

  // in initState we will initialize the NotifyHelper
  // and then we will use it to request iOS permissions
  // and initialize the notification settings.
  // This is important to ensure that the notifications work properly on iOS devices.
  @override
  void initState() {
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification(); // تهيئة الإشعارات
    _taskController.getTasksFromDB(); // تحميل المهام
    super.initState();
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: IconButton(
        padding: const EdgeInsets.all(0),
        icon: Icon(
          Get.isDarkMode
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round_outlined,
          size: 20,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
        onPressed: () async {
          ThemeServices().switchTheme();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.cleaning_services_outlined,
            size: 20,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: Text('Clear all tasks?', style: titleStyle),
                content: Row(
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        notifyHelper.cancelAllNotification();
                        _taskController.deleteAllTasksFromDB();
                        Get.back();
                        Get.snackbar(
                          'Deleted',
                          'All tasks deleted successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blueGrey[100],
                          colorText: pinkClr,
                          icon: const Icon(Icons.done, color: pinkClr),
                        );
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('asset/images/person.jpeg'),
          backgroundColor: Colors.transparent,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(children: [_addDateBar(), _dateBarPicker(), _showTasks()]),
    );
  }

  Widget _addDateBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(_selectedDate),
                style: subHeadingStyle,
              ),
              Text(
                _isToday(_selectedDate)
                    ? 'Today'
                    : DateFormat.E().format(_selectedDate),
                style: subHeadingStyle,
              ),
            ],
          ),
          const SizedBox(width: 20),
          MyButton(
            label: '+ Add Task',
            onTap: () async {
              // Add your task addition logic here
              await Get.to(() => const AddTaskPage());
              _taskController.getTasksFromDB();
            },
          ),
        ],
      ),
    );
  }

  Widget _noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 180),
                  SvgPicture.asset(
                    'asset/images/task.svg',
                    height: 100,
                    semanticsLabel: 'Task',
                    colorFilter: ColorFilter.mode(
                      primaryClr.withAlpha((.5 * 255).round()),
                      BlendMode.srcIn,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Text(
                      'You do not have any task yet!\nAdd new task to make your day productive',
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 120)
                      : const SizedBox(height: 220),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    await _taskController.getTasksFromDB();
  }

  Widget _showTasks() {
    return Expanded(
      child: Obx(() {
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemCount: _taskController.taskList.length,
              itemBuilder: (context, index) {
                final task = _taskController.taskList[index];
                if (task.date == DateFormat.yMd().format(_selectedDate) ||
                    task.repeat == 'Daily' ||
                    (task.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                      DateFormat.yMd().parse(task.date!),
                                    )
                                    .inDays %
                                7 ==
                            0) ||
                    (task.repeat == 'Monthly' &&
                        DateFormat.yMd().parse(task.date!).day ==
                            _selectedDate.day)) {
                  final date = DateFormat('hh:mm a').parse(task.startTime!);
                  final myTime = DateFormat('HH:mm').format(date);

                  notifyHelper.scheduleNotification(
                    int.parse(myTime.toString().split(':')[0]),
                    int.parse(myTime.toString().split(':')[1]),
                    task,
                  );
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 1000),
                    child: SlideAnimation(
                      horizontalOffset: 300,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () => _showBottomSheet(context, task),
                          child: TaskTile(task),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        }
      }),
    );
  }

  Widget _dateBarPicker() {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 70,
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        initialSelectedDate: _selectedDate,
        dateTextStyle: body3Style.copyWith(fontSize: 20),
        dayTextStyle: body3Style.copyWith(fontSize: 16),
        monthTextStyle: body3Style.copyWith(fontSize: 12),
        onDateChange: (date) {
          // New date selected
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // the explaination of the _buildBottomSheet function and _showBottomSheet function
  // firstly the _buildBottomSheet function is used to create a bottom sheet widget that displays a label, an onTap function, and a color.
  // the parameters of the function are: label, onTap, clr, and isClose.
  // the label parameter is used to display a label on the bottom sheet widget.
  // the onTap parameter is used to specify the function that should be called when the user taps on the bottom sheet widget.
  // the clr parameter is used to specify the color of the bottom sheet widget.
  // the isClose parameter is used to specify whether the bottom sheet widget should be closed when the user taps on it.
  // the _showBottomSheet function is used to show the bottom sheet widget when the user taps on the button.
  // in _showBottomSheet function , we use Get.bottomSheet to display the bottom sheet widget.
  // Get.bottomSheet is a method provided by the GetX package that allows you to easily create and display bottom sheets in your Flutter application.
  // after that, we create a SingleChildScrollView widget to allow scrolling if the content exceeds the available height.
  // we then create a Container widget to hold the content of the bottom sheet.
  // we use Column widget to display the content of the bottom sheet.

  _buildBottomSheet({
    required String label,
    required Function() onTap,
    required Color clr,
    bool isClose = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose
                ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          height: (SizeConfig.orientation == Orientation.landscape)
              ? (task.isCompleted == 1
                    ? SizeConfig.screenHeight * .6
                    : SizeConfig.screenHeight * .8)
              : (task.isCompleted == 1
                    ? SizeConfig.screenHeight * .40
                    : SizeConfig.screenHeight * .49),
          color: Get.isDarkMode ? darkHeaderClr : white,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              task.isCompleted == 1
                  ? Container()
                  : _buildBottomSheet(
                      label: 'Task Completed',
                      onTap: () {
                        notifyHelper.cancelScheduledNotification(task);
                        _taskController.markTaskCompletedInDB(id: task.id);
                        Get.back();
                      },
                      clr: primaryClr,
                    ),
              task.isCompleted == 1
                  ? Container()
                  : Divider(
                      color: Get.isDarkMode ? Colors.grey : darkGreyClr,
                      indent: 20,
                      endIndent: 20,
                    ),
              _buildBottomSheet(
                label: 'Delete Task',
                onTap: () {
                  notifyHelper.cancelScheduledNotification(task);
                  _taskController.deleteTasksFromDB(task: task);
                  Get.back();
                },
                clr: pinkClr,
              ),
              Divider(
                color: Get.isDarkMode ? Colors.grey : darkGreyClr,
                indent: 20,
                endIndent: 20,
              ),

              _buildBottomSheet(
                label: 'Cancel',
                onTap: () {
                  Get.back();
                },
                clr: primaryClr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
