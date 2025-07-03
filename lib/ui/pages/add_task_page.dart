import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_pro/controllers/task_controller.dart';
import 'package:to_do_pro/ui/theme.dart';
import 'package:to_do_pro/ui/widgets/button.dart';
import 'package:to_do_pro/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final String _startTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now()).toString();
  final String _endTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now().add(const Duration(minutes: 15))).toString();

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 24),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text('Add Task', style: headingStyle),
        actions: const [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('asset/images/person.jpeg'),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const SizedBox(height: 10),
                InputField(
                  title: 'Title',
                  hint: 'Enter your title',
                  controller: _titleController,
                ),
                const SizedBox(height: 10),
                InputField(
                  title: 'Note',
                  hint: 'Enter your note',
                  controller: _noteController,
                ),
                const SizedBox(height: 10),
                InputField(
                  title: 'Date',
                  hint: DateFormat.yMd().format(_selectedDate),
                  widget: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        title: 'Start Time',
                        hint: _startTime,
                        widget: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {},
                          icon: const Icon(Icons.access_time_outlined),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InputField(
                        title: 'End Time',
                        hint: _endTime,
                        widget: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {},
                          icon: const Icon(Icons.access_time_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InputField(
                  title: 'Remind',
                  hint: '$_selectedRemind minutes early',
                  widget: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedRemind = value as int;
                        });
                      },
                      items: remindList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.toString(), style: bodyStyle),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InputField(
                  title: 'Repeat',
                  hint: _selectedRepeat,
                  widget: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      elevation: 4,
                      iconSize: 32,
                      onChanged: (value) {
                        setState(() {
                          _selectedRepeat = value as String;
                        });
                      },
                      items: repeatList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color', style: titleStyle),
                        const SizedBox(height: 3),
                        // Color selection widget
                        // to make Color selection i used Wrap widget and List.generate method to generate 3 CircleAvatar widgets
                        // why wrap widget? because it allows us to wrap the children in a horizontal or vertical manner
                        // and to control the spacing between them
                        //How make Icon Done inside CircleAvatar?
                        // i used GestureDetector to detect the tap on CircleAvatar and change the _selectedColor
                        // then i used a conditional operator to check if the _selectedColor is equal to the index of the CircleAvatar
                        // if it is equal then i show the Icon Done inside the CircleAvatar
                        // else i show the CircleAvatar without the Icon Done
                        Wrap(
                          children: List<Widget>.generate(
                            3,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: index == 0
                                      ? primaryClr
                                      : index == 1
                                      ? pinkClr
                                      : orangeClr,
                                  child: _selectedColor == index
                                      ? const Icon(
                                          Icons.done,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    MyButton(
                      label: 'Create Task',
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();

    super.dispose();
  }
}
