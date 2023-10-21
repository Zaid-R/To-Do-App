import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:to_do_app/UI/home_page.dart';
import 'package:to_do_app/UI/theme.dart';
import 'package:to_do_app/database/database_helper.dart';
import 'package:to_do_app/services/theme_services.dart';

void main() async{
  //WidgetFlutterBinding is used to interact with the Flutter engine
  //GetStorage.init() needs to call native code to initialize GetStorage
  //and since the plugin needs to use platform channels to call the native code,which is done asynchronously
  //therefore you have to call ensureInitialized() to make sure that you have an instance of the WidgetsBinding.
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  //getStorage has to be initialized in the entry point of the app
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //MaterialApp + Getx properties = GetMaterialApp
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().getTheme(),
      home: HomePage()
    );
  }
}