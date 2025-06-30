import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:to_do_pro/services/theme_services.dart';
import 'package:to_do_pro/ui/pages/home_page.dart';
import 'package:to_do_pro/ui/theme.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToDoPro',
      debugShowCheckedModeBanner: false,
      darkTheme: Themes.darkTheme,
      themeMode: ThemeServices().theme,
      theme: Themes.lightTheme,
      home: const HomePage(),
    );
  }
}
