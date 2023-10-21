import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bluishColor = Color(0xFF4e5ae8);
const Color yellowColor = Color(0xFFFFB746);
const Color pinkColor = Color(0xFFff4667);
const Color whiteColor = Colors.white;
const primaryColor = bluishColor;
const Color darkGreyColor = Color(0xFF121212);
Color darkHeaderColor = Colors.grey[800]!;


class Themes {
  static final light = ThemeData(
      backgroundColor:whiteColor,
      primaryColor: primaryColor,
      brightness: Brightness.light,
      useMaterial3: true);

  static final dark = ThemeData(
    backgroundColor: darkGreyColor,
    primaryColor: darkGreyColor,
    brightness: Brightness.dark,
  );
}

TextStyle buildGoogleFontsStyle(double? fontSize,Color? color,FontWeight? fontWeight){
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color
    )
  );
}


//public
TextStyle subHeadingStyle(bool isDarkMode){
  var color = Colors.grey[isDarkMode?400:500];
  return buildGoogleFontsStyle(20,color,FontWeight.w400);
}

TextStyle headingStyle(bool isDarkMode){
  var color = isDarkMode?whiteColor:Colors.black;
  return buildGoogleFontsStyle(26,color,FontWeight.bold);
}
//TODO: find a way to remove parameter isDarkMode from these methods
TextStyle titleStyle(bool isDarkMode){
  return headingStyle(isDarkMode).copyWith(fontSize:16,fontWeight: FontWeight.w600);
}

TextStyle subTitleStyle(bool isDarkMode){
  return buildGoogleFontsStyle(14, Colors.grey[isDarkMode?100:400], FontWeight.w400);
}