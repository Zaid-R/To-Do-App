import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices{
   final _themeInfo = GetStorage();
   final _key = 'isDarkMode';

   //At first read, the value of _key will be null, so _isDarkMode will return false
   bool get _isDarkMode => _themeInfo.read(_key)??false;

   void _setTheme(bool isDarkMode)=>_themeInfo.write(_key, isDarkMode);

   ThemeMode getTheme()=> _isDarkMode?ThemeMode.dark:ThemeMode.light;

   void switchTheme(){
    Get.changeThemeMode(_isDarkMode?ThemeMode.light:ThemeMode.dark);
    _setTheme(!_isDarkMode);
   }
}