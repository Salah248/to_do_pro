import 'package:flutter/material.dart';
import 'package:to_do_pro/services/theme_services.dart';
import 'package:to_do_pro/ui/size_config.dart';
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => ThemeServices().switchTheme(),
          icon: const Icon(Icons.light_mode),
        ),
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
              },
            ),
            const InputField(
              title: 'Title',
              hint: 'Enter your task here',
              controller: null,
              widget: Icon(Icons.access_alarm),
            ),
          ],
        ),
      ),
    );
  }
}
