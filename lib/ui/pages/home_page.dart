import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import 'package:to_do_pro/services/theme_services.dart';
import 'package:to_do_pro/ui/pages/add_task_page.dart';
import 'package:to_do_pro/ui/size_config.dart';
import 'package:to_do_pro/ui/theme.dart';
import 'package:to_do_pro/ui/widgets/button.dart';
import 'package:to_do_pro/ui/widgets/input_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
          onPressed: () {
            ThemeServices().switchTheme();
          },
        ),
        actions: const [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('asset/images/person.jpeg'),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyButton(
              label: 'Add Task',
              onTap: () {
                // Add your task addition logic here
                Get.to(() => const AddTaskPage());
              },
            ),
            const InputField(title: 'Title', hint: 'Enter your task here'),
          ],
        ),
      ),
    );
  }
}
