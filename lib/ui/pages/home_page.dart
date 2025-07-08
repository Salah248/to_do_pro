import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
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
  DateTime _nowDate = DateTime.now();
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
    notifyHelper.initializeNotification();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
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
          onPressed: () {
            ThemeServices().switchTheme();
            notifyHelper.showNotification(
              title: 'Theme Changed',
              body:
                  'Theme changed to ${Get.isDarkMode ? 'Light' : 'Dark'} mode',
            );
            notifyHelper.scheduleNotification();
          },
        ),
        actions: const [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('asset/images/person.jpeg'),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_addDateBar(), _dateBarPicker(), _showTasks()],
        ),
      ),
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
                DateFormat.yMMMMd().format(_nowDate),
                style: subHeadingStyle,
              ),
              Text(
                _isToday(_nowDate) ? 'Today' : DateFormat.E().format(_nowDate),
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
              //  _taskController.getTasks();
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
                    : const SizedBox(height: 220),
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
                    : const SizedBox(height: 180),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _showTasks() {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(
          context,
          Task(
            title: 'Sample Task',
            startTime: '10:00 AM',
            endTime: '11:00 AM',
            color: 2, // Example color
            isCompleted: 0,
            note: 'This is a sample task note.',
          ),
        );
      },
      child: TaskTile(
        Task(
          title: 'Sample Task',
          startTime: '10:00 AM',
          endTime: '11:00 AM',
          color: 2, // Example color
          isCompleted: 0,
          note: 'This is a sample task note.',
        ),
      ),
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
        initialSelectedDate: _nowDate,
        dateTextStyle: body3Style.copyWith(fontSize: 20),
        dayTextStyle: body3Style.copyWith(fontSize: 16),
        monthTextStyle: body3Style.copyWith(fontSize: 12),
        onDateChange: (date) {
          // New date selected
          setState(() {
            _nowDate = date;
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
                        Get.back();
                      },
                      clr: primaryClr,
                    ),
              Divider(
                color: Get.isDarkMode ? Colors.grey : darkGreyClr,
                indent: 20,
                endIndent: 20,
              ),
              _buildBottomSheet(
                label: 'Delete Task',
                onTap: () {
                  Get.back();
                },
                clr: primaryClr,
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
